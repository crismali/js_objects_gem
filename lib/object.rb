require 'active_support/all'

OBJECT = Prototype.new

# class << OBJECT

#   def method_missing(method, *arguments)
#     if method.to_s[-1] == '='
#       attr_name = method.to_s.chop!.to_sym
#       self[attr_name] = arguments.first
#       self.define_singleton_method method do |new_value|
#         self[attr_name] = new_value
#       end

#       self.define_singleton_method attr_name do
#         self[attr_name]
#       end
#     else
#       nil
#     end
#   end

# end
