class Yuyi; end

require 'yuyi/cli'
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
  VERSION = YAML.load(File.read(File.dirname(__FILE__) + '/../Newfile'))['version']
  DEFAULT_FILE_NAME = 'Yuyifile'

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
