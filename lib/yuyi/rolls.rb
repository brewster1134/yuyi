class Yuyi::Rolls
  @@all_on_menu = {}

  # Being the process of loading and installing rolls
  #
  def self.load
    # Don't order rolls if there is a roll cannot be loaded
    self.load_from_menu rescue return
    self.load_dependencies
    self.present_options
    self.order_rolls
  end

private

  def self.menu= menu; @@menu = menu; end
  def self.menu; @@menu; end

  # Require all rolls on the menu
  #
  def self.load_from_menu
    self.menu.keys.each do |roll|
      raise if require_roll(roll).nil?
    end
  end

  def self.present_options
    options = false
    @@all_on_menu.each do |file_name, klass|
      unless klass.available_options.empty?
        Yuyi.present_options klass
        options = true
      end
    end
    return unless options
    Yuyi.ask('Hit enter when the options are set correctly in your menu', :type => :success) {}
  end

  # Require all the dependencies of all the rolls added from the menu
  #
  def self.load_dependencies
    @@all_on_menu.each do |file_name, klass|
      klass.add_dependencies
    end
  end

  # Require a single roll
  #
  def self.require_roll roll
    begin
      # Require roll (which will then add its class to the @all_on_menu class var)
      require roll.to_s
    rescue LoadError
      Yuyi.say
      Yuyi.say "You ordered the '#{roll}' roll off the menu, but we are fresh out...", :type => :fail
      Yuyi.say "Make sure `rolls/#{roll}.rb` exists, or remove it from your menu.", :type => :fail
    end
  end

  # Add rolls to hash in format of {under_score_name: ClassName}
  # Called from yuyi/roll.rb#self.inherited
  #
  def self.add_roll file, klass
    @@all_on_menu[file] = klass
  end

  # Return an array of the tsorted rolls from the menu
  #
  def self.tsorted_rolls
    tsort_hash = {}

    @@all_on_menu.each do |file_name, klass|
      tsort_hash[file_name.to_s] = klass.dependencies.map(&:to_s)
    end

    tsort_hash.tsort.map(&:to_sym)
  end

  # Initialize all the rolls in order
  #
  def self.order_rolls
    self.tsorted_rolls.each do |roll|
      roll_class = @@all_on_menu[roll]
      roll_class.new
    end
  end

  # Check if a roll is on the menu
  #
  def self.on_the_menu? roll
    @@all_on_menu.keys.include? roll
  end
end
