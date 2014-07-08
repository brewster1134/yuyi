require 'spec_helper'
require 'yuyi/cli'

describe Yuyi::Cli do
  # Argument Methods
  #
  describe '#list' do
    before do
      allow(Yuyi::Menu).to receive :new
      allow(Yuyi::Menu).to receive(:sources).and_return([
        OpenStruct.new({ :rolls => { :foo => {}}}),
        OpenStruct.new({ :rolls => { :bar => {}}})
      ])

      @output = ''
      allow(Yuyi).to receive :say do |o, p|
        @output << (o || '')
      end

      Yuyi::Cli.new.send :list
    end

    after do
      allow(Yuyi::Menu).to receive(:new).and_call_original
      allow(Yuyi::Menu).to receive(:set_sources).and_call_original
    end

    it 'should return all rolls alphabetically' do
      expect(@output).to include "barfoo"
    end
  end
end
