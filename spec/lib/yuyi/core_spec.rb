require 'spec_helper'

describe Hash do
  describe '.deep_symbolize_keys!' do
    before do
      @hash = {
        'foo' => 'bar',
        'nested_hash' => { 'nested_key' => 'nested_value'},
        'nested_array' => ['array_element']
      }

      @hash.deep_symbolize_keys!
    end

    it 'should recursively symbolize keys' do
      expect(@hash).to eq({
        :foo => 'bar',
        :nested_hash => { :nested_key => 'nested_value' },
        :nested_array => ['array_element']
      })
    end
  end

  describe '.deep_stringify_keys!' do
    before do
      @hash = {
        :foo => 'bar',
        :nested_hash => { :nested_key => 'nested_value' },
        :nested_array => ['array_element']
      }

      @hash.deep_stringify_keys!
    end

    it 'should recursively stringify keys' do
      expect(@hash).to eq({
        'foo' => 'bar',
        'nested_hash' => { 'nested_key' => 'nested_value'},
        'nested_array' => ['array_element']
      })
    end
  end
end
