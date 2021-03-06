# frozen_string_literal: true
module Critic::Controller
  extend ActiveSupport::Concern

  included do
    if respond_to?(:hide_action)
      hide_action(:authorize)
      hide_action(:authorize_scope)
    end
  end

  def authorize(resource, action = default_action, policy: policy(resource), with: nil)
    authorizing!

    args = [with] if !with.is_a?(Array) && !with.nil?

    @authorization = policy.authorize(action, critic, resource, args)

    authorization_failed! if @authorization.denied?

    @authorization.result
  end

  def authorized?(resource, *args, **options)
    authorize(resource, *args, **options)
  rescue Critic::AuthorizationDenied
    false
  end

  def authorize_scope(scope, *args, action: nil, policy: policy(scope), **options)
    authorization_action = action || policy.scope

    authorize(scope, authorization_action, *args, policy: policy, **options)
  end

  protected

  attr_reader :authorization

  def authorization_failed!
    raise Critic::AuthorizationDenied, authorization
  end

  def authorization_missing!
    raise Critic::AuthorizationMissing
  end

  def verify_authorized
    (true == @_authorizing) || authorization_missing!
  end

  def authorizing!
    @_authorizing = true
  end

  def policy(object)
    Critic::Policy.for(object)
  end

  def critic
    (defined?(consumer) && consumer) || current_user
  end

  private

  def default_action
    defined?(params) && params[:action]
  end
end
