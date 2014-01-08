require 'spec_helper'

describe Yuyi::Config do
  before do
    class ConfigTestClass
      include Yuyi::Config
    end
  end

  it 'should return meta info' do
    expect(ConfigTestClass::NAME).to_not be_nil
    expect(ConfigTestClass::VERSION).to_not be_nil
    expect(ConfigTestClass::ROOT_DIR).to_not be_nil
    expect(ConfigTestClass::DEFAULT_ROLL_PATH).to_not be_nil
    expect(ConfigTestClass::ROLLS_DIR).to_not be_nil
  end

  it 'should hadd rolls directory to load path' do
    expect($:).to include ConfigTestClass::ROLLS_DIR
  end
end
