# encoding: utf-8

class Yuyi::Roll

  # DSL API Methods
  #
  def self.title title = nil
    title ? @title = title : @title
  end

  def self.file_name file_name = nil
    file_name ? @file_name = file_name : @file_name
  end

  def self.pre_install &block
    if block
      @pre_install = block
    else
      @pre_install
    end
  end

  def self.install &block
    if block
      @install = block
    else
      @install
    end
  end

  def self.post_install &block
    if block
      @post_install = block
    else
      @post_install
    end
  end

  def self.uninstall &block
    if block
      @uninstall = block
    else
      @uninstall
    end
  end

  def self.upgrade &block
    if block
      @upgrade = block
    else
      @upgrade
    end
  end

  def self.installed? &block
    if block
      @installed = block
    else
      @installed
    end
  end

  def self.dependencies *dependencies
    @dependencies ||= []

    unless dependencies.empty?
      @dependencies |= dependencies
      require_dependencies
    end

    @dependencies
  end

  # set option definitions
  def self.options arg = {}
    @option_defs ||= arg
  end

  # DSL Helper methods
  #
  def title; self.class.title; end
  def file_name; self.class.file_name; end

  # return option definitions
  def option_defs
    self.class.options
  end

  def write_to_file file, *text
    Yuyi.write_to_file file, *text
  end

  def delete_from_file file, *text
    Yuyi.delete_from_file file, *text
  end

  def options
    option_defaults = {}
    option_defs.each do |roll, option_settings|
      option_defaults[roll] = option_settings[:default]
    end

    option_defaults.merge Yuyi::Menu.options(self)
  end

  def dependencies
    self.class.dependencies
  end

  # Run the roll
  #
  def install
    if installed?
      if options[:uninstall]
        Yuyi.say "🍣\s Uninstalling #{title}...", :color => 33
        uninstall
      elsif upgrade?
        Yuyi.say "🍣\s Upgrading #{title}", :color => 36
        upgrade
      end
    else
      Yuyi.say "🍣\s Installing #{title}...", :color => 32
      install
    end
  end
  alias_method :order, :install
  alias_method :entree, :install

  def pre_install; pre_install; end
  alias_method :appetizers, :pre_install

  def post_install; post_install; end
  alias_method :dessert, :post_install

private

    def upgrade?
      Yuyi::Menu.upgrade?
    end

    # Add to global collection of rolls
    #
    def self.inherited klass
      return if klass.to_s.include? 'RollModel'

      add_roll klass, caller
    end

    def self.add_roll klass, caller
      # convert class name to a title string
      klass.title class_to_title klass

      # convert caller to a file name symbol
      klass.file_name caller_to_file_name caller

      Yuyi::Menu.add_roll klass.file_name, klass
    end

    def self.class_to_title klass
      klass.to_s.match(/[^:]+$/)[0].gsub(/(?=[A-Z])/, ' ').strip
    end

    def self.caller_to_file_name caller
      caller.first[/[a-z_]+?(?=\.rb)/].to_sym
    end

    def self.require_dependencies
      @dependencies.each do |roll|
        unless Yuyi::Menu.on_the_menu? roll
          Yuyi::Menu.find_roll roll
        end
      end
    end

    def pre_install
      return unless self.class.pre_install
      say title, :type => :success
      instance_eval(&self.class.pre_install)
    end

    def install
      begin
        instance_eval(&self.class.install)
      rescue
        say "The #{self.title} roll does not have `install` defined", :type => :fail
        exit
      end
    end

    def post_install
      return unless self.class.post_install
      say title, :type => :success
      instance_eval(&self.class.post_install)
    end

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
      if Yuyi.verbose?
        say "INSTALLED?: #{self.title}", :color => 36
      end

      begin
        !!instance_eval(&self.class.installed?)
      rescue
        say "The #{self.title} roll does not have `installed?` defined", :type => :fail
        exit
      end
    end

    # Helpers for Yuyi Cli methods
    def say *args; Yuyi.say *args; end
    def ask *args; Yuyi.ask *args; end
    def run *args; Yuyi.run *args; end
    def command? *args; Yuyi.command? *args; end
    def osx_version; Yuyi.osx_version; end

    def on_the_menu? roll
      Yuyi::Menu.on_the_menu? roll
    end
end
