require 'spec_helper'

describe Yuyi::Source do
  before do
    @name = :foo_source
    @url = File.expand_path(File.join(File.dirname(__FILE__), '../../fixtures/foo_source.zip'))

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

  it 'should download the source file' do
    expect(File.exists?(File.join(@source.var(:tmp_dir), @name.to_s))).to be_true
  end

  it 'should unzip the source file to the root of the tmp dir' do
    expect(File.exists?(File.join(@source.var(:tmp_dir), 'foo_roll.rb'))).to be_true
  end

  it 'should set the available rolls' do
    expect(@source.var(:available_rolls).keys).to include :foo_roll
  end
end
