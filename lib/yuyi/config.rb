module Yuyi::Config
  NAME = 'Yuyi'
  VERSION = '0.0.5'
  ROOT_DIR = File.expand_path('../../..', __FILE__)
  DEFAULT_ROLL_PATH = '~/Documents/menu.yml'
  ROLLS_DIR = File.join ROOT_DIR, 'rolls'

  $: << ROLLS_DIR
end
