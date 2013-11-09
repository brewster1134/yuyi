require 'yaml'

class Yuyi::Rolls
  @@all_on_menu = {}

  def self.load
    self.load_from_menu
    self.tsorted_rolls
    self.order_rolls
  end

private

  # require all rolls on the menu
  #
  def self.load_from_menu
    self.load_menu.each do |roll, data|
      begin
        # Require roll (which will then add its class to the @all class var)
        require roll
      rescue LoadError
        Yuyi.say "You ordered the '#{roll}' roll off the menu, but we are fresh out...", :type => :warn
        Yuyi.say "Make sure `rolls/#{roll}.rb` exists, or remove it from your menu.", :type => :warn
      end
    end

    return @@all_on_menu
  end

  def self.load_menu
    YAML.load File.open Yuyi::MENU_YAML
  end

  # Add rolls to hash in format of {under_score_name: ClassName}
  # Called from yuyi/roll.rb#self.inherited
  #
  def self.add_roll file, klass
    @@all_on_menu[file] = klass
  end

  def self.tsorted_rolls
    tsort_hash = {}

    @@all_on_menu.each do |underscore, klass|
      tsort_hash[underscore] = klass.dependencies
    end

    @@tsorted_rolls = tsort_hash.tsort
  end

  def self.order_rolls
    @@tsorted_rolls.each do |roll|
      roll_class = @@all_on_menu[roll]
      roll_class.new
    end
  end
end
