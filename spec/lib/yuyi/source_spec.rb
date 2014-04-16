require 'spec_helper'

describe Yuyi::Source do
  shared_examples 'a source' do
    before do
      @url = File.expand_path(File.join(File.dirname(__FILE__), "../../fixtures/#{source}"))
      @source = Yuyi::Source.new @name, @url
    end

    it 'should set the root tmp dir' do
      expect(Yuyi::Source.var(:root_tmp_dir)).to_not be_nil
    end

    it 'should set the instance vars' do
      expect(@source.var(:name)).to eq @name
      expect(@source.var(:url)).to eq @url
      expect(@source.var(:tmp_dir)).to include Yuyi::Source.var(:root_tmp_dir)
      expect(@source.var(:tmp_dir)).to include @name.to_s
    end

    it 'should put roll files in the tmp dir' do
      paths = @source.var(:available_rolls).values.map{ |r| r[:require_path]}

      expect(paths.size).to eq 2

      paths.each do |path|
        expect(File.exists?(File.join(Yuyi::Source.var(:root_tmp_dir), "#{path}.rb"))).to be_true
      end
    end

    it 'should set the available rolls' do
      expect(@source.var(:available_rolls).keys).to include :foo_roll
    end
  end

  context 'with a compressed file' do
    let(:source){ 'roll_zip.zip' }
    before do
      @name = :compressed_source
    end

    it_behaves_like 'a source'
  end

  context 'with a directory' do
    let(:source){ 'roll_dir' }

    before do
      @name = :directory_source
    end

    it_behaves_like 'a source'
  end
end
