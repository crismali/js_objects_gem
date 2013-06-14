require 'active_support/all'
require 'pry'
require './lib/object'
require './lib/js_object'

h = JsObject.new

h.something = 'something'

j = JsObject.new

p = Proc.new { |arg, arg2| puts arg; puts arg2 }

h.proc = p

binding.pry
