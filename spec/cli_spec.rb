require 'spec_helper'

options = Yuyi::Cli::OPTIONS.keys

describe Yuyi::Cli do
  let(:option_flags) { options.map{ |option| option.to_s.chars.first }}

  before do
    class CliTest; extend Yuyi::Cli; end
    CliTest.stub(:say)
  end

  describe 'OPTIONS' do
    it 'should have options with a unique first character' do
      expect(option_flags.uniq.length).to eq options.length
    end
  end

  describe '.start' do
    context 'without arguments' do
      before do
        Yuyi::Rolls.stub(:load)
        CliTest.stub(:get_menu)
        CliTest.start []
      end

      after do
        Yuyi::Rolls.unstub(:load)
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
          CliTest.start "--#{option}"
        end

        it "should call #{option} method" do
          expect(CliTest).to have_received(option).twice
        end
      end
    end
  end

  describe '.get_menu' do
    subject { CliTest }

    after do
      Readline.unstub(:readline)
    end

    context 'when no input is given' do
      before do
        Readline.stub(:readline).and_return('')
        subject.send(:get_menu)
      end

      it 'should load the default menu' do
        expect(Yuyi::Menu.path).to eq '~/Documents/menu.yml'
      end
    end

    context 'when an invalid path is given' do
      before do
        Readline.stub(:readline).and_return('foo', 'bar', '')
        subject.send(:get_menu)
      end

      it 'should request input again' do
        expect(Readline).to have_received(:readline).exactly(3).times
      end
    end

    context 'when a custom path is given' do
      before do
        Readline.stub(:readline).and_return('spec/fixtures/menu_load_path.yml')
        subject.send(:get_menu)
      end

      it 'should load the menu' do
        expect(Yuyi::Menu.path).to eq 'spec/fixtures/menu_load_path.yml'
      end
    end
  end
end
