PROTOTYPE = Prototype.new

class JsObject < Prototype

  def initialize(prototype=nil)
    super
    self.nil_keys = []
    self.false_keys = []
    self[:prototype] = prototype || PROTOTYPE
  end

  def [](key)
    if nil_keys.include? key.to_s
      nil
    elsif false_keys.include? key.to_s
      false
    else
      super || prototype[key]
    end
  end

  def []=(key, value)
    remove_from_falsey_lists key.to_s
    add_to_falsey_lists key.to_s, value
    super
  end

  private

  attr_accessor :nil_keys, :false_keys

  def remove_from_falsey_lists(key)
    nil_keys.delete key
    false_keys.delete key
  end

  def add_to_falsey_lists(key, value)
    if value.nil?
      nil_keys << key
    elsif value == false
      false_keys << key
    end
  end

  def method_missing(method, *arguments, &block)
    return super if equals_method?(method) || (block && prototype[method].nil?)
    delegate_to_prototype method, arguments, block
  end

  def delegate_to_prototype(method_name, arguments, block)

    prototypes_value = prototype[method_name]
    if prototypes_value.kind_of? Proc
      define_singleton_method :__proto_proc, &prototypes_value
      __proto_proc *arguments, &block
    else
      prototypes_value
    end
  end



end
