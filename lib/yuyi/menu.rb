class Yuyi::Menu
  @rolls = {}
  @pre_installs = []
  @post_installs = []

  # DSL Helper methods
  #
  def self.instance; @@instance; end

  def self.object; @object; end
  def object; self.class.object; end

  def self.sources; @@instance.sources; end
  def sources; @sources; end

  def self.rolls; @rolls; end
  def rolls; self.class.rolls; end

  def self.path
    @@instance.path
  end
  def path; @path; end

  def self.on_the_menu? roll
    @@instance.on_the_menu? roll
  end

  def self.find_roll name, options = {}
    @@instance.find_roll name, options
  end

  def self.set_sources
    @@instance.set_sources
  end

  def self.upgrade? boolean = nil
    @@instance.upgrade? boolean
  end

  def self.options roll
    @@instance.options roll
  end

  # Attempt to load a menu from a file path
  # defaults to previously stored @path value
  #
  def self.load_from_file path = path
    @object = begin
      YAML.load(File.open(File.expand_path(path))).deep_symbolize_keys!
    rescue
      nil
    end
  end

  # Add rolls to hash in format of {file_name: RollInstance}
  # Called from yuyi/roll.rb#self.inherited
  #
  def self.add_roll file_name, klass
    @rolls[file_name] = klass.new
  end

  def self.add_pre_install block
    @pre_installs << block
  end

  def self.add_post_install block
    @post_installs << block
  end

  def self.pre_install
    @pre_installs.each { |b| b.call }
  end

  def self.post_install
    @post_installs.each { |b| b.call }
  end

  # Get/Set upgrade flag
  #
  def upgrade? boolean = nil
    @upgrade = boolean.nil? ? @upgrade : boolean
  end

  # Check if a roll is on the menu
  #
  def on_the_menu? roll
    object[:rolls].keys.include? roll
  end

  # Download & create all sources on the menu
  #
  def set_sources
    if object[:sources].empty?
      Yuyi.say 'No rolls could be found because no sources were set in your menu.'
      return
    end

    @sources = []
    object[:sources].each do |source|
      source.each do |name, path|
        @sources << Yuyi::Source.new(name, path)
      end
    end

    @sources
  end

  def options roll
    object[:rolls][roll.file_name] || {}
  end

  # Initialize all the rolls in order
  #
  def order_rolls
    Yuyi::Menu.pre_install

    sorted_rolls.each do |file_name|
      rolls[file_name].order
    end

    Yuyi::Menu.post_install
  end

  # Find the best roll in the source to be added
  #
  def find_roll name, options = {}
    options ||= {}
    # return specific source roll if specified in the menu
    #
    if source = options[:source]
      require_roll name, File.join(source, name.to_s)
      return

    # look through the sources for the first roll that matches.
    # sources are listed in the menu in order of priority
    else
      sources.each do |source|
        if path = source.available_rolls[name]
          require_roll name, path
          return
        end
      end
    end

    # no roll was found
    Yuyi.say "You ordered the '#{name}' roll off the menu, but we are fresh out...", :type => :fail
    Yuyi.say 'Check your menu to make sure a source with your roll is listed.', :type => :warn
    Yuyi.say
  end

private

    def initialize path
      return unless Yuyi::Menu.load_from_file path

      @path = path
      @@instance = self

      set_sources
      set_rolls
    end

    # Create all rolls on the menu
    #
    def set_rolls
      object[:rolls].each do |name, options|
        find_roll name, options
      end
    end

    # Require a single roll
    #
    def require_roll name, path
      # check if already on the roll for when requiring dependencies
      return if roll_loaded? name

      begin
        require path
      rescue LoadError
        Yuyi.say "There was a problem loading the `#{name}` roll from `#{path}`", :type => :fail
        Yuyi.say 'If this problem continues, please log an issue on the Yuyi github page.', :type => :warn
        Yuyi.say
      end
    end

    # Check if roll has already been required & loaded
    #
    def roll_loaded? roll
      rolls.keys.include? roll
    end

    # Return an array of the topologically sorted rolls from the menu
    #
    def sorted_rolls
      tsort_hash = {}
      rolls.each do |file_name, roll|
        tsort_hash[file_name.to_s] = roll.dependencies.map(&:to_s)
      end

      tsort_hash.tsort.map(&:to_sym)
    end
end
