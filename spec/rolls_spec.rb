require 'spec_helper'

describe Yuyi::Rolls do
  describe Class do
    subject(:rolls) { Yuyi::Rolls }

    describe '#load' do
      before do
        rolls.stub(:load_from_menu)
        rolls.stub(:order_rolls)
        rolls.load
      end

      it 'should call neccessary methods' do
        expect(rolls).to have_received :load_from_menu
        expect(rolls).to have_received :order_rolls
      end
    end

    describe '#load_from_menu' do
      before do
        rolls.menu = ['test_roll']
        rolls.load_from_menu
      end

      it 'should add the roll to the class variable' do
        expect(rolls.class_var(:all_on_menu)['test_roll']).to eq(TestRoll)
      end

      it 'should add the dependent rolls to the class variable' do
        expect(rolls.class_var(:all_on_menu)['test_dependent_roll']).to eq(TestDependentRoll)
      end
    end

    describe '#add_roll' do
      before do
        rolls.add_roll 'foo', 'Foo'
      end

      it 'should add the roll to the class var' do
        expect(rolls.class_var(:all_on_menu)['foo']).to eq 'Foo'
      end
    end

    describe '#tsorted_rolls' do
      before do
        # Needs a class with a dependencies method
        class TsortTest
          def initialize dependencies
            @dependencies = dependencies
          end
          def dependencies; @dependencies; end
        end

        rolls.class_var :all_on_menu, {
          1 => TsortTest.new([2, 3]),
          2 => TsortTest.new([3]),
          3 => TsortTest.new([]),
          4 => TsortTest.new([])
        }

        @tsorted_rolls = rolls.tsorted_rolls
      end

      it 'should tsort the rolls' do
        expect(@tsorted_rolls).to eq [3, 2, 1, 4]
      end
    end

    describe '#order_rolls' do
      before do
        class OrderRoll; end
        OrderRoll.stub(:new)
        subject.stub(:tsorted_rolls).and_return([:order_roll])
        rolls.class_var :all_on_menu, { :order_roll => OrderRoll}
        rolls.order_rolls
      end

      it 'should initialize each tsorted roll' do
        expect(OrderRoll).to have_received(:new)
      end
    end
  end
end
