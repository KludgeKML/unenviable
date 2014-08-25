# encoding: utf-8
require 'dotenv'
require 'yaml'

# Handles loading a YAML file that will describe what ENV variables
# are necessary for a twelve-factor app in a specific environment.
module Unenviable
  attr_writer @env_list

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

  def self.create_minimum_dotenv
    load_env_descriptions unless @env_list
    File.new('.env', 'wb') do |f|
      @env_list.each do |var, details|
        f.write("export #{var}=#{details['initial_value']}") if details[:required]
      end
    end
  end

  def self.env_descriptions_file_location
    'config/unenviable.yml'
  end

  def self.env_descriptions=(env_list)
    @env_list = env_list
  end

  private

  # Load the file that descriptions the required environment variables
  # this needn't be called directly, it's called lazily by the functions.
  def self.load_env_descriptions
    if File.file?(env_descriptions_file_location)
      @env_list = YAML.load(File.open(env_descriptions_file_location))
    else
      @env_list = {}
    end
  end
end
