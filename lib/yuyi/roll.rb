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
    Yuyi::Menu.add_pre_install block
  end

  def self.install &block
    @install ||= block
  end

  def self.post_install &block
    Yuyi::Menu.add_post_install block
  end

  def self.uninstall &block
    @uninstall ||= block
  end

  def self.upgrade &block
    @upgrade ||= block
  end

  def self.installed? &block
    @installed ||= block
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
  def order
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

private

    def upgrade?
      Yuyi::Menu.upgrade?
    end

    # Add to global collection of rolls
    #
    def self.inherited klass
      # convert class name to a human readble title-cased string
      klass.title klass.to_s.gsub(/(?=[A-Z])/, ' ').strip

      # convert absolute path to a file name symbol
      klass.file_name caller.first[/[a-z_]+?(?=\.rb)/].to_sym

      Yuyi::Menu.add_roll klass.file_name, klass
    end

    def self.require_dependencies
      @dependencies.each do |roll|
        unless Yuyi::Menu.on_the_menu? roll
          Yuyi::Menu.find_roll roll
        end
      end
    end

    def install
      instance_eval(&self.class.install)
    end

    def uninstall
      instance_eval(&self.class.uninstall)
    end

    def upgrade
      instance_eval(&self.class.upgrade)
    end

    def installed?
      !!instance_eval(&self.class.installed?)
    end

    # Helpers for Yuyi Cli methods
    def say *args; Yuyi.say *args; end
    def run *args; Yuyi.run *args; end
    def command? *args; Yuyi.command? *args; end

    def on_the_menu? roll
      Yuyi::Menu.on_the_menu? roll
    end
end
