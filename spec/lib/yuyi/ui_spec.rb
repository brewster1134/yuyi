require 'spec_helper'

describe Yuyi::Ui do
  before do
    class UiTest; extend Yuyi::Ui; end
    Yuyi::Ui.class_var :required, {}
  end

  describe '.present_options' do
    before do
      @output = ''
      allow(UiTest).to receive :say do |o, p|
        @output << (o || '')
      end

      class PresentOptionsRoll; end
      allow(PresentOptionsRoll).to receive(:title).and_return 'Present Options Roll'
      allow(PresentOptionsRoll).to receive(:file_name).and_return :present_options_roll
      allow(PresentOptionsRoll).to receive(:options).and_return({ :option_foo => '3.0' })
      allow(PresentOptionsRoll).to receive(:option_defs).and_return({
        :option_foo => {
          :description => 'foo description',
          :example => '1.0',
          :default => '2.0'
        },
        :option_required_foo => {
          :required => true
        }
      })

      UiTest.send :present_options, PresentOptionsRoll
    end

    it 'should output the neccessary information' do
      expect(@output).to include 'Present Options Roll'
      expect(@output).to include 'present_options_roll'
      expect(@output).to include 'foo description'
      expect(@output).to include '1.0'
      expect(@output).to include '2.0'
    end

    it 'should add to the required object' do
      expect(Yuyi::Ui.class_var(:required)).to eq({ :present_options_roll => [:option_required_foo] })
    end
  end

  describe '.confirm_options' do
    before do
      Yuyi::Ui.class_var :required, { :confirm_options_roll => [:option_foo]}

      allow(UiTest).to receive(:present_options)
      allow(UiTest).to receive(:say)
      allow(UiTest).to receive(:ask)

      class ConfirmOptionsRoll; end
      @confirm_options_roll = ConfirmOptionsRoll.new
      allow(ConfirmOptionsRoll).to receive(:options).and_return({ :option_foo => {}})

      allow(Yuyi::Menu).to receive(:rolls).and_return({ :confirm_options_roll => @confirm_options_roll })
      allow(Yuyi::Menu).to receive(:menu_path)
      allow(Yuyi::Menu).to receive(:options).and_return({ :option_foo => nil }, { :option_foo => 'bar' })

      UiTest.send :confirm_options
    end

    it 'should call present_options if there are rolls with options' do
      expect(UiTest).to have_received(:present_options).with(@confirm_options_roll)
    end

    it 'should ask to reload the menu if required options arent satisfied' do
      expect(UiTest).to have_received(:ask).twice
    end
  end
end
