module Yuyi::Config
  NAME = 'Yuyi'
  VERSION = '0.0.6'
  ROOT_DIR = File.expand_path('../../..', __FILE__)
  DEFAULT_ROLL_PATH = '~/Documents/menu.yml'
  ROLLS_DIR = File.join ROOT_DIR, 'rolls'

  # Add the rolls directory to the load path
  $: << ROLLS_DIR
end
