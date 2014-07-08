require 'readline'

class Yuyi::Menu
  # Stores a single menu instance on the class
  # If a new menu is initialized, it will become the only menu accessible through Yuyi::Menu.menu
  #
  @@menu = nil

  # Create a new menu that stores the raw yaml file
  # along with source, roll, and roll model instances
  #
  def initialize path
    # make menu instance accessible by the class
    @@menu = self
    @rolls = {}
    @sources = []

    # load a yaml file
    load_from_file path

    # create objects from the menu
    set_sources
    set_roll_models
    set_rolls
  end

  def options roll
    @yaml[:rolls][roll] || {}
  end

  # DSL METHODS
  #
  def self.sources
    menu.send :sources
  end

  # Add rolls to hash in format of {file_name: RollInstance}
  # Called from Yuyi::Roll when a roll is inherited
  #
  def self.add_roll file_name, klass
    unless klass.to_s.include? 'RollModel'
      rolls[file_name] = klass.new
    end
  end

  def self.on_the_menu? roll
    menu.send :on_the_menu?, roll
  end

  def self.find_roll name, options = {}
    menu.send :find_roll, name, options
  end

  def self.load_from_file
    menu.send :load_from_file
  end

  # Find the best roll match from the sources and require it
  #
  def find_roll name, options = {}
    return if on_the_menu? name

    # return specific source roll if specified in the menu
    #
    if source = options[:source]
      require_roll name, File.join(source, name.to_s)
      return

    # look through the sources for the first roll that matches.
    # sources are listed in the menu in order of priority
    else
      @sources.each do |source|
        if path = source.rolls[name]
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

    # CLASS METHODS
    #
    def self.menu; @@menu; end
    def self.menu_path; @@menu.send :menu_path; end
    def self.order; @@menu.send :order; end
    def self.rolls; @@menu.send :rolls; end
    def self.sources; @@menu.send :sources; end

    def self.options roll
      @@menu.options roll
    end

    # INSTANCE METHODS
    #
    def menu_path; @menu_path; end
    def rolls; @rolls; end
    def sources; @sources; end

    # Attempt to load a menu from a file path
    #
    def load_from_file menu_path = @menu_path
      if !menu_path || menu_path.empty?
        get_menu_path
        return
      end

      unless @menu_path
        # check if path is local first
        begin
          File.open(File.expand_path(menu_path))

          @menu_path = File.expand_path(menu_path)

        # otherwise assume it is remote and try to download it
        rescue
          # try to download the menu path
          response = Yuyi.run "curl -sS #{menu_path}"

          # save a local copy of the remote menu
          if $?.success?
            # if a menu was downloaded, save the response to a local file
            local_file_name = Yuyi::DEFAULT_MENU.clone << '_remote'

            File.open local_file_name, 'w+' do |f|
              f.write response
            end

            @menu_path = local_file_name
          end
        end
      end

      begin
        @yaml = YAML.load(File.open(@menu_path)).deep_symbolize_keys!
      rescue
        Yuyi.say "No menu could be loaded from `#{menu_path}`", :type => :fail
        get_menu_path
      end
    end

    # prompt the user to enter a path to menu file
    # keep prompting until path is valid
    #
    def get_menu_path
      until @yaml
        Yuyi.say 'Navigate to a menu file...', :type => :success
        Yuyi.ask "...or just press enter to load `#{Yuyi::DEFAULT_MENU}`", :readline => true, :color => 36 do |user_path|
          menu_path = user_path.empty? ? Yuyi::DEFAULT_MENU : user_path
          load_from_file menu_path
        end
      end
    end

    # Initialize sources from menu
    #
    def set_sources
      @yaml[:sources].each do |name, path|
        @sources << Yuyi::Source.new(name, path)
      end
    end

    # Loop through the roll models in the yaml file and find a matching roll
    def set_roll_models
      @sources.each do |source|
        source.roll_models.values.each do |roll_model_path|
          require roll_model_path
        end
      end
    end

    # Loop through the rolls in the yaml file and find a matching roll
    #
    def set_rolls
      @yaml[:rolls].each do |roll_name, roll_options|
        find_roll roll_name, roll_options || {}
      end
    end

    # Add a single roll to the menu
    #
    def require_roll name, path
      # check if already on the roll for when requiring dependencies
      return if on_the_menu? name

      begin
        require path
      rescue LoadError
        Yuyi.say "There was a problem loading the `#{name}` roll from `#{path}`", :type => :fail
        Yuyi.say 'If this problem continues, please log an issue on the Yuyi github page.', :type => :warn
        Yuyi.say
      end
    end

    # Check if roll has already been added
    #
    def on_the_menu? roll
      @rolls.keys.include? roll
    end

    # Initialize all the rolls in order
    #
    def order
      header_length = 80
      all_rolls = sorted_rolls


      # pre installs
      #
      Yuyi.say '=' * header_length, :color => 35
      Yuyi.say 'APPETIZERS', :color => 35, :justify => :center, :padding => header_length
      Yuyi.say 'Pre Install', :justify => :center, :padding => header_length
      Yuyi.say

      all_rolls.each do |file_name|
        @rolls[file_name].appetizers
      end


      # main installs
      #
      Yuyi.say '=' * header_length, :color => 36
      Yuyi.say 'ENTREES', :color => 36, :justify => :center, :padding => header_length
      Yuyi.say 'Main Install', :justify => :center, :padding => header_length
      Yuyi.say

      all_rolls.each do |file_name|
        @rolls[file_name].entree
      end


      # post installs
      #
      Yuyi.say '=' * header_length, :color => 35
      Yuyi.say 'DESSERT', :color => 35, :justify => :center, :padding => header_length
      Yuyi.say 'Post Install', :justify => :center, :padding => header_length
      Yuyi.say

      all_rolls.each do |file_name|
        @rolls[file_name].dessert
      end


      Yuyi.say '=' * header_length, :color => 36
      Yuyi.say 'YUYI COMPLETED', :color => 36, :justify => :center, :padding => header_length
      Yuyi.say '=' * header_length, :color => 36
      Yuyi.say
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
end
