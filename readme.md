# Javascript Objects Gem

## About
The not-so-creative name pretty much gives it all away. This gem allows you to use
a Javascript like object in Ruby. Some documentation as well as what I assume will
be frequently asked questions are below.

## Dependency
You'll need these gems to use Javascript Objects:

* ActiveSupport (or at least the HashWithIndifferentAccess)

## How to install
Y'know, the way you normally install gems. Either: ```gem install js_objects``` or
add ```gem js_objects``` to your Gemfile and ```bundle install```.

## Syntaxes and ways to use this thing
First, get a Javascript object like so:
```ruby
js_obj = JsObject.new
```
You can also give it an argument if you don't want to use its default prototype (more on prototypes later)
```ruby
JsObject.new(prototype)
```
Once you have your JS object, you can treat it pretty much like... well, an object in Javascript.
```ruby
js_obj.something = "something"
js_obj.something                # => "something"
js_obj['something']             # => "something"
js_obj[:something]              # => "something"

js_obj[:false] = false
js_obj.false                    # => false

js_obj['nil'] = nil
js_obj[:nil]                    # => nil
```
Call a method for an attribute that hasn't been defined yet and you'll get back ```nil``` (unless
you do some stuff with the prototype, but again, more on that later).
```ruby
js_obj.never_defined            # => nil
```
If you set a Proc as a property, it becomes a method, but it's still accessible
via #[]
```ruby
some_proc = Proc.new{ |x| x * x }
js_obj[:proc] = some_proc
js_obj['proc']                  # => some_proc
js_obj.proc(3)                  # => 9
```
You can even set Procs that take Procs as methods:
```ruby
some_lambda = ->(x, &block){ block.call x }
js_obj.lambda = some_lambda
js_obj[:lambda]                 # => some_lambda
js_obj.lambda(2) { |z| z + 1 }  # => 3
js_obj.lambda(2, &some_proc)    # => 4

js_obj.new_method(&some_lambda)
js_obj.lambda(2) { |z| z + 1 }  # => 3

js_obj.even_newer_method { |x| x.to_sym }
js_obj.even_newer_method('hi')  # => :hi

js_obj.num = 5
js_obj.other_num = 3
```
Hate typing ```Proc.new``` or```->```? Well, you don't have to: You can simply call an unknown
method and pass it a block to define the method on the object. You can still access the Proc object
(say if you wanted another JS object to have the same method) via #[]. Also, every method set on
a JS object is executed in the context of the object, which is pretty neat.
```ruby
js_obj.number_method do |x|
  self.num = x + self.num
  self.num + self.other_num
end

js_obj.number_method(2)         # => 10
js_obj.num                      # => 7
```
Sick of property or method on your object? Get rid of it with #delete
```ruby
js_obj.tired = "of this property"
js_obj.delete :tired
js_obj.tired                    # => nil
```


## Frequently Asked Questions (aka FAQ)

### Why would anyone want this?

* If they really liked Javascript objects but had to write Ruby.
* If they hate brackets and would rather just call methods on their objects
* If they hate classical inheritance and prefer prototypal inheritance.
* If they wanted really badass OpenStructs with prototypal inheritance.


