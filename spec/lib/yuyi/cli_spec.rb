describe Yuyi::Cli do
  before do
    @cli = Yuyi::Cli.new

    # collect output from S.ay
    @output = ''
    allow(S).to receive :ay do |text|
      @output << (text || '')
    end
  end

  describe '#list' do
    before do
      allow(Yuyi::Menu).to receive :new
      allow(Yuyi::Menu).to receive(:sources).and_return([
        OpenStruct.new({ :rolls => { :foo => {}}}),
        OpenStruct.new({ :rolls => { :bar => {}}})
      ])

      @cli.list
    end

    after do
      allow(Yuyi::Menu).to receive(:new).and_call_original
      allow(Yuyi::Menu).to receive(:sources).and_call_original
    end

    it 'should return all rolls alphabetically' do
      expect(@output).to include "barfoo"
    end
  end

  describe '#version' do
    it 'should return a version' do
      expect(@cli.version).to eq "#{Yuyi::NAME} #{Yuyi::VERSION}"
    end
  end
end
