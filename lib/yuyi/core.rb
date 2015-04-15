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

  # https://github.com/rails/rails/blob/c48a0cac626b4e32d7abfa9f4f1fae16568157d9/activesupport/lib/active_support/core_ext/hash/keys.rb
  # Destructively & recursively convert all keys to symbols.
  #
  # DEPRECATION
  # required for: ruby 1.8.7
  # can be replaced with activesupport ~4.0
  #
  def deep_symbolize_keys!
    deep_transform_keys!{ |key| key.to_sym rescue key }
  end

  def deep_stringify_keys!
    deep_transform_keys!{ |key| key.to_s rescue key }
  end

  # Destructively convert all keys by using the block operation.
  # This includes the keys from the root hash and from all
  # nested hashes.
  #
  def deep_transform_keys! &block
    keys.each do |key|
      value = delete(key)

      self[yield(key)] = case value
      when Hash
        value.deep_transform_keys!(&block)
      when Array
        value.each{ |e| e.deep_transform_keys!(&block) rescue value }
      else
        value
      end
    end
    self
  end
end
