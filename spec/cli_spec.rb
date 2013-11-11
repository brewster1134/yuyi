require 'spec_helper'

options = Yuyi::Cli::OPTIONS.keys
option_flags = options.map{ |option| option.to_s.chars.first }

class CliTest
  extend Yuyi::Cli
end

describe Yuyi::Cli do
  before do
    CliTest.stub(:say)
  end

  describe 'OPTIONS' do
    it 'should have options with a unique first character' do
      expect(option_flags.uniq.length).to eq options.length
    end
  end

  describe '#start' do
    context 'without arguments' do
      before do
        Yuyi::Rolls.stub(:load)
        CliTest.start []
      end

      it 'should load rolls' do
        expect(Yuyi::Rolls).to have_received(:load)
      end
    end

    context 'with an invalid argument' do
      before do
        CliTest.stub :help
        CliTest.start 'foo'
      end

      it 'should call the help method' do
        expect(CliTest).to have_received(:help)
      end
    end

    context 'with arguments' do
      options.each do |option|
        before do
          CliTest.stub option
          CliTest.start "-#{option.to_s.chars.first}"
        end

        it "should call #{option} method" do
          expect(CliTest).to have_received(option)
        end
      end
    end
  end
end
