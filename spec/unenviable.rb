# encoding: utf-8
require 'spec_helper'

describe Unenviable do
  before :each do
  end

  after :each do
  end

  describe '#check' do
    it 'passes silently when no variables are specified' do
      expect(Unenviable.check).to eq([[], [], []])
    end
  end
end
