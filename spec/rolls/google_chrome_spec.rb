require 'spec_helper'
require 'google_chrome'

describe GoogleChrome do
  let(:roll) { GoogleChrome.new }

  before do
    stub_roll GoogleChrome
  end
end
