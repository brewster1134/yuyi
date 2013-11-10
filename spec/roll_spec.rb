require 'spec_helper'

require_all_rolls

describe Yuyi::Roll do
  Yuyi::Rolls.class_var(:all_on_menu).values.each do |roll_class|
    describe roll_class do
      let(:roll) { roll_class.new }

      before do
        roll_class.any_instance.stub(:install)
      end

      it 'should have a title' do
        expect(roll.title).to be_true
      end

      it 'should have dependencies' do
        expect(roll.dependencies).to be_true
        expect(roll.dependencies).to be_an_instance_of Array
      end
    end
  end
end
