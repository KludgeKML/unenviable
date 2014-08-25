# encoding: utf-8
require 'yaml'

module Unenviable
  def self.check
    load_env_descriptions unless @env_list
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
