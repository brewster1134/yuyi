class Yuyi::Roll
  # Add to global collection of rolls
  #
  def self.inherited roll_class
    # convert class name to a human readble title-cased string
    roll_class.title = roll_class.to_s.gsub(/(?=[A-Z])/, ' ').strip

    # convert absolute path to a file name symbol
    roll_class.file_name = file_name = caller.first[/[a-z_]+?(?=\.rb)/].to_sym

    Yuyi::Menu.add_roll file_name, roll_class
  end

  def self.require_dependencies
    @dependencies.each { |roll| Yuyi::Menu.require_roll roll }
  end

  # DSL Methods called when each roll is required
  # These act as meta data for the roll class
  #
  def self.title= title
    @title ||= title
  end
  def self.title; @title; end
  def title; self.class.title; end

  def self.file_name= file_name
    @file_name ||= file_name
  end
  def self.file_name; @file_name; end

  def self.available_options available_options = {}
    @available_options ||= available_options
  end
  def available_options; self.class.available_options; end

  def self.dependencies *dependencies
    @dependencies ||= dependencies.flatten
    require_dependencies
  end
  def dependencies; self.class.dependencies; end

  def self.add_dependencies *dependencies_array
    # Create @dependencies if it doesnt exist yet
    # This prevent needing to call `dependencies` on a roll if all dependencies are dynamic
    @dependencies ||= []

    # Merge dynamic dependencies with static dependencies with bitwise operator
    @dependencies |= dependencies_array

    # Require dynamic dependencies
    dependencies.each { |d| Yuyi::Menu.require_roll d }
  end

  def self.installed? &block
    @installed ||= block
  end
  def installed?
    installed = !!instance_eval(&self.class.installed?)
    if installed
      Yuyi.say "-= #{title} already installed", :type => :warn
    end
    installed
  end

  def self.install &block
    @install ||= block
  end
  def install
    Yuyi.say "-= Installing #{title}...", :type => :success
    instance_eval(&self.class.install)
  end

  def self.update &block
    @update ||= block
  end
  def update
    return unless self.class.update
    Yuyi.say '...Installing Updates', :type => :success, :indent => 3
    instance_eval(&self.class.update)
  end

  def self.uninstall &block
    @uninstall ||= block
  end
  def uninstall
    if options[:uninstall]
      Yuyi.say "-= Uninstalling #{title}...", :type => :success
      instance_eval(&self.class.uninstall)
    end
  end

  # Get the latest options from the menu or return an empty object
  #
  def self.options
    options = Yuyi::Menu.object[file_name] || {}
  end
  def options; self.class.options; end

  def self.present_options
    options = false
    unless available_options.empty?
      Yuyi.present_options self
      options = true
    end
    options
  end

  def say *args; Yuyi.say *args; end
  def run *args; Yuyi.run *args; end
  def command? *args; Yuyi.command? *args; end

  # Run when roll is ordered
  #
  def initialize
    if installed?
      update
    else
      install
    end
    Yuyi.say
  end
end
