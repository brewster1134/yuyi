class Yuyi; end

require 'yuyi/core'
require 'yuyi/dsl'
require 'yuyi/menu'
require 'yuyi/roll'
require 'yuyi/source'
require 'yuyi/ui'

class Yuyi
  extend Yuyi::Dsl
  extend Yuyi::Ui

  NAME = 'Yuyi'
  VERSION = YAML.load(File.read(File.dirname(__FILE__) + '/../.new'))['version']
  DEFAULT_MENU = File.expand_path('~/yuyi_menu')

  def self.start
    header

    Yuyi::Menu.new menu_path

    # confirm with user
    confirm_options
    authenticate

    # order
    Yuyi::Menu.order
  end
end
