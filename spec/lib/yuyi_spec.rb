require 'spec_helper'

describe Yuyi do
  describe '.set_verbose' do
    it 'should set and get the verbose boolean' do
      Yuyi.class_var :verbose, false
      Yuyi.set_verbose

      expect(Yuyi.verbose?).to eq true
    end
  end

  describe '.set_upgrade' do
    it 'should set and get the upgrade boolean' do
      Yuyi.class_var :upgrade, false
      Yuyi.set_upgrade

      expect(Yuyi.upgrade?).to eq true
    end
  end

  describe '.start' do
    it 'should initialize a menu' do
      expect(Yuyi::Menu).to receive(:new).with 'foo'
      expect(Yuyi::Menu).to receive(:order)

      Yuyi.start 'foo'

      allow(Yuyi::Menu).to receive(:new).and_call_original
      allow(Yuyi::Menu).to receive(:order).and_call_original
    end
  end
end
