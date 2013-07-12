class Prototype < HashWithIndifferentAccess

  def []=(key, value)
    define_methods(key, value)
    super
  end

  def delete(property)
    singleton_class.send :remove_method, property
    singleton_class.send :remove_method, getter_to_setter_name(property)
    super
  end

  private

  def method_missing(method, *arguments, &block)
    if method.to_s[-1] == '=' && method.to_s[-2] != '='
      self[setter_to_getter_name(method)] = arguments.first
    else
      self[:method]
    end
  end

  def setter_to_getter_name(setter_name)
    setter_name.to_s.chop.to_sym
  end

  def getter_to_setter_name(getter_name)
    "#{getter_name}=".to_sym
  end

  def define_setter_method(method_name)
    define_singleton_method method_name do |new_value|
      self[setter_to_getter_name(method_name)] = new_value
    end
  end

  def define_proc_getter_method(method_name, proc)
    define_singleton_method method_name, &proc
  end

  def define_getter_method(method_name)
    define_singleton_method method_name do
      self[method_name]
    end
  end

  def define_methods(method_name, value)
    define_setter_method getter_to_setter_name(method_name) unless respond_to? method_name
    if value.kind_of? Proc
      define_proc_getter_method method_name, value
    else
      define_getter_method method_name
    end
  end
end
