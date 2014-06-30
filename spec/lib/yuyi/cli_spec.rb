require 'spec_helper'

options = Yuyi::Cli::CLI_OPTIONS.keys

describe Yuyi::Cli do
  before do
    class CliTest; extend Yuyi::Cli; end
    allow(CliTest).to receive(:say)
    CliTest.send(:instance_variable_set, :'@path', nil)
  end

  describe 'CLI_OPTIONS' do
    it 'should have options with a unique first character' do
      flags = options.map{ |option| option.to_s.chars.first }

      expect(flags.uniq.length).to eq options.length
    end
  end

  describe '#init' do
    context 'without arguments' do
      before do
        allow(CliTest).to receive :start
        CliTest.init []
      end

      it 'should call start' do
        expect(CliTest).to have_received(:start)
      end
    end

    context 'with an invalid argument' do
      before do
        allow(CliTest).to receive :help
        CliTest.init '-foo'
      end

      it 'should call the help method' do
        expect(CliTest).to have_received(:help)
      end
    end

    context 'with the respective argument' do
      options.each do |option|
        before do
          allow(CliTest).to receive option.to_s.downcase.to_sym

          # Test both option forms
          CliTest.init "-#{option.to_s.chars.first}"
          CliTest.init "--#{option}"
        end

        the "#{option} option is valid" do
          expect(CliTest).to have_received(option.to_s.downcase.to_sym).twice
        end
      end
    end

    context 'with a menu path' do
      before do
        allow(CliTest).to receive :start
        CliTest.init 'foo_path'
      end

      it 'should set the path' do
        expect(CliTest.instance_var(:path)).to eq 'foo_path'
      end
    end
  end

  describe '#say' do
    before do
      allow(CliTest).to receive(:say).and_call_original
      allow(STDOUT).to receive(:puts)
    end

    after do
      allow(STDOUT).to receive(:puts).and_call_original
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
      allow(CliTest).to receive(:say)
      allow(STDIN).to receive(:gets).and_return 'foo'
    end

    after do
      allow(STDIN).to receive(:gets).and_call_original
    end

    it 'should pass the user input to the block' do
      CliTest.ask 'why?' do |response|
        expect(response).to eq 'foo'
      end
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

  describe '#write_to_file' do
    after do
      FileUtils.rm Dir.glob('write_to_file*')
    end

    it 'should create a file if it doesnt exist' do
      CliTest.write_to_file 'write_to_file_create', 'foo'

      expect(File.exists?('write_to_file_create')).to be true
    end

    it 'should append to the file' do
      CliTest.write_to_file 'write_to_file_append', 'foo'
      CliTest.write_to_file 'write_to_file_append', 'bar'

      expect(File.open('write_to_file_append').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple string arguments' do
      CliTest.write_to_file 'write_to_file_strings', 'line 1', 'line 2'

      expect(File.open('write_to_file_strings').read).to eq "line 1\nline 2\n"
    end

    it 'should accept an array argument' do
      CliTest.write_to_file 'write_to_file_array', ['line 1', 'line 2']

      expect(File.open('write_to_file_array').read).to eq "line 1\nline 2\n"
    end

    it 'should not add a line if it already exists' do
      CliTest.write_to_file 'write_to_file_exists', 'foo'
      CliTest.write_to_file 'write_to_file_exists', 'foo'

      expect(File.open('write_to_file_exists').read).to eq "foo\n"
    end
  end

  describe '#delete_from_file' do
    after do
      FileUtils.rm Dir.glob('delete_from_file*')
    end

    it 'should remove a line from the file' do
      CliTest.write_to_file 'delete_from_file', 'foo', 'remove', 'bar'
      CliTest.delete_from_file 'delete_from_file', 'remove'

      expect(File.open('delete_from_file').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple string arguments' do
      CliTest.write_to_file 'delete_from_file_strings', 'foo', 'remove 1', 'remove 2', 'bar'
      CliTest.delete_from_file 'delete_from_file_strings', 'remove 1', 'remove 2'

      expect(File.open('delete_from_file_strings').read).to eq "foo\nbar\n"
    end

    it 'should accept an array argument' do
      CliTest.write_to_file 'delete_from_file_array', 'foo', 'remove 1', 'remove 2', 'bar'
      CliTest.delete_from_file 'delete_from_file_array', ['remove 1', 'remove 2']

      expect(File.open('delete_from_file_array').read).to eq "foo\nbar\n"
    end
  end

  describe '#osx_version' do
    it 'should return a float' do
      expect(CliTest.osx_version).to be_a Float
    end
  end

  describe '#get_menu' do
    before do
      stub_const 'Yuyi::DEFAULT_MENU', 'spec/fixtures/menu.yaml'
      allow(Yuyi::Menu).to receive(:new)
      allow(Yuyi::Menu).to receive(:load_from_file)
    end

    after do
      CliTest.send :get_menu
      allow(Readline).to receive(:readline).and_call_original
      allow(Yuyi::Menu).to receive(:new).and_call_original
      allow(Yuyi::Menu).to receive(:load_from_file).and_call_original
    end

    context 'when no input is given' do
      before do
        allow(Readline).to receive(:readline).and_return('')
        allow(Yuyi::Menu).to receive(:load_from_file).and_return(true)
      end

      it 'should load the default menu' do
        expect(Yuyi::Menu).to receive(:load_from_file).with('spec/fixtures/menu.yaml')
      end
    end

    context 'when an invalid path is given' do
      before do
        allow(Readline).to receive(:readline).and_return('foo', 'bar', '')
        allow(Yuyi::Menu).to receive(:load_from_file).and_return(false, false, true)
      end

      it 'should request input again' do
        expect(Yuyi::Menu).to receive(:load_from_file).exactly(3).times
      end
    end

    context 'when a custom path is given' do
      before do
        allow(Readline).to receive(:readline).and_return('spec/fixtures/menu.yaml')
        allow(Yuyi::Menu).to receive(:load_from_file).and_return(true)
      end

      it 'should load the menu' do
        expect(Yuyi::Menu).to receive(:load_from_file).with('spec/fixtures/menu.yaml')
      end
    end
  end

  describe '#present_options' do
    before do
      @output = ''
      allow(CliTest).to receive :say do |o, p|
        @output << (o || '')
      end

      class PresentOptionsRoll; end
      allow(PresentOptionsRoll).to receive(:title).and_return 'Present Options Roll'
      allow(PresentOptionsRoll).to receive(:file_name).and_return :present_options_roll
      allow(PresentOptionsRoll).to receive(:options).and_return({ :option_foo => '3.0' })
      allow(PresentOptionsRoll).to receive(:option_defs).and_return({
        :option_foo => {
          :description => 'foo description',
          :example => '1.0',
          :default => '2.0'
        }
      })

      CliTest.send :present_options, PresentOptionsRoll
    end

    it 'should output the neccessary information' do
      expect(@output).to include 'Present Options Roll'
      expect(@output).to include 'present_options_roll'
      expect(@output).to include 'foo description'
      expect(@output).to include '1.0'
      expect(@output).to include '2.0'
    end
  end

  # Argument Methods
  #
  describe '#help' do
    before do
      stub_const 'Yuyi::Cli::CLI_OPTIONS', {
        :FOO => 'doo',
        :bar => 'boo'
      }

      @output = ''
      allow(CliTest).to receive :say do |o, p|
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
      class ListRollSource; end
      allow(ListRollSource).to receive(:available_rolls).and_return({ :list_roll => nil })

      allow(CliTest).to receive :get_menu
      allow(Yuyi::Menu).to receive :set_sources
      allow(Yuyi::Menu).to receive(:sources).and_return([ ListRollSource ])

      @output = ''
      allow(CliTest).to receive :say do |o, p|
        @output << (o || '')
      end

      CliTest.send :list
    end

    after do
      allow(Yuyi::Menu).to receive(:set_sources).and_call_original
    end

    it 'should return all rolls' do
      expect(@output).to include 'list_roll'
    end
  end
end
