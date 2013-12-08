require 'spec_helper'

describe Yuyi::Rolls do
  describe Class do
    describe '.load' do
      before do
        Yuyi::Rolls.stub(:load_from_menu)
        Yuyi::Rolls.stub(:load_dependencies)
        Yuyi::Rolls.stub(:present_options)
        Yuyi::Rolls.stub(:order_rolls)
        Yuyi::Rolls.load
      end

      after do
        Yuyi::Rolls.unstub(:load_from_menu)
        Yuyi::Rolls.unstub(:load_dependencies)
        Yuyi::Rolls.unstub(:present_options)
        Yuyi::Rolls.unstub(:order_rolls)
      end

      it 'should call neccessary methods' do
        expect(Yuyi::Rolls).to have_received :load_from_menu
        expect(Yuyi::Rolls).to have_received :load_dependencies
        expect(Yuyi::Rolls).to have_received :present_options
        expect(Yuyi::Rolls).to have_received :order_rolls
      end
    end

    describe '.load_from_menu' do
      before do
        Yuyi::Menu.class_var :object, { :load_from_menu_roll => nil }
        Yuyi::Rolls.load_from_menu
      end

      it 'should add the roll to the class variable' do
        expect(Yuyi::Rolls.class_var(:all_on_menu)[:load_from_menu_roll]).to eq(LoadFromMenuRoll)
      end
    end

    describe '.load_dependencies' do
      before do
        class LoadDependenciesRoll; end
        LoadDependenciesRoll.stub(:add_dependencies)
        Yuyi::Rolls.class_var :all_on_menu, {
          :load_dependencies_roll => LoadDependenciesRoll
        }
        Yuyi::Rolls.load_dependencies
      end

      it 'should call add_dependencies for each dependency' do
        expect(LoadDependenciesRoll).to have_received(:add_dependencies)
      end
    end

    describe '.add_roll' do
      before do
        class AddRollRoll; end
        Yuyi::Rolls.add_roll :add_roll_roll, AddRollRoll
      end

      it 'should add the roll to the class var' do
        expect(Yuyi::Rolls.class_var(:all_on_menu)[:add_roll_roll]).to eq AddRollRoll
      end
    end

    describe '.tsorted_rolls' do
      before do
        # Needs a class with a dependencies method
        class TsortedRollsTest
          attr_accessor :dependencies
          def initialize dependencies
            @dependencies = dependencies
          end
        end

        Yuyi::Rolls.class_var :all_on_menu, {
          :a => TsortedRollsTest.new([:b, :c]),
          :b => TsortedRollsTest.new([:c]),
          :c => TsortedRollsTest.new([]),
          :d => TsortedRollsTest.new([])
        }
      end

      it 'should tsort the rolls' do
        expect(Yuyi::Rolls.tsorted_rolls).to eq [:c, :b, :a, :d]
      end
    end

    describe '.order_rolls' do
      before do
        class OrderRollsRoll; end
        OrderRollsRoll.stub(:new)
        Yuyi::Rolls.class_var :all_on_menu, { :order_rolls_roll => OrderRollsRoll }
        Yuyi::Rolls.stub(:tsorted_rolls).and_return([:order_rolls_roll])
        Yuyi::Rolls.order_rolls
      end

      after do
        Yuyi::Rolls.unstub(:tsorted_rolls)
      end

      it 'should initialize each tsorted roll' do
        expect(OrderRollsRoll).to have_received(:new)
      end
    end

    describe '.on_the_menu?' do
      before do
        Yuyi::Rolls.class_var(:all_on_menu, { :roll => 'Roll' })
      end

      it 'should return true if roll is on the menu' do
        expect(Yuyi::Rolls.on_the_menu?(:roll)).to be_true
      end
    end
  end
end
