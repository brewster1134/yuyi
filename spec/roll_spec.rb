require 'spec_helper'

require_rolls

Yuyi::Rolls.all_on_menu.values.each do |roll_class|
  describe roll_class do
    let(:roll) { roll_class.new }

    it 'should have a title' do
      expect(roll.title).to be_true
    end

    it 'should have dependencies' do
      expect(roll.dependencies).to be_true
      expect(roll.dependencies).to be_an_instance_of Array
    end
  end
end
