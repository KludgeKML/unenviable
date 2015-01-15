module Unenviable
  # Wraps the ENV variable to catch calls to ENV where the value
  # is missing or not specified in Unenviable's YAML file.
  class ENVWrapper
    def initialize
      @saved_env = ENV
      @closed = false
      @missing_descriptions = []
    end

    def [](key)
      fail "Requested ENV[#{key}] after initialization finished!" if @closed
      value = @saved_env[key]
      @missing_descriptions << key unless Unenviable.described?(key)
      return value unless value.nil?
      'MISSING VALUE'
    end

    def []=(key, value)
      @saved_env[key] = value
    end

    def restore_saved
      Object.send(:remove_const, :ENV)
      Object.const_set(:ENV, @saved_env)
    end

    def close_wrapper
      @closed = true
      fail "Requested Keys [#{@missing_descriptions.join(', ')}] which are not described!" unless @missing_descriptions.empty?
    end
  end
end
