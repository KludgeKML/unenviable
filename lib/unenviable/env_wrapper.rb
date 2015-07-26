module Unenviable
  # Wraps the ENV variable to catch calls to ENV where the value
  # is missing or not specified in Unenviable's YAML file.
  class ENVWrapper

    COMMON_RAILS = %w{
      RACK_ENV SECRET_KEY_BASE RUBY_MIME_TYPES_LAZY_LOAD
      RUBY_MIME_TYPES_CACHE RUBY_MIME_TYPES_DATA RUBY_MIME_TYPES_CACHE
      COFFEESCRIPT_SOURCE_PATH DATABASE_URL
    }

    def initialize
      @saved_env = ENV
      @closed = false
      @missing_descriptions = []

      discrepancies = Unenviable.check
      problems = ''
      problems += "Required Keys [#{discrepancies[:required].join(', ')}] for this environment are missing! " unless discrepancies[:required].empty?
      problems += "Keys [#{discrepancies[:forbidden].join(', ')}] are forbidden in this environment! " unless discrepancies[:forbidden].empty?
      handle_problem(problems) unless problems.blank?
    end

    def [](key)
      handle_problem("Requested ENV[#{key}] after initialization finished!") if @closed && !COMMON_RAILS.include?(key)
      value = @saved_env[key]
      @missing_descriptions << key unless Unenviable.described?(key) || COMMON_RAILS.include?(key)
      return value unless value.nil?
    end

    def []=(key, value)
      @saved_env[key] = value
    end

    def restore_saved
      Object.send(:remove_const, :ENV)
      Object.const_set(:ENV, @saved_env)
    end

    def close_wrapper
      handle_problem("Requested Keys [#{@missing_descriptions.join(', ')}] which are not described!") unless @missing_descriptions.empty?
      @closed = true
    end

    private

    def handle_problem(value)
      Rails.logger.warn(value) if defined?(Rails)
      fail value if (Unenviable.strict? && !@closed) || (Unenviable.runtime_strict?)
    end
  end
end
