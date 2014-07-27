# encoding: utf-8

class Yuyi::Roll

  # CLASS DSL API Methods
  #
  def self.title title = nil
    title ? @title = title : @title
  end

  def self.file_name file_name = nil
    file_name ? @file_name = file_name : @file_name
  end

  def self.pre_install &block
    block_given? ? @pre_install = block : @pre_install
  end

  def self.install &block
    block_given? ? @install = block : @install
  end

  def self.post_install &block
    block_given? ? @post_install = block : @post_install
  end

  def self.uninstall &block
    block_given? ? @uninstall = block : @uninstall
  end

  def self.upgrade &block
    block_given? ? @upgrade = block : @upgrade
  end

  def self.installed? &block
    block_given? ? @installed = block : @installed
  end

  def self.dependencies *dependencies
    dependencies.each do |d|
      Yuyi::Menu.find_roll d
    end

    @dependencies ||= []
    @dependencies |= dependencies
  end

  # set option definitions
  def self.options option_defs = {}
    @option_defs ||= {}
    @option_defs.merge! option_defs
  end


  # INSTANCE DSL METHODS
  #
  def method_missing method, *args, &block
    begin
      self.class.send method, *args, &block
    rescue
      Yuyi.send method, *args, &block
    rescue
      super
    end
  end

  def on_the_menu? roll
    Yuyi::Menu.on_the_menu? roll
  end

  # return definitions instaed of user options
  #
  def option_defs
    self.class.options
  end

  # return user option values
  #
  def options
    option_defaults = {}
    option_defs.each do |option_name, option_settings|
      option_defaults[option_name] = option_settings[:default]
    end

    option_defaults.merge Yuyi::Menu.options(self.class.file_name)
  end

  # Run the roll
  #
  def order
    if installed?
      if options[:uninstall]
        say "🍣\s Uninstalling #{title}...", :color => :red, :progressbar => true, :overwrite => true
        uninstall
      elsif Yuyi.upgrade
        say "🍣\s Upgrading #{title}", :color => :yellow, :progressbar => true, :overwrite => true
        upgrade
      end
    else
      say "🍣\s Installing #{title}...", :color => :green, :progressbar => true, :overwrite => true
      install
    end
  end
  alias_method :entree, :order

  # Methods to execute block
  #
  def pre_install
    return if !self.class.pre_install || installed?
    say title, :type => :success
    instance_eval(&self.class.pre_install)
  end
  alias_method :appetizers, :pre_install

  def install
    begin
      instance_eval(&self.class.install)
    rescue
      say "The #{self.title} roll does not have `install` defined", :type => :fail
      exit
    end
  end

  def post_install
    return if !self.class.post_install || installed?
    say title, :type => :success
    instance_eval(&self.class.post_install)
  end
  alias_method :dessert, :post_install

  def uninstall
     begin
      instance_eval(&self.class.uninstall)
    rescue
      say "The #{self.title} roll does not have `uninstall` defined", :type => :fail
      exit
    end
  end

  def upgrade
    begin
      instance_eval(&self.class.upgrade)
    rescue
      say "The #{self.title} roll does not have `upgrade` defined", :type => :fail
      exit
    end
  end

  def installed?
    if Yuyi.verbose
      say "INSTALLED?: #{self.title}", :color => :yellow
    end

    begin
      !!instance_eval(&self.class.installed?)
    rescue
      say "The #{self.title} roll does not have `installed?` defined", :type => :fail
      exit
    end
  end

private

    # Add to global collection of rolls
    #
    def self.inherited klass
      add_roll klass, caller
    end

    # method that actually passes the new roll to the menu
    #
    def self.add_roll klass, caller
      # convert class name to a title string
      klass.title class_to_title klass

      # convert caller to a file name symbol
      klass.file_name caller_to_file_name(caller)

      Yuyi::Menu.add_roll klass.file_name, klass
    end

    # Convert long class name to a readable title
    #
    def self.class_to_title klass
      klass.to_s.match(/[^:]+$/)[0].gsub(/(?=[A-Z])/, ' ').strip
    end

    # Convert long file name to a roll name symbol
    #
    def self.caller_to_file_name caller
      caller.first[/[a-z_]+?(?=\.rb)/].to_sym
    end
end
