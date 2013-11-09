module Config
  NAME = 'Yuyi'
  VERSION = '0.0.1'
  ROOT_DIR = File.expand_path('../../..', __FILE__)
  MENU_YAML = File.join ROOT_DIR, 'menu.yml'
  ROLLS_DIR = File.join ROOT_DIR, 'rolls'

  $: << ROLLS_DIR
end
