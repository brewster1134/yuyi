class Yuyi::Roll
  # Add to global collection of rolls
  #
  def self.inherited roll_class
    file_name = caller.first[/[a-z_]+?(?=\.rb)/].to_sym
    roll_class.file_name = file_name
    Yuyi::Rolls.add_roll file_name, roll_class
  end

  def self.add_dependencies
    dependencies.each{ |roll| Yuyi::Rolls.require_roll roll }
  end

  # DSL Methods called when each roll is required
  # These act as meta data for the roll class
  #
  def self.title title = nil; @title ||= title; end
  def title; self.class.title; end

  def self.file_name= file_name; @file_name ||= file_name; end
  def self.file_name; @file_name; end

  def self.dependencies dependencies = []
    @dependencies ||= dependencies
  end
  def dependencies; self.class.dependencies; end

  def self.install &install
    @install ||= install
  end
  def install; instance_eval(&self.class.install); end

  def self.installed? &installed
    @installed ||= installed
  end
  def installed?; !!instance_eval(&self.class.installed?); end

  def self.available_options available_options = {}
    @available_options ||= available_options
  end
  def available_options; self.class.available_options; end

  # Run when roll is ordered
  #
  def initialize
    if installed?
      Yuyi.say "-= #{self.title} already installed", :type => :warn
    else
      Yuyi.say "-= Installing #{self.title}...", :type => :success
      install
    end
    Yuyi.say
  end

  def write_to_file file, *text
    File.open(File.expand_path(file), File::WRONLY|File::CREAT|File::APPEND) do |file|
      file.write text * "\n"
      file.write "\n"
    end
  end

  def on_the_menu? roll
    Yuyi::Rolls.on_the_menu? roll
  end

  def options
    # Get options from menu or return an empty object
    options = Yuyi::Menu.object[self.class.file_name.to_s] || {}

    # Convert keys to symbols
    options.keys.each do |key|
      options[key.to_sym] = options.delete(key)
    end

    options
  end

  def command? command
    `which #{command}`
    $?.success?
  end
end
