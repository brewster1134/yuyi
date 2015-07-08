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
      expect(@output).to include Yuyi::VERSION
    end
  end

  describe '#init' do
    before do
      stub_const 'Yuyi::DEFAULT_FILE_NAME', 'Yuyifile_spec'

      responses = [
        # home: sources
        'spec',                 # source name
        'spec/fixtures/source', # source path
        '',                     # finished adding sources

        # home: rolls
        'y',                    # add rolls to the home menu?
        'spec_roll_dependency', # add valid roll from list
        '6',                    # when asked for the option values
        'invalid_roll',         # attempt to add invalid roll
        '',                     # finished adding home rolls

        # pwd: rolls
        'y',                    # when asked to add rolls to the pwd menu
        'spec_roll',            # add valid roll from list
        'invalid_project_roll', # attempt to add invalid roll
        '',                     # finished adding pwd rolls
      ]
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

    it 'should create a menu file in the home dir' do
      home_menu = YAML.load(File.expand_path(File.join('~', Yuyi::DEFAULT_FILE_NAME))).deep_symbolize_keys

      expect(home_menu[:sources][:default]).to eq 'brewster1134/yuyi-rolls'
      expect(home_menu[:sources][:spec]).to eq 'spec/fixtures/source'
      expect(home_menu[:rolls][:spec_roll_dependency]).to eq({})
      expect(home_menu[:rolls][:spec_roll]).to eq({ :version => 6 })
      expect(home_menu[:rolls][:invalid_roll]).to be_nil
    end

    it 'should create a new menu file in the pwd' do
      expect(File.exists?(File.join(@tmp, Yuyi::DEFAULT_FILE_NAME))).to eq true
    end

    it 'should add the users sources and rolls' do
      new_menu = YAML.load(File.read(File.join(@tmp, Yuyi::DEFAULT_FILE_NAME)))
      expect(new_menu['sources']['source_one']).to eq 'source/one'
      expect(new_menu['sources']['source_two']).to eq 'source/two'
      expect(new_menu['rolls']['roll_one']).to be_a Hash
      expect(new_menu['rolls']['roll_two']).to be_a Hash
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

  describe '#start' do
    before do
      allow(Yuyi).to receive(:start)

      @cli.options = {
        :verbose => true,
        :upgrade => true,
        :menu_paths => ['foo/bar']
      }

      @cli.start
    end

    after do
      allow(Yuyi).to receive(:start).and_call_original
    end

    it 'should start yuyi with options' do
      expect(Yuyi).to have_received(:start).with ['foo/bar'], :verbose => true, :upgrade => true
    end
  end
end
