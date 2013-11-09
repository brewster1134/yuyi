require 'spec_helper'

describe Yuyi::Rolls do
  describe Class do
    subject(:rolls) { Yuyi::Rolls }

    describe '#add_roll' do
      before do
        rolls.add_roll 'foo', 'Foo'
      end

      it 'should add the roll to the class var' do
        expect(rolls.all_on_menu['foo']).to eq 'Foo'
      end
    end

    describe '#tsorted_rolls' do
      before do
        load 'yuyi/rolls.rb'

        class TsortTest
          def initialize dependencies
            @dependencies = dependencies
          end
          def dependencies; @dependencies; end
        end

        rolls.add_roll 1, TsortTest.new([2, 3])
        rolls.add_roll 2, TsortTest.new([3])
        rolls.add_roll 3, TsortTest.new([])
        rolls.add_roll 4, TsortTest.new([])
      end

      it 'should tsort rolls dependencies' do
        expect(rolls.tsorted_rolls).to eq [3, 2, 1, 4]
      end
    end
  end
end
