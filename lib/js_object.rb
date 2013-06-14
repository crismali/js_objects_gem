require 'active_support/all'
require './object'

class JsObject < HashWithIndifferentAccess

  def initialize(prototype=nil)
    @nil_keys = []
    @false_keys = []
    self.prototype = prototype || OBJECT
  end

  alias_method :old_brackets, :[]

  def [](key)
    if @nil_keys.include? key
      nil
    elsif @false_keys.include? key
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
  end

  def remove_from_falsey_lists(key, value)
    if @nil_keys.include? key
      @nil_keys.delete key.to_s
      @nil_keys.delete key.to_sym
    elsif @false_keys.include? key
      @false_keys.delete key.to_s
      @false_keys.delete key.to_sym
    end
  end

  def add_to_falsey_lists(key, value)
    if value.nil?
      @nil_keys << key.to_sym
      @nil_keys << key.to_s
    elsif value == false
      @false_keys << key.to_sym
      @false_keys << key.to_s
    end
  end

  def method_missing(method, *arguments)
    if method.to_s[-1] == '=' && method.to_s[-2] != '='
      if arguments.first.kind_of? Proc
        define_proc_method(method, arguments.first)
      else
        define_setter_method method
        define_getter_method method
        self.send method, arguments.first
      end
    else
      prototype[method]
    end
  end

  def define_proc_method(method_name, proc)
    define_setter_method method_name
    self.send method_name, proc

    attr_name = setter_to_getter_name(method_name)

    self.define_singleton_method attr_name do |*arguments|
      self.instance_exec *arguments, &self[attr_name]
    end
  end

  def setter_to_getter_name(setter_name)
    setter_name.to_s.chop.to_sym
  end

  def define_setter_method(method_name)
    self.define_singleton_method method_name do |new_value|
      self[setter_to_getter_name(method_name)] = new_value
    end
  end

  def define_getter_method(method_name)
    attr_name = setter_to_getter_name(method_name)
    self.define_singleton_method attr_name do
      self[attr_name]
    end
  end

end
