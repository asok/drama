require "drama/version"
require "drama/act"
require "drama/whitelisting"
require "drama/name_error"
require "drama/rspec"

require "active_support"
require "active_support/core_ext"

module Drama
  extend ActiveSupport::Concern

  included do
    class_attribute :acts
  end

  def act
    act_class = self.class.acts[action_name.intern]
    raise("No act was registered for action '#{action_name}'") unless act_class

    act_class.new(self)
  end

  def act!(*args, &blk)
    act.call(*args, &blk)
  end

  class_methods do
    def acts_on(*args)
      self.acts ||= {}

      acts = args.extract_options!

      args.each do |action_name|
        acts.merge!(
          action_name => [
            action_name.to_s.camelize,
            controller_name.singularize.camelize,
            "Act"
          ].join.constantize
        )
      end

      self.acts = acts
    rescue ::NameError => e
      raise Drama::NameError, "Please create #{e.missing_name} class in the app/acts directory"
    end
  end
end
