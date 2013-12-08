class Yuyi::Menu
  @@path = nil
  @@object = nil
  def self.path; @@path; end
  def self.object; @@object; end

  def initialize path = '~/Documents/menu.yml'
    @@path = path
    @@object = load
  end

  def load path = @@path
    YAML.load(File.open(File.expand_path(path)))
  rescue
    return nil
  end
end
