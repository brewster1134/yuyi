require 'spec_helper'

describe Array do
end

describe Hash do
  describe '.deep_symbolize_keys!' do
    let(:hash) {{ 'foo' => 'bar', 'nested' => { 'nestedkey' => 'nestedvalue' }}}

    before do
      hash.deep_symbolize_keys!
    end

    it 'should recursively symbolize keys' do
      expect(hash).to eq({ :foo => 'bar', :nested => { :nestedkey => 'nestedvalue' }})
    end
  end
end
