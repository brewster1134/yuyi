class Yuyi::Menu

  # DSL API Methods
  #
  def self.add_roll file, roll
    @@instance.send :add_roll, file, roll
  end

  def self.find_roll roll
    @@instance.send :find_roll, roll
  end

  def self.on_the_menu? roll
    @@instance.send :on_the_menu?, roll
  end

  def self.options roll
    @@instance.send :options, roll
  end

  def sources; @sources; end

  # If any rolls on the menu have options, confirm the options before continuing
  #
  def confirm_options
    options = false
    @rolls.values.each do |roll|
      unless roll.options.empty?
        Yuyi.present_options roll
        options = true
      end
    end

    if options
      Yuyi.ask('Hit any key when you have your options set correctly in your menu file', :type => :warn) do
        load_from_file
      end
    end

    order_rolls
  end

private

  def initialize path = Yuyi::DEFAULT_MENU
    @rolls = {}
    @path = path
    @@instance = self

    return unless load_from_file

    download_sources
    find_rolls
  end

  # Load the file specified in the path and update the object var
  #
  def load_from_file
    @object = begin
      YAML.load(File.open(File.expand_path(@path))).deep_symbolize_keys!
    rescue
      nil
    end
  end

  # Download all sources on the menu
  #
  def download_sources
    if @object[:sources].empty?
      Yuyi.say 'No rolls could be found because no sources were set in your menu.'
      return
    end

    @sources = {}
    @object[:sources].each do |name, url|
      @sources[name] = Yuyi::Source.new name, url
    end

    @sources
  end

  # Find the rolls on the menu to add
  #
  def find_rolls
    @object[:rolls].keys.each do |roll|
      find_roll roll
    end
  end

  # Find the best roll in the source to be added
  #
  def find_roll roll
    # return specific source roll if specified in the menu
    #
    if source = (@object[:rolls][roll] || {})[:source]
      require_roll roll, File.join(source, roll.to_s)

    # look through the sources for the first roll that matches.
    # sources are listed in the menu in order of priority
    else
      @object[:sources].keys.each do |source|
        if @sources[source].available_rolls.include? roll
          path = @sources[source].available_rolls[roll][:require_path]

          require_roll roll, path
          return
        end
      end
    end
  end

  # Require a single roll
  #
  def require_roll roll, path
    return if on_the_menu? roll
    begin
      # Require roll (which will then add its class to the @all_on_menu class var)
      require path
    rescue LoadError
      Yuyi.say "You ordered the '#{roll}' roll off the menu, but we are fresh out...", :type => :fail
      Yuyi.say 'Check your menu to make sure a source with your roll is listed.', :type => :warn
      Yuyi.say
    end
  end

  # Check if a roll is on the menu
  #
  def on_the_menu? roll
    @rolls.keys.include? roll
  end

  def options roll
    @object[:rolls][roll.file_name]
  end

  # Add rolls to hash in format of {file_name: ClassName}
  # Called from yuyi/roll.rb#self.inherited
  #
  def add_roll file, roll
    @rolls[file] = roll
  end

  # Get a specific roll
  #
  def roll roll
    @rolls[roll]
  end

  # Return an array of the topologically sorted rolls from the menu
  #
  def sorted_rolls
    tsort_hash = {}

    @rolls.each do |file_name, roll|
      tsort_hash[file_name.to_s] = roll.dependencies.map(&:to_s)
    end

    tsort_hash.tsort.map(&:to_sym)
  end

  # Initialize all the rolls in order
  #
  def order_rolls
    sorted_rolls.each do |roll|
      roll_class = @rolls[roll]
      roll_class.new
    end
  end
end
