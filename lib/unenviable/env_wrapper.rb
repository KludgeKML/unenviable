module Unenviable
  # Wraps the ENV variable to catch calls to ENV where the value
  # is missing or not specified in Unenviable's YAML file.
  class ENVWrapper
    def initialize
      @saved_env = ENV
    end

    def [](key)
      value = @saved_env[key]
      fail "Requested ENV[#{key}] which has not been described!" unless Unenviable.described?(key)
      return value unless value.nil?
      'MISSING VALUE'
    end

    def []=(key, value)
      @saved_env[key] = value
    end
  end
end
