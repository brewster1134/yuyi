require 'spec_helper'

describe Yuyi::Ui do
  describe '#present_options' do
    before do
      class UiTest; extend Yuyi::Ui; end

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
  end
end
