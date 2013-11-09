require 'spec_helper'
require 'google_chrome'

describe GoogleChrome do
  let(:roll) { GoogleChrome.new }

  it 'should return a name' do
    expect(roll.title).to eq 'Google Chrome'
  end
end
