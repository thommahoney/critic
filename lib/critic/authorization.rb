# frozen_string_literal: true
class Critic::Authorization
  attr_reader :policy, :action
  attr_accessor :messages, :granted, :result, :metadata

  def initialize(policy, action)
    @policy = policy
    @action = action&.to_sym

    @metadata = {}
    @granted, @result = nil
    @messages = []
  end

  def granted?
    true == @granted
  end

  def denied?
    false == @granted
  end
end
