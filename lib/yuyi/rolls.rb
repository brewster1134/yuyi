class Yuyi::Rolls
  @@all_on_menu = {}

  def self.load
    # Don't order rolls if there is a roll cannot be loaded
    self.load_from_menu rescue return
    self.order_rolls
  end

private

  def self.menu= menu; @@menu = menu; end
  def self.menu; @@menu; end

  # require all rolls on the menu
  #
  def self.load_from_menu
    self.menu.each do |roll|
      raise if require_roll(roll).nil?
    end
  end

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

  def self.tsorted_rolls
    tsort_hash = {}

    @@all_on_menu.each do |file_name, klass|
      tsort_hash[file_name] = klass.dependencies
    end

    tsort_hash.tsort
  end

  def self.order_rolls
    self.tsorted_rolls.each do |roll|
      roll_class = @@all_on_menu[roll]
      roll_class.new
    end
  end

  def self.on_the_menu? roll
    @@all_on_menu.keys.include? roll.to_s
  end
end
