require "ostruct"

class Prototype < OpenStruct

  private

  def method_missing(method, *arguments, &block)
    if equals_method?(method) && arguments.first.kind_of?(Proc)
      super
      # def proc as method on object
    elsif block
      self[method] = block
    else
      self[method]
    end
  end

  def equals_method?(method_name)
    method_name.to_s[-1] == "=" && method_name.to_s[-2] != "="
  end

end
