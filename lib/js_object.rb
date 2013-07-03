require 'active_support/all'
require './lib/object.rb'

class JsObject < HashWithIndifferentAccess

  attr_accessor :nil_keys, :false_keys

  def initialize(prototype=nil)
    self.nil_keys = []
    self.false_keys = []
    self.prototype = prototype || OBJECT
  end

  alias_method :old_brackets, :[]

  def [](key)
    if nil_keys.include? key
      nil
    elsif false_keys.include? key
      false
    else
      self.old_brackets(key) || prototype[key]
    end
  end

  alias_method :old_brackets_equal, :[]=

  def []=(key, value)
    remove_from_falsey_lists key, value
    add_to_falsey_lists key, value
    self.old_brackets_equal key, value
    define_methods(key, value) unless respond_to? key
  end

  def remove_from_falsey_lists(key, value)
    sym_key = key.to_sym
    if nil_keys.include? sym_key
      nil_keys.delete sym_key
    elsif false_keys.include? sym_key
      false_keys.delete sym_key
    end
  end

  def add_to_falsey_lists(key, value)
    if value.nil?
      @nil_keys << key.to_sym
    elsif value == false
      @false_keys << key.to_sym
    end
  end

  def method_missing(method, *arguments, &block)
    if method.to_s[-1] == '=' && method.to_s[-2] != '='
      self[setter_to_getter_name(method)] = arguments.first
    else
      delegate_to_prototype method, arguments
    end
  end

  def delegate_to_prototype(method_name, arguments)
    prototypes_value = prototype[method_name]
    if prototypes_value.kind_of? Proc
      self.instance_exec *arguments, &prototypes_value
    else
      prototypes_value
    end
  end

  def define_proc_getter_method(method_name, proc)
    self.define_singleton_method method_name do |*arguments|
      self.instance_exec *arguments, &self[method_name]
    end
  end

  def setter_to_getter_name(setter_name)
    setter_name.to_s.chop.to_sym
  end

  def getter_to_setter_name(getter_name)
    "#{getter_name}=".to_sym
  end

  def define_setter_method(method_name)
    self.define_singleton_method method_name do |new_value|
      self[setter_to_getter_name(method_name)] = new_value
    end
  end

  def define_getter_method(method_name)
    self.define_singleton_method method_name do
      self[method_name]
    end
  end

  def define_methods(method_name, value)
    define_setter_method getter_to_setter_name(method_name)
    if value.kind_of? Proc
      define_proc_getter_method method_name, value
    else
      define_getter_method method_name
    end
  end
end
