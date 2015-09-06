require 'active_support/core_ext/class/attribute'

require_relative './whitelisting'

module Drama
  class Act
    attr_accessor :controller, :params
    class_attribute :whitelisting

    def initialize(controller = nil)
      self.controller = controller

      (self.class.whitelisting || []).each do |listing|
        self.send("#{listing.required}_params=",
                  controller.params.require(listing.required).permit(listing.permitted))
      end
    end

    def call
      raise NotImplementedError
    end

    def self.require_params(key)
      whitelisting = Whitelisting.new(key)

      self.whitelisting ||= []
      self.whitelisting.push(whitelisting)

      define_method("#{key}_params")      {       instance_variable_get("@#{key}") }
      define_method("#{key}_params="){ |arg| instance_variable_set("@#{key}", arg) }

      whitelisting
    end
  end
end
