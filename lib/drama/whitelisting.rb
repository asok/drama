module Drama
  class Whitelisting
    attr_reader :required, :permitted

    def initialize(required)
      @required = required
    end

    def permit(*permitted)
      @permitted = permitted
      self
    end
  end
end
