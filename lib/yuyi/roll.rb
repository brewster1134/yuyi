class Yuyi::Roll
  # Add to global collection of rolls
  #
  def self.inherited roll_class
    file_name = caller.first[/[a-z_]+?(?=.rb)/]
    Yuyi::Rolls.add_roll file_name, roll_class
  end

  def self.add_dependencies dependencies
    dependencies.each{ |roll| Yuyi::Rolls.require_roll roll }
  end

  # Methods called when each roll is required
  # These act as meta data for the roll class
  #
  def self.title title = nil
    @title ||= title
  end
  def title; self.class.title; end

  def self.dependencies dependencies = []
    add_dependencies dependencies
    @dependencies ||= dependencies.map(&:to_s)
  end
  def dependencies; self.class.dependencies; end

  def self.install &install
    @install ||= install
  end
  def install; self.class.install; end

  # Run when roll is ordered
  #
  def initialize
    Yuyi.say
    Yuyi.say "-= Installing #{self.title}...", :color => 32
    self.install.call()
  end
end
