module Drama
  module RSpec
    class FallbackToExampleController
      attr_accessor :__example__

      def method_missing(method_name, *args, &blk)
        if __example__.respond_to?(method_name)
          __example__.send(method_name, *args, &blk)
        else
          super
        end
      end
    end
  end
end
