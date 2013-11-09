class Yuyi::Roll
  def self.inherited roll
    key = caller.first[/[a-z_]+?(?=.rb)/]
    Yuyi::Rolls.add_roll key, roll
  end

  def self.title title = nil
    @title ||= title
  end
  def title; self.class.title; end

  def self.dependencies dependencies = []
    @dependencies ||= dependencies.map(&:to_s)
  end
  def dependencies; self.class.dependencies; end

  def initialize
    Yuyi.say
    Yuyi.say "-= Installing #{self.title}...", :color => 32
    self.install
  end
end
