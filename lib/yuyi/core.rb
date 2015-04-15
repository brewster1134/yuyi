#
# Yuyi Core
# monkey patches, opening ruby classes, vendored library configurations, etc.
#
require 'tsort'

class Array
  def to_yaml_style; :inline; end
end

class Hash
  include TSort
  alias tsort_each_node each_key
  def tsort_each_child node, &block
    fetch(node).each(&block)
  end
end
