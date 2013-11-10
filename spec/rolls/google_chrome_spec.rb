require 'spec_helper'
require 'google_chrome'

describe GoogleChrome do
  let(:roll) { GoogleChrome.new }

  before do
    stub_roll GoogleChrome
  end

  it 'should return a name' do
    expect(roll.title).to eq 'Google Chrome'
  end
end
