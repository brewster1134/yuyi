require 'spec_helper'

describe Yuyi::Dsl do
  before do
    class DslTest; extend Yuyi::Dsl; end
  end

  describe '#say' do
    before do
      allow(STDOUT).to receive(:puts)
    end

    after do
      allow(STDOUT).to receive(:puts).and_call_original
    end

    it 'should output the correct justification & padding' do
      expect(STDOUT).to receive(:puts).with(' foo justify padding  ')
      DslTest.say 'foo justify padding', :justify => :center, :padding => 22
    end

    it 'should output the correct indentation' do
      expect(STDOUT).to receive(:puts).with('  foo indent')
      DslTest.say 'foo indent', :indent => 2
    end
  end

  describe '#ask' do
    before do
      allow(DslTest).to receive(:ask)
      allow(STDIN).to receive(:gets).and_return 'foo'
    end

    after do
      allow(STDIN).to receive(:gets).and_call_original
    end

    it 'should pass the user input to the block' do
      DslTest.ask 'why?' do |response|
        expect(response).to eq 'foo'
      end
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
