describe Yuyi::Cli do
  before do
    @cli = Yuyi::Cli.new

    # collect output from S.ay
    @output = ''
    allow(S).to receive :ay do |text|
      @output << (text || '')
    end
  end

  describe '#version' do
    it 'should return a version' do
      @cli.version
      expect(@output).to eq Yuyi::VERSION
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
      expect(@output).to include 'barfoo'
    end
  end

  describe '#init' do
    before do
      responses = ['source_one', 'source/one', 'source_two', 'source/two', '', 'roll_one', 'roll_two', '']
      allow(A).to receive(:sk) do |text, options, &block|
        block.call responses.shift
      end

      @pwd = Dir.pwd
      @tmp = Dir.mktmpdir
      FileUtils.chdir @tmp
      @cli.init
    end

    after do
      FileUtils.chdir @pwd
    end

    it 'should create a new menu file in the pwd' do
      expect(File.exists?(File.join(@tmp, Yuyi::DEFAULT_FILE_NAME))).to eq true
    end

    it 'should add the users sources and rolls' do
      new_menu = YAML.load(File.read(File.join(@tmp, Yuyi::DEFAULT_FILE_NAME)))
      expect(new_menu['sources']['source_one']).to eq 'roll_one'
      expect(new_menu['rolls']['roll_one']).to be_a Hash
      expect(new_menu['rolls']['roll_two']).to be_a Hash
    end
  end

  describe '#start' do
    before do
      allow(Yuyi).to receive(:start)

      @cli.options = {
        :verbose => true,
        :upgrade => true,
        :menu_path => 'foo/bar'
      }

      @cli.start
    end

    after do
      allow(Yuyi).to receive(:start).and_call_original
    end

    it 'should set flags' do
      expect(Yuyi.verbose?).to eq true
      expect(Yuyi.upgrade?).to eq true
    end

    it 'should start yuyi with menu path' do
      expect(Yuyi).to have_received(:start).with 'foo/bar'
    end
  end
end
