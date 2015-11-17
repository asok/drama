require 'active_support/core_ext/class/attribute'

require 'drama/whitelisting'

module Drama
  class Act
    attr_accessor :controller, :params
    class_attribute :whitelisting

    def initialize(controller = nil)
      self.controller = controller
    end

    def call
      raise NotImplementedError
    end

    def self.require_params(key)
      whitelisting = Whitelisting.new(key)

      self.whitelisting ||= []
      self.whitelisting.push(whitelisting)

      define_method("#{key}_params") do
        if controller
          controller.params.require(whitelisting.required).permit(whitelisting.permitted)
        else
          raise "the controller is not set (the act should be initialized with it)"
        end
      end

      whitelisting
    end
  end
end
