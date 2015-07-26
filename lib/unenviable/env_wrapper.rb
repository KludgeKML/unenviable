module Unenviable
  # Wraps the ENV variable to catch calls to ENV where the value
  # is missing or not specified in Unenviable's YAML file.
  class ENVWrapper

    COMMON_RAILS = %w{RACK_ENV SECRET_KEY_BASE RUBY_MIME_TYPES_LAZY_LOAD}
    CLOSE_ON = %w{RACK_ENV}

    def initialize
      @saved_env = ENV
      @closed = false
      @missing_descriptions = []
    end

    def [](key)
      puts "Requested ENV[#{key}] after initialization finished!" if @closed
      puts "(Is it actually finished? #{Rails.initialized?})" if @closed
      value = @saved_env[key]
      @missing_descriptions << key unless Unenviable.described?(key) || COMMON_RAILS.include?(key)
      return value unless value.nil?
    end

    def []=(key, value)
      close_wrapper if CLOSE_ON.include?(key) && !@closed
      @saved_env[key] = value
    end

    def restore_saved
      Object.send(:remove_const, :ENV)
      Object.const_set(:ENV, @saved_env)
    end

    def close_wrapper
      @closed = true
      puts "Requested Keys [#{@missing_descriptions.join(', ')}] which are not described!" unless @missing_descriptions.empty?
    end
  end
end
