#
# YUYI
# Root class that stores global instances and state
#
require 'yaml'

class Yuyi
  require 'yuyi/cli'
  require 'yuyi/core'
  require 'yuyi/menu'
  require 'yuyi/roll'
  require 'yuyi/source'
  require 'yuyi/ui'
  extend Yuyi::Ui

  VERSION = YAML.load(File.read(File.dirname(__FILE__) + '/../Newfile'))['version']
  DEFAULT_FILE_NAME = 'Yuyifile'

  # When verbose is enabled, roll commands, and their outputs will be shown
  @@verbose = false
  def self.set_verbose; @@verbose = true; end
  def self.verbose?; @@verbose; end

  # When upgrade is enabled, already-installed rolls will attempt to be upgraded
  @@upgrade = false
  def self.set_upgrade; @@upgrade = true; end
  def self.upgrade?; @@upgrade; end

  # State variables
  # Global access to Yuyi singleton instances
  # The initialized cli instance
  @@cli = nil
  def self.cli= cli; @@cli = cli; end
  def self.cli; @@cli; end

  # The loaded menu will be stored here. Through it, you can access the loaded sources and rolls
  @@menu = nil
  def self.menu= menu; @@menu = menu; end
  def self.menu; @@menu; end

  # Starts Yuyi
  # @param menu_path [String] a path to a valid yuyi menu yaml-formatted file
  #
  def self.start menu_path
    Yuyi::Menu.new menu_path

    # confirm with user
    confirm_options
    authenticate

    # order
    Yuyi::Menu.order
  end
end
