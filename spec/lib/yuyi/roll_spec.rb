require 'spec_helper'

describe Yuyi::Roll do
  describe '.dependencies' do
    before do
      allow(Yuyi::Menu).to receive(:find_roll)
    end

    after do
      allow(Yuyi::Menu).to receive(:find_roll).and_call_original
    end

    it 'should call find dependency rolls' do
      expect(Yuyi::Menu).to receive(:find_roll).with :foo
      expect(Yuyi::Menu).to receive(:find_roll).with :bar
      Yuyi::Roll.dependencies :foo, :bar
    end
  end

  describe '.class_to_title' do
    it 'should render a title' do
      expect(Yuyi::Roll.class_to_title('Yuyi::RollModel::FooBar')).to eq 'Foo Bar'
    end
  end

  describe '.caller_to_file_name' do
    it 'should render a file name' do
      expect(Yuyi::Roll.caller_to_file_name(['/foo/bar/foo_bar.rb'])).to eq :foo_bar
    end
  end

  context 'when inherited' do
    before do
      allow(Yuyi::Menu).to receive(:add_roll)
    end

    after do
      allow(Yuyi::Menu).to receive(:add_roll).and_call_original
    end

    it 'should add the roll to the menu' do
      class RollSpecInheritedRoll < Yuyi::Roll; end
      expect(Yuyi::Menu).to have_received(:add_roll).with :roll_spec, RollSpecInheritedRoll
    end

    it 'should respond to title' do
      class RollSpecTitle < Yuyi::Roll; end
      expect(RollSpecTitle.title).to eq  'Roll Spec Title'
    end

    it 'should respond to file_name' do
      class RollSpecFileName < Yuyi::Roll; end
      expect(RollSpecFileName.file_name).to eq  :roll_spec
    end
  end

  describe 'instance' do
    before do
      allow(Yuyi::Menu).to receive(:add_roll)
      allow(Yuyi::Menu).to receive(:find_roll)

      class RollSpecInstance < Yuyi::Roll
        dependencies :foo, :bar
        installed? { false }
        pre_install { 'Pre Install' }
      end

      @roll = RollSpecInstance.new
    end

    after do
      allow(Yuyi::Menu).to receive(:add_roll).and_call_original
      allow(Yuyi::Menu).to receive(:find_roll).and_call_original
    end

    it 'should respond to pre_install' do
      expect(@roll.pre_install).to eq 'Pre Install'
    end

    it 'should respond to dependencies' do
      expect(@roll.dependencies).to eq [ :foo, :bar ]
    end
  end

  describe '#command?' do
    it 'should return true if command exists' do
      expect(DslTest.command?('ruby -v')).to eq true
    end

    it 'should return false if command does not exist' do
      expect(DslTest.command?('rubyfoo')).to eq false
    end
  end

  describe '#write_to_file' do
    after do
      FileUtils.rm Dir.glob('write_to_file*')
    end

    it 'should create a file if it doesnt exist' do
      DslTest.write_to_file 'write_to_file_create', 'foo'

      expect(File.exists?('write_to_file_create')).to be true
    end

    it 'should append to the file' do
      DslTest.write_to_file 'write_to_file_append', 'foo'
      DslTest.write_to_file 'write_to_file_append', 'bar'

      expect(File.open('write_to_file_append').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple string arguments' do
      DslTest.write_to_file 'write_to_file_strings', 'line 1', 'line 2'

      expect(File.open('write_to_file_strings').read).to eq "line 1\nline 2\n"
    end

    it 'should accept an array argument' do
      DslTest.write_to_file 'write_to_file_array', ['line 1', 'line 2']

      expect(File.open('write_to_file_array').read).to eq "line 1\nline 2\n"
    end

    it 'should not add a line if it already exists' do
      DslTest.write_to_file 'write_to_file_exists', 'foo'
      DslTest.write_to_file 'write_to_file_exists', 'foo'

      expect(File.open('write_to_file_exists').read).to eq "foo\n"
    end
  end

  describe '#delete_from_file' do
    after do
      FileUtils.rm Dir.glob('delete_from_file*')
    end

    it 'should remove a line from the file' do
      DslTest.write_to_file 'delete_from_file', 'foo', 'remove', 'bar'
      DslTest.delete_from_file 'delete_from_file', 'remove'

      expect(File.open('delete_from_file').read).to eq "foo\nbar\n"
    end

    it 'should accept multiple string arguments' do
      DslTest.write_to_file 'delete_from_file_strings', 'foo', 'remove 1', 'remove 2', 'bar'
      DslTest.delete_from_file 'delete_from_file_strings', 'remove 1', 'remove 2'

      expect(File.open('delete_from_file_strings').read).to eq "foo\nbar\n"
    end

    it 'should accept an array argument' do
      DslTest.write_to_file 'delete_from_file_array', 'foo', 'remove 1', 'remove 2', 'bar'
      DslTest.delete_from_file 'delete_from_file_array', ['remove 1', 'remove 2']

      expect(File.open('delete_from_file_array').read).to eq "foo\nbar\n"
    end
  end
end
