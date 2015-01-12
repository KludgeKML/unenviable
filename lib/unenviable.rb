# encoding: utf-8
require 'dotenv'
require 'yaml'

require 'unenviable/env_wrapper'
require 'unenviable/railtie' if defined?(Rails)

# Handles loading a YAML file that will describe what ENV variables
# are necessary for a twelve-factor app in a specific environment.
module Unenviable
  attr_writer :env_list

  def self.check
    load_env_descriptions unless @env_list
    Dotenv.load
    discrepancies = { required: [], optional: [], forbidden: [] }

    @env_list.each do |var, details|
      discrepancies[:required] << var if details[:required] && !ENV[var]
      discrepancies[:optional] << var if !details[:required] && !details[:forbidden] && !ENV[var]
      discrepancies[:forbidden] << var if details[:forbidden] && ENV[var]
    end

    discrepancies
  end

  def self.env_descriptions_file_location
    'config/unenviable.yml'
  end

  def self.env_descriptions=(env_list)
    @env_list = env_list
  end

  def self.install_wrapper
    wrapper = Unenviable::ENVWrapper.new
    Object.send(:remove_const, :ENV)
    Object.const_set(:ENV, wrapper)
  end

  def self.described?(key)
    @env_list.include?(key)
  end

  def self.generate
    File.open('.env', 'wb') do |f|
      generate_dotenv_lines.each { |l| f.write(l + "\n") }
    end
  end

  def self.generate_dotenv_lines
    load_env_descriptions unless @env_list
    lines = []
    @env_list.each do |var, details|
      lines << "# #{details[:description]}"
      lines << "#{var}=#{details[:initial_value]}" if details[:required]
      lines << "##{var}=#{details[:initial_value]}" unless details[:required]
      lines << ''
    end

    lines
  end

  private

  # Load the file that descriptions the required environment variables
  # this needn't be called directly, it's called lazily by the functions.
  def self.load_env_descriptions
    if File.file?(env_descriptions_file_location)
      @base_env_list = YAML.load(File.open(env_descriptions_file_location))
      @env_list = {}
      @base_env_list.each do |var, details|
        @env_list[var] = {}
        details.each { |k, v| @env_list[var][k.to_sym] = v }
      end
    else
      @env_list = {}
    end
  end
end
