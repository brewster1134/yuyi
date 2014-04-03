require 'spec_helper'

options = Yuyi::Cli::OPTIONS.keys

describe Yuyi::Cli do
  before do
    class CliTest; extend Yuyi::Cli; end
    CliTest.stub(:say)
  end

  describe 'OPTIONS' do
    it 'should have options with a unique first character' do
      flags = options.map{ |option| option.to_s.chars.first }

      expect(flags.uniq.length).to eq options.length
    end
  end

  describe '#init' do
    context 'without arguments' do
      before do
        CliTest.stub :start
        CliTest.init []
      end

      it 'should call start' do
        expect(CliTest).to have_received(:start)
      end
    end

    context 'with an invalid argument' do
      before do
        CliTest.stub :help
        CliTest.init 'foo'
      end

      it 'should call the help method' do
        expect(CliTest).to have_received(:help)
      end
    end

    context 'with the respective argument' do
      options.each do |option|
        before do
          CliTest.stub option.to_s.downcase.to_sym

          # Test both option forms
          CliTest.init "-#{option.to_s.chars.first}"
          CliTest.init "--#{option}"
        end

        the "#{option} option is valid" do
          expect(CliTest).to have_received(option.to_s.downcase.to_sym).twice
        end
      end
    end
  end

  describe '#say' do
    before do
      CliTest.stub(:say).and_call_original
      STDOUT.stub(:puts)
    end

    after do
      STDOUT.unstub(:puts)
    end

    it 'should output the correct type' do
      expect(STDOUT).to receive(:puts).with("\e[31mfoo type\e[0m")
      CliTest.say 'foo type', :type => :fail
    end

    it 'should output the correct color' do
      expect(STDOUT).to receive(:puts).with("\e[123mfoo color\e[0m")
      CliTest.say 'foo color', :color => 123
    end

    it 'should output the correct justification & padding' do
      expect(STDOUT).to receive(:puts).with(' foo justify padding  ')
      CliTest.say 'foo justify padding', :justify => :center, :padding => 22
    end

    it 'should output the correct indentation' do
      expect(STDOUT).to receive(:puts).with('  foo indent')
      CliTest.say 'foo indent', :indent => 2
    end
  end

  describe '#ask' do
    before do
      CliTest.stub(:say)
      STDIN.stub(:gets).and_return 'foo'
    end

    after do
      STDIN.unstub(:gets)
    end

    it 'should pass the user input to the block' do
      CliTest.ask 'why?' do |response|
        expect(response).to eq 'foo'
      end
    end
  end

  describe '#present_options' do
    before do
      @output = ''
      CliTest.stub :say do |o, p|
        @output << (o || '')
      end

      class PresentOptionsRoll
        def title; :foo_title; end
        def file_name; :foo_filename; end
        def options
          {
            :option_foo => {
              :description => 'foo description',
              :example => '1.0',
              :default => '2.0',
              :required => true
            }
          }
        end
      end
      @present_options_roll = PresentOptionsRoll.new

      CliTest.present_options @present_options_roll
    end

    it 'should output the neccessary information' do
      expect(@output).to include 'foo_title'
      expect(@output).to include 'foo_filename'
      expect(@output).to include 'foo description'
      expect(@output).to include '1.0'
      expect(@output).to include '2.0'
      expect(@output).to include "\e[31m" # make sure something is red (required)
    end
  end

  describe '#write_to_file' do
    before do
      CliTest.write_to_file 'test', 'foo'
    end

    after do
      FileUtils.rm 'test'
    end

    it 'should create a file if it doesnt exist' do
      expect(File.exists?('test')).to be_true
    end

    it 'should append to the file' do
      CliTest.write_to_file 'test', 'bar'
      expect(File.open('test').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple text arguments' do
      CliTest.write_to_file 'test', 'arg1', 'arg2'
      expect(File.open('test').read).to eq "foo\narg1\narg2\n"
    end
  end

  describe '#delete_from_file' do
    before do
      CliTest.write_to_file 'test', 'foo', 'remove1', 'remove2', 'bar'
    end

    after do
      FileUtils.rm 'test'
    end

    it 'should remove a line from the file' do
      CliTest.delete_from_file 'test', 'remove1'
      expect(File.open('test').read).to eq "foo\nremove2\nbar\n"
    end

    it 'should accept multiple text arguments' do
      CliTest.delete_from_file 'test', 'remove1', 'remove2'
      expect(File.open('test').read).to eq "foo\nbar\n"
    end
  end

  describe '#command?' do
    it 'should return true if command exists' do
      expect(CliTest.command?('ruby -v')).to eq true
    end

    it 'should return false if command does not exist' do
      expect(CliTest.command?('rubyfoo')).to eq false
    end
  end

  describe '#get_menu' do
    before do
      stub_const 'Yuyi::DEFAULT_MENU', 'spec/fixtures/menu.yaml'
    end

    after do
      CliTest.send(:get_menu)
      Readline.unstub(:readline)
      Yuyi::Menu.unstub(:new)
    end

    context 'when no input is given' do
      before do
        Readline.stub(:readline).and_return('')
        Yuyi::Menu.stub(:new).and_return(true)
      end

      it 'should load the default menu' do
        expect(Yuyi::Menu).to receive(:new).with('spec/fixtures/menu.yaml')
      end
    end

    context 'when an invalid path is given' do
      before do
        Readline.stub(:readline).and_return('foo', 'bar', '')
        Yuyi::Menu.stub(:new).and_return(false, false, true)
      end

      it 'should request input again' do
        expect(Readline).to receive(:readline).exactly(3).times
      end
    end

    context 'when a custom path is given' do
      before do
        Readline.stub(:readline).and_return('spec/fixtures/menu.yaml')
        Yuyi::Menu.stub(:new).and_return(true)
      end

      it 'should load the menu' do
        expect(Yuyi::Menu).to receive(:new).with('spec/fixtures/menu.yaml')
      end
    end
  end

  # argument methods
  #
  describe '#help' do
    before do
      stub_const 'Yuyi::Cli::OPTIONS', {
        :FOO => 'doo',
        :bar => 'boo'
      }

      @output = ''
      CliTest.stub :say do |o, p|
        @output << (o || '')
      end

      CliTest.send :help
    end

    it 'should return options' do
      expect(@output).to include '-F'
      expect(@output).to include '--FOO'
      expect(@output).to include 'doo'
      expect(@output).to include '-b'
      expect(@output).to include '--bar'
      expect(@output).to include 'boo'
    end
  end

  describe '#list' do
    before do
      @output = ''
      CliTest.stub :say do |o, p|
        @output << (o || '')
      end

      Readline.stub(:readline).and_return 'spec/fixtures/menu.yaml'

      CliTest.send :list
    end

    after do
      Readline.unstub(:readline)
    end

    it 'should return all rolls' do
      expect(@output).to include 'foo_roll'
    end
  end
end
