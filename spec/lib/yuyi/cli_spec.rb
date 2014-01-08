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
        Yuyi::Menu.stub(:load)
        CliTest.stub(:get_menu)
        CliTest.start []
      end

      after do
        Yuyi::Menu.unstub(:load)
      end

      it 'should load rolls' do
        expect(Yuyi::Menu).to have_received(:load)
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

          # Test both option forms
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
    before do
      stub_const 'Yuyi::DEFAULT_ROLL_PATH', 'spec/fixtures/menu_load.yml'
      Yuyi::Roll.any_instance.stub(:installed?).and_return(true)
      Yuyi::Menu.any_instance.stub(:require_rolls)
      Yuyi::Menu.class_var :classes, {}
    end

    after do
      Yuyi::Roll.any_instance.unstub(:installed?)
      Yuyi::Menu.any_instance.unstub(:require_rolls)
      Readline.unstub(:readline)
    end

    after :each do
      Yuyi.send(:get_menu)
    end

    context 'when no input is given' do
      before do
        Readline.stub(:readline).and_return('')
      end

      it 'should load the default menu' do
        expect(Yuyi::Menu).to receive(:new).with(Yuyi::DEFAULT_ROLL_PATH).and_call_original
      end
    end

    context 'when an invalid path is given' do
      before do
        Readline.stub(:readline).and_return('foo', 'bar', '')
      end

      it 'should request input again' do
        expect(Readline).to receive(:readline).exactly(3).times
      end
    end

    context 'when a custom path is given' do
      before do
        Readline.stub(:readline).and_return('spec/fixtures/menu_load.yml')
      end

      it 'should load the menu' do
        expect(Yuyi::Menu).to receive(:new).with('spec/fixtures/menu_load.yml').and_call_original
      end
    end
  end

  describe '.write_to_file' do
    before do
      Yuyi.write_to_file 'test', 'foo'
    end

    after do
      FileUtils.rm 'test'
    end

    it 'should create a file if it doesnt exist' do
      expect(File.exists?('test')).to be_true
    end

    it 'should append to the file' do
      Yuyi.write_to_file 'test', 'bar'
      expect(File.open('test').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple text arguments' do
      Yuyi.write_to_file 'test', 'arg1', 'arg2'
      expect(File.open('test').read).to eq "foo\narg1\narg2\n"
    end
  end

  describe '.delete_from_file' do
    before do
      Yuyi.write_to_file 'test', 'foo', 'remove1', 'remove2', 'bar'
    end

    after do
      FileUtils.rm 'test'
    end

    it 'should remove a line from the file' do
      Yuyi.delete_from_file 'test', 'remove1'
      expect(File.open('test').read).to eq "foo\nremove2\nbar\n"
    end

    it 'should accept multiple text arguments' do
      Yuyi.delete_from_file 'test', 'remove1', 'remove2'
      expect(File.open('test').read).to eq "foo\nbar\n"
    end
  end

  describe '.command?' do
    it 'should return true if command exists' do
      expect(Yuyi.command?('ruby')).to eq true
      expect(Yuyi.command?('rubyfoo')).to eq false
    end
  end
end
