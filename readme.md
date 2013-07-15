# Javascript Objects Gem
## About
The not-so-creative name pretty much gives it all away. This gem allows you to use
a Javascript like object in Ruby. Some documentation as well as what I assume will
be frequently asked questions are below.
## Dependencies
Ruby 1.9 or Ruby 2.0. Might work on 1.8.7, but I haven't checked.
## How to install
Y'know, the way you normally install gems. Either: ```gem install js_objects``` or
add ```gem js_objects``` to your Gemfile and ```bundle install```.
## JsObject
JsObjects are supposed to behave like Javascript objects, meaning you can define methods
and attributes on them through a ```#["attribute"]```, calling ```#attribute=``` (where 'attribute'
is mostly whatever you want it to be). They also implement a prototypal inheritance scheme, just
like real Javascript. That means they have a prototype (either another JsObject or an instance of
the Prototype class) that you can modify or set yourself. JsObject inherits from Hash, so it has
all of the Hash methods available to it. Not all of these methods are wrapped up in by this code
so it's possible you could experience some weird behavior or get your object into a weird state.
But that's all of programming though.
### Basics
First, get a Javascript object like so:
```ruby
js_obj = JsObject.new
```
You can also give it an argument if you don't want to use its default prototype (more on prototypes later).
```ruby
JsObject.new(prototype)
```
Once you have your JS object, you can treat it pretty much like... well, an object in Javascript.
```ruby
js_obj.something = "something"
js_obj.something                # => "something"
js_obj["something"]             # => "something"
js_obj[:something]              # => "something"

js_obj[:false] = false
js_obj.false                    # => false

js_obj["nil"] = nil
js_obj[:nil]                    # => nil
```
Call a method for an attribute that hasn't been defined yet and you'll get back ```nil``` (unless
you do some stuff with the prototype, but again, more on that later).
```ruby
js_obj.never_defined            # => nil
```
### Indifference
JsObjects are _extremely_ indifferent. Strings, symbols, numbers; they're all the same to your JsObject.
When you do use numbers as keys, remember that you can't later call ```.5``` on JsObjects or any other object for that
matter. Ruby doesn't like it. It also doesn't like ```:5``` so keep that in mind too. Or not if you like errors.
```ruby
js_obj[5] = "hello"
js_obj[5]                       # => "hello"
js_obj["5"]                     # => "hello"
js_obj[:"5"]                    # => "hello"
js_obj.send(:"5")               # => "hello"
```
Be careful with anything that isn't a string, symbol, number or something that doesn't implement ```#to_s``` like
Objects do (ie, like ```"#<Object:0x007f8003825200>"```). If changing the object changes the return value of ```#to_s```
then your JsObject will treat it like a different key. A couple examples are below:
```ruby
hash = { word: "hello", number: 5 }
hash.to_s                       # => "{:word=>\"hello\", :number=>5}"
js_obj[hash] = 5
js_obj[hash]                    # => 5

hash["new"] = "something"
hash.to_s                       # => "{:word=>\"hello\", :number=>5, \"new\"=>\"something\"}"
js_obj[hash]                    # => nil


array = [1, "two", 3]
array.to_s                      # => "[1, \"two\", 3]"
js_obj[array] = 8
js_obj[array]                   # => 8

array << 4
array.to_s                      # => "[1, \"two\", 3, 4]"
js_obj[array]                   # => nil
```
Of course, anything that doesn't implement ```#to_s``` will raise an error if you try to use it as a key:
```ruby
basic = BasicObject.new
js_obj[basic]        # => NoMethodError: undefined method `to_s' for #<BasicObject:0x007f8001a1c6a0>
js_obj[basic] = 5    # => NoMethodError: undefined method `to_s' for #<BasicObject:0x007f8001a1c6a0>
js_obj[basic]        # => NoMethodError: undefined method `to_s' for #<BasicObject:0x007f8001a1c6a0> still.
```
### Blocks, Procs, and Lambdas become methods.
If you set a Proc as a property, it becomes a method, but it's still accessible via ```#[]```.
```ruby
some_proc = Proc.new{ |x| x * x }
js_obj[:proc] = some_proc
js_obj["proc"]                  # => some_proc
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
js_obj.even_newer_method("hi")  # => :hi

js_obj.num = 5
js_obj.other_num = 3
```
Hate typing ```Proc.new``` or```->```? Well, you don't have to: You can simply call an unknown
method and pass it a block to define the method on the object. You can still access the Proc object
(say if you wanted another JS object to have the same method) via ```#[]```.

```ruby
js_obj.new_method { |x| x * x }
js_obj.new_method(5)              # => 25

js_obj.another_method do |word|
  word.upcase
end
js_obj.another_method("word")     # => "WORD"
```
Also, every method set ona JS object is executed in the context of the object, so feel free to use ```self``` when defining methods
through blocks, procs, or lambdas. Just remember that you shouldn't use ```self``` in a block, proc, or lambda
that's passed as an argument to another method, unless you want that ```self``` to be the scope the proc was created
in. So this is good:
```ruby
js_obj.context_is? { self }
js_obj.context_is?              # => js_obj

js_obj.number_method do |x|
  self.num = x + self.num
  self.num + self.other_num
end

js_obj.number_method(2)         # => 10
js_obj.num                      # => 7
```
But this will be weird.
```ruby
js_obj.proc = Proc.new{ |&block| block.call }
js_obj.proc{ "this context: #{self}"" }             # => "this context: main"
```
Sick of property or method on your object? Get rid of it with ```#delete```.
```ruby
js_obj.tired = "of this property"
js_obj.delete(:tired)
js_obj.tired                    # => nil
```
## Prototype
Prototype objects share a lot in common with JsObject objects as JsObject inherits from Prototype,
which inherits from Hash. The main difference between JsObject and Prototype does not implement
prototypal inheritance which sounds like it doesn't make sense, but don't worry: It does.
Unknown methods are not deferred to a prototype, they simply return ```nil```, unless you use the
Hash method ```#default=``` or ```#default_proc``` to specify a different return value. You can make
it raise an error so you don't get immediate errors instead of ```NoMethodError``` for ```nil``` later.

Since you have access to the Prototype class, you can utilize them as a kind of OpenStruct that can call
methods or have as many different prototypal inheritance trees as you'd like.

```PROTOTYPE``` is the default prototype for JsObjects. So instead of doing this:
```ruby
js_obj.something                # => nil
js_obj.prototype.something = "something"
js_obj.something                # => "something"
```
You can just do this:
```ruby
js_obj.something                # => nil
PROTOTYPE.something = "something"
js_obj.something                # => "something"
```
Whatever you want.
## Prototypal Inheritance
[Protoypal Inheritance](http://en.wikipedia.org/wiki/Prototype-based_programming) can be read about that link. The short version is that objects don't inherit from a class, but instead inherit methods and attributes from a prototype.

For instance, let's say we have 3 objects: ```PROTOTYPE``` (the default instance of the Prototype class and the default prototype
for JsObjects), ```js_obj```, and ```js_obj2```.
```ruby
js_obj2.prototype = js_obj

PROTOTYPE == js_obj.prototype               # => true
js_obj2.prototype == js_obj                 # => true
js_obj2.prototype.prototype == PROTOTYPE    # => true
```
If a method or attribute is defined somewhere in an object's inheritance tree, then that value will bubble up.
```ruby
PROTOTYPE.something = "something"

PROTOTYPE.something                          # => "something"
js_obj.something                             # => "something"
js_obj2.something                            # => "something"

js_obj.something_else = "something else"
PROTOTYPE.something_else                     # => nil
js_obj.something_else                        # => "something else"
js_obj2.something_else                       # => "something else"

js_obj2.another_thing = "anothing thing"

PROTOTYPE.another_thing                          # => nil
js_obj.another_thing                             # => nil
js_obj2.another_thing                            # => "another thing"
```
Procs, blocks, and lambdas don't behave so weirdly though. If you have a proc set on an object's prototype,
then calling it on the child object will invoke in the context of the child object. So:

```ruby
PROTOTYPE.set_something { self.something = "something" }
PROTOTYPE.something                        # => nil
js_obj.something                           # => nil

js_obj.set_something
js_obj.something                           # => "something"
PROTOTYPE.something                        # => nil
```
## Frequently Asked Questions (aka FAQ)
### Why would anyone want this?
* Why do you gotta hate?
* If they really liked Javascript objects but had to write Ruby.
* If they hate brackets and would rather just call methods on their objects
* If they hate classical inheritance and prefer prototypal inheritance.
* If they wanted really badass OpenStructs with prototypal inheritance.
### Why not make this out of OpenStruct instead of Hash?
Then it wouldn't work in Ruby 1.9.3. OpenStructs only got the cool new ```#[]``` syntax in Ruby 2.0.
Also, OpenStructs are pretty bare methodwise while Hashes already have a ton of methods.
That is, I'd rather wrap those methods with super than write a bunch new methods for OpenStruct.
Granted, I haven't actually wrapped a lot of those methods yet, but I probably will at some point.
### Why not make this out of HashWithIndifferentAccess?
It was pretty easy to make it pretty indifferent without pulling in _all_ of ActiveSupport, so I did
that instead. Plus, in Javascript you can't really use Arrays and Objects as keys, so partially taking
that away actually makes this more like Javascript. There are always tradeoffs and in this case not using
ActiveSupport costs us being able to use some objects as keys. That's fine with me.
### Everyone hates Javascript and prefers Ruby, so why make Ruby more like Javascript?
Again, why do you gotta hate? In particular, on Javascript? I understand what you mean, but
this was a good learning exercise. Besides, prototypal inheritance and passing procs around can actually
create some pretty expressive and powerful code. Maybe this will help you practice Javascript and you'll
eventually learn to love it.



