require 'spec_helper'

describe Yuyi::Rolls do
  describe Class do
    subject(:rolls) { Yuyi::Rolls }

    describe '#load' do
      before do
        rolls.stub(:load_from_menu)
        rolls.stub(:load_dependencies)
        rolls.stub(:present_options)
        rolls.stub(:order_rolls)
        rolls.load
      end

      it 'should call neccessary methods' do
        expect(rolls).to have_received :load_from_menu
        expect(rolls).to have_received :load_dependencies
        expect(rolls).to have_received :present_options
        expect(rolls).to have_received :order_rolls
      end
    end

    describe '#load_from_menu' do
      before do
        rolls.menu = { :load_from_menu_roll => nil }
        rolls.load_from_menu
      end

      it 'should add the roll to the class variable' do
        expect(rolls.class_var(:all_on_menu)[:load_from_menu_roll]).to eq(LoadFromMenuRoll)
      end
    end

    describe '#present_options' do
      before do
        class PresentOptionsRoll; end
        rolls.class_var :all_on_menu, { :present_options_roll => PresentOptionsRoll }
        Yuyi.stub(:present_options)
      end
    end

    describe '#load_dependencies' do
      before do
        class LoadDependenciesRoll; end
        LoadDependenciesRoll.stub(:add_dependencies)
        rolls.class_var :all_on_menu, {
          :load_dependencies_roll => LoadDependenciesRoll
        }
        rolls.load_dependencies
      end

      it 'should call add_dependencies for each dependency' do
        expect(LoadDependenciesRoll).to have_received(:add_dependencies)
      end
    end

    describe '#add_roll' do
      before do
        class AddRollRoll; end
        rolls.add_roll :add_roll_roll, AddRollRoll
      end

      it 'should add the roll to the class var' do
        expect(rolls.class_var(:all_on_menu)[:add_roll_roll]).to eq AddRollRoll
      end
    end

    describe '#tsorted_rolls' do
      before do
        # Needs a class with a dependencies method
        class TsortedRollsTest
          attr_accessor :dependencies
          def initialize dependencies
            @dependencies = dependencies
          end
        end

        rolls.class_var :all_on_menu, {
          :a => TsortedRollsTest.new([:b, :c]),
          :b => TsortedRollsTest.new([:c]),
          :c => TsortedRollsTest.new([]),
          :d => TsortedRollsTest.new([])
        }
      end

      it 'should tsort the rolls' do
        expect(rolls.tsorted_rolls).to eq [:c, :b, :a, :d]
      end
    end

    describe '#order_rolls' do
      before do
        class OrderRollsRoll; end
        OrderRollsRoll.stub(:new)
        rolls.class_var :all_on_menu, { :order_rolls_roll => OrderRollsRoll }
        rolls.stub(:tsorted_rolls).and_return([:order_rolls_roll])
        rolls.order_rolls
      end

      it 'should initialize each tsorted roll' do
        expect(OrderRollsRoll).to have_received(:new)
      end
    end

    describe '#on_the_menu?' do
      before do
        rolls.class_var(:all_on_menu, { :roll => 'Roll' })
      end

      it 'should return true if roll is on the menu' do
        expect(rolls.on_the_menu?(:roll)).to be_true
      end
    end
  end
end
