# encoding: utf-8
require 'spec_helper'

# Mock the default yml file
module Unenviable
  def self.env_descriptions_file_location
    'tmp/unenviable_test/unenviable.yml'
  end
end

describe Unenviable do
  before :each do
    Dir.mkdir File.join('', 'tmp', 'unenviable_test')
    @config_dir = Dir.new File.join('', 'tmp', 'unenviable_test')
  end

  after :each do
    @config_dir.each { |f| f.unlink unless f == '.' || f == '..' }
    Dir.unlink @config_dir
  end

  describe '.check' do
    it 'passes silently when no variables are specified' do
      expect(Unenviable.check).to eq(required: [], optional: [], forbidden: [])
    end

    it 'passes silently when required variables are in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test', required: true } }
      ENV['VALID_VAR'] = 'TRUE'
      expect(Unenviable.check).to eq(required: [], optional: [], forbidden: [])
    end

    it 'returns missing list when required variables are not in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test', required: true } }
      ENV.delete 'VALID_VAR'
      expect(Unenviable.check).to eq(required: ['VALID_VAR'], optional: [], forbidden: [])
    end

    it 'passes silently when optional variables are in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test' } }
      ENV['VALID_VAR'] = 'TRUE'
      expect(Unenviable.check).to eq(required: [], optional: [], forbidden: [])
    end

    it 'returns optional list when optional variables are not in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test' } }
      ENV.delete 'VALID_VAR'
      expect(Unenviable.check).to eq(required: [], optional: ['VALID_VAR'], forbidden: [])
    end

    it 'passes silently when forbidden variables are not in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test', forbidden: true } }
      ENV.delete 'VALID_VAR'
      expect(Unenviable.check).to eq(required: [], optional: [], forbidden: [])
    end

    it 'returns forbidden list when forbidden variables are in the environment' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test', forbidden: true } }
      ENV['VALID_VAR'] = 'TRUE'
      expect(Unenviable.check).to eq(required: [], optional: [], forbidden: ['VALID_VAR'])
    end
  end

  describe '::install_wrapper' do
    it 'installs the ENV wrapper, then complains when an unspecified variable is read' do
      Unenviable.env_descriptions = {}
      Unenviable.install_wrapper
      expect { _var = ENV['VALID_VAR'] }.to raise_error(RuntimeError)
    end

    it 'installs the ENV wrapper, then doesn\'t complain when a specified variable is read' do
      Unenviable.env_descriptions = { 'VALID_VAR' => { description: 'test' } }
      Unenviable.install_wrapper
      expect { _var = ENV['VALID_VAR'] }.to_not raise_error
    end
  end

  describe '::generate_dotenv_lines' do
    it 'makes a commented-out env string for an optional var' do
      description = 'This variable is optional'
      name = 'VALID_VAR'
      Unenviable.env_descriptions = { name => { description: description, required: false } }
      lines = Unenviable.generate_dotenv_lines
      expect(lines[0]).to eq("# #{description}")
      expect(lines[1]).to eq("##{name}=")
    end

    it 'makes an env string for an required var' do
      description = 'This variable is optional'
      name = 'VALID_VAR'
      Unenviable.env_descriptions = { name => { description: description, required: true } }
      lines = Unenviable.generate_dotenv_lines
      expect(lines[0]).to eq("# #{description}")
      expect(lines[1]).to eq("#{name}=")
    end

    it 'makes a commented-out env string for an required var with a default value' do
      description = 'This variable is optional'
      name = 'VALID_VAR'
      value = 'my value'
      Unenviable.env_descriptions = { name => { description: description, required: false, initial_value: value } }
      lines = Unenviable.generate_dotenv_lines
      expect(lines[0]).to eq("# #{description}")
      expect(lines[1]).to eq("##{name}=#{value}")
    end

    it 'makes an env string for an required var with a default value' do
      description = 'This variable is optional'
      name = 'VALID_VAR'
      value = 'my value'
      Unenviable.env_descriptions = { name => { description: description, required: true, initial_value: value } }
      lines = Unenviable.generate_dotenv_lines
      expect(lines[0]).to eq("# #{description}")
      expect(lines[1]).to eq("#{name}=#{value}")
    end
  end
end
