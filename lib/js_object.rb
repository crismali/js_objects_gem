require 'active_support/all'
require_relative 'object'

OBJECT = Prototype.new

class JsObject < Prototype

  attr_accessor :nil_keys, :false_keys

  def initialize(prototype=nil)
    self.nil_keys = []
    self.false_keys = []
    self[:prototype] = prototype || OBJECT
  end

  def [](key)
    if nil_keys.include? key
      nil
    elsif false_keys.include? key
      false
    else
      super || prototype[key]
    end
  end

  def []=(key, value)
    remove_from_falsey_lists key
    add_to_falsey_lists key, value
    super
  end

  def delete(property)
    remove_from_falsey_lists property
    super
  end

  private

  def remove_from_falsey_lists(key)
    sym_key = key.to_sym
    if nil_keys.include? sym_key
      nil_keys.delete sym_key
    elsif false_keys.include? sym_key
      false_keys.delete sym_key
    end
  end

  def add_to_falsey_lists(key, value)
    if value.nil?
      nil_keys << key.to_sym
    elsif value == false
      false_keys << key.to_sym
    end
  end

  def method_missing(method, *arguments, &block)
    return super if method.to_s[-1] == '=' && method.to_s[-2] != '='
    delegate_to_prototype method, arguments, block
  end

  def delegate_to_prototype(method_name, arguments, block)
    prototypes_value = prototype[method_name]
    if prototypes_value.kind_of? Proc
      self.define_singleton_method :__proto_proc, prototypes_value
      __proto_proc *arguments, &block
    elsif prototypes_value.nil? && block
      self[method_name] = block
    else
      prototypes_value
    end
  end
end
