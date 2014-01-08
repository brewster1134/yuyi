module Yuyi::Config
  NAME = 'Yuyi'
  VERSION = '0.1.0'
  ROOT_DIR = File.expand_path('../../..', __FILE__)
  DEFAULT_ROLL_PATH = File.expand_path('~/.yuyi_menu')
  ROLLS_DIR = File.join ROOT_DIR, 'rolls'

  # Add the rolls directory to the load path
  $: << ROLLS_DIR
end
