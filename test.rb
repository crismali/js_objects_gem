require 'active_support/all'
require 'pry'
require './lib/object'
require './lib/js_object'

h = JsObject.new

h.something = 'something'

j = JsObject.new


x = ->(a, &b) { b.call a }
y = Proc.new { |a, &b| b.call a}

h.proc = x

binding.pry
