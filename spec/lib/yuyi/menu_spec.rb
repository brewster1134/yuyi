require 'spec_helper'

describe Yuyi::Menu do
  describe '.initialize' do
    let(:menu) { Yuyi::Menu.new }

    before do
      Yuyi::Menu.stub(:load).and_return({:menu => 'foo'})
      Yuyi::Menu.any_instance.stub(:require_rolls)
      Yuyi::Menu.any_instance.stub(:present_options)
    end

    after do
      Yuyi::Menu.unstub(:load)
      Yuyi::Menu.any_instance.unstub(:require_rolls)
      Yuyi::Menu.any_instance.unstub(:present_options)
    end

    it 'should set the object class var' do
      expect(menu.class.class_var(:object)).to eq({:menu => 'foo'})
    end

    it 'should call other methods' do
      expect(menu).to have_received(:require_rolls)
      expect(menu).to have_received(:present_options)
    end

    context 'when no path is specified' do
      it 'should call .load with the default path' do
        expect(menu.class.path).to eq Yuyi::DEFAULT_ROLL_PATH
      end
    end

    context 'when a path is specified' do
      let(:menu) { Yuyi::Menu.new 'foo' }

      it 'should call .load with the custom path' do
        expect(menu.class.path).to eq('foo')
      end
    end
  end

  describe 'self.load' do
    context 'when path is invalid' do
      before do
        Yuyi::Menu.class_var :path, 'foo'
      end

      it 'should have a nil object' do
        expect(Yuyi::Menu.load).to be_nil
      end
    end

    context 'when path is valid' do
      before do
        Yuyi::Menu.class_var :path, 'spec/fixtures/menu_load.yml'
      end

      it 'should set object with symbolized keys' do
        expect(Yuyi::Menu.load).to eq({ :menu_load => { :foo => 'bar' }})
      end
    end
  end

  describe 'self.on_the_menu?' do
    before do
      Yuyi::Menu.class_var :classes, { :foo => 'bar' }
    end

    it 'should return true if on the menu' do
      expect(Yuyi::Menu.on_the_menu?(:foo)).to be_true
    end
  end

  describe 'self.add_roll' do
    before do
      class MenuAddRollRoll; end
      Yuyi::Menu.add_roll :menu_add_roll_roll, MenuAddRollRoll
    end

    it 'should add the roll to the class var' do
      expect(Yuyi::Menu.class_var(:classes)[:menu_add_roll_roll]).to eq MenuAddRollRoll
    end
  end

  describe 'self.sorted' do
    before do
      class DependencyRoll < Yuyi::Roll
        def self.dependencies; [:foo, :bar]; end
      end
      class EmptyDependencyRoll
        def self.dependencies; []; end
      end
      Yuyi::Menu.class_var :classes, { :dependency_roll => DependencyRoll, :foo => EmptyDependencyRoll, :bar => EmptyDependencyRoll }
    end

    it 'should add the roll to the class var' do
      expect(Yuyi::Menu.sorted.sort_by {|sym| sym.to_s}).to eq([:foo, :bar, :dependency_roll].sort_by {|sym| sym.to_s})
    end
  end
end
