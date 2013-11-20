class Yuyi::Roll
  # Add to global collection of rolls
  #
  def self.inherited roll_class
    file_name = caller.first[/[a-z_]+?(?=\.rb)/]
    Yuyi::Rolls.add_roll file_name, roll_class
  end

  def self.add_dependencies dependencies
    dependencies.each{ |roll| Yuyi::Rolls.require_roll roll }
  end

  # Methods called when each roll is required
  # These act as meta data for the roll class
  #
  def self.title title = nil; @title ||= title; end
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

  def self.installed? &installed
    @installed ||= yield rescue false
  end
  def installed?; !!self.class.installed? end

  # Run when roll is ordered
  #
  def initialize
    Yuyi.say
    if self.installed?
      Yuyi.say "-= #{self.title} already installed", :type => :warn
    else
      Yuyi.say "-= Installing #{self.title}...", :type => :success
      self.install.call()
    end
  end

  def write_to_file file, text
    File.open(File.expand_path(file), File::WRONLY|File::CREAT|File::APPEND) do |file|
      file.write text
      file.write "\n"
    end
  end

  def on_the_menu? roll
    Yuyi::Rolls.on_the_menu? roll
  end
end
