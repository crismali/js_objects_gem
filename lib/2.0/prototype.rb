require "ostruct"

class Prototype < OpenStruct

  def [](key)
    super(key.to_s)
  end

  def []=(key, value)
    if value.kind_of? Proc
      super(key.to_s, value)
      define_proc_getter_method(key, value)
    else
      super(key.to_s, value)
    end
  end

  private

  def method_missing(method, *arguments, &block)
    if equals_method?(method)
      super
      if arguments.first.kind_of?(Proc)
        getter_name = setter_to_getter_name(method)
        define_proc_getter_method(getter_name, arguments.first)
      end
    elsif block
      self[method] = block
      define_proc_getter_method(getter_name, arguments.first)
    else
      self[method]
    end
  end

  def equals_method?(method_name)
    method_name.to_s[-1] == "=" && method_name.to_s[-2] != "="
  end

  def setter_to_getter_name(setter_name)
    setter_name.to_s.chop.to_sym
  end

  def getter_to_setter_name(getter_name)
    "#{getter_name}=".to_sym
  end

  def define_proc_getter_method(method_name, proc)
    define_singleton_method method_name, &proc
  end

end
