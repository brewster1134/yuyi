class Yuyi::Menu
  @@classes = {}
  @@object = {}
  @@path = nil

  def initialize path = Yuyi::DEFAULT_ROLL_PATH
    @@path = path
    return unless @@object = self.class.load
    require_rolls
    present_options
  end

  def self.load
    YAML.load(File.open(File.expand_path(@@path))).deep_symbolize_keys!
  rescue
    return nil
  end

  def self.classes; @@classes; end
  def self.object; @@object; end
  def self.path; @@path; end

  # Require a single roll
  #
  def self.require_roll roll
    return if on_the_menu? roll
    begin
      # Require roll (which will then add its class to the @all_on_menu class var)
      require roll.to_s
    rescue LoadError
      Yuyi.say
      Yuyi.say "You ordered the '#{roll}' roll off the menu, but we are fresh out...", :type => :fail
      Yuyi.say "Make sure `rolls/#{roll}.rb` exists, or remove it from your menu.", :type => :fail
    end
  end

  # Check if a roll is on the menu
  #
  def self.on_the_menu? roll
    !!@@classes[roll]
  end

  # Add rolls to hash in format of {under_score_name: ClassName}
  # Called from yuyi/roll.rb#self.inherited
  #
  def self.add_roll file, klass
    @@classes[file] ||= klass
  end

  # Return an array of the tsorted rolls from the menu
  #
  def self.sorted
    tsort_hash = {}

    @@classes.each do |file_name, klass|
      tsort_hash[file_name.to_s] = klass.dependencies.map(&:to_s)
    end

    tsort_hash.tsort.map(&:to_sym)
  end

  # Initialize all the rolls in order
  #
  def self.order_rolls
    sorted.each do |roll|
      roll_class = @@classes[roll]
      roll_class.new
    end
  end

private

  # Require all rolls on the menu
  #
  def require_rolls
    self.class.object.keys.each do |roll|
      # raise if self.class.require_roll(roll).nil?
      self.class.require_roll(roll).nil?
    end
  end

  def present_options
    options = false
    @@classes.values.each do |klass|
      if klass.present_options
        options = true
      end
    end
    return unless options
    Yuyi.ask('Hit enter when the options are set correctly in your menu', :type => :success) do
      self.class.load
      self.class.order_rolls
    end
  end
end
