class Object
  # Extracts the singleton class, so that metaprogramming can be done on it.
  #
  # @return <Class> The meta class.
  #
  # @example [Setup]
  #   class MyString < String; end
  #
  #   MyString.instance_eval do
  #     define_method :foo do
  #       puts self
  #     end
  #   end
  #
  #   MyString.meta_class.instance_eval do
  #     define_method :bar do
  #       puts self
  #     end
  #   end
  #
  #   def String.add_meta_var(var)
  #     self.meta_class.instance_eval do
  #       define_method var do
  #         puts "HELLO"
  #       end
  #     end
  #   end
  #
  # @example
  #   MyString.new("Hello").foo #=> "Hello"
  # @example
  #   MyString.new("Hello").bar
  #     #=> NoMethodError: undefined method `bar' for "Hello":MyString
  # @example
  #   MyString.foo
  #     #=> NoMethodError: undefined method `foo' for MyString:Class
  # @example  
  #   MyString.bar
  #     #=> MyString
  # @example  
  #   String.bar
  #     #=> NoMethodError: undefined method `bar' for String:Class
  # @example
  #   MyString.add_meta_var(:x)
  #   MyString.x #=> HELLO
  #
  # @details [Description of Examples]
  #   As you can see, using #meta_class allows you to execute code (and here,
  #   define a method) on the metaclass itself. It also allows you to define
  #   class methods that can be run on subclasses, and then be able to execute
  #   code on the metaclass of the subclass (here MyString).
  #
  #   In this case, we were able to define a class method (add_meta_var) on
  #   String that was executable by the MyString subclass. It was then able to
  #   define a method on the subclass by adding it to the MyString metaclass.
  #
  #   For more information, you can check out _why's excellent article at:
  #   http://whytheluckystiff.net/articles/seeingMetaclassesClearly.html
  def meta_class() class << self; self end end

  # @return <TrueClass, FalseClass>
  #   True if the empty? is true or if the object responds to strip (e.g. a
  #   String) and strip.empty? is true, or if !self is true.
  #
  # @example [].blank?         #=>  true
  # @example [1].blank?        #=>  false
  # @example [nil].blank?      #=>  false
  # @example nil.blank?        #=>  true
  # @example true.blank?       #=>  false
  # @example false.blank?      #=>  true
  # @example "".blank?         #=>  true
  # @example "     ".blank?    #=>  true
  # @example " hey ho ".blank? #=>  false
  def blank?
    if respond_to?(:empty?) && respond_to?(:strip)
      empty? or strip.empty?
    elsif respond_to?(:empty?)
      empty?
    else
      !self
    end
  end

  # @param name<String> The name of the constant to get, e.g. "Merb::Router".
  #
  # @return <Object> The constant corresponding to the name.
  def full_const_get(name)
    list = name.split("::")
    obj = Object
    list.each {|x| obj = obj.const_get(x) }
    obj
  end

  # Defines module from a string name (e.g. Foo::Bar::Baz)
  # If method already exists, no exception raised.
  #
  # @param name<String> The name of the full module name to make
  #
  # @return <NilClass>
  def make_module(str)
    mod = str.split("::")
    start = mod.map {|x| "module #{x}"}.join("; ")
    ender = (["end"] * mod.size).join("; ")
    self.class_eval <<-HERE
      #{start}
      #{ender}
    HERE
  end

  # @param duck<Symbol, Class, Array> The thing to compare the object to.
  #
  # @note
  #   The behavior of the method depends on the type of duck as follows:
  #   Symbol:: Check whether the object respond_to?(duck).
  #   Class:: Check whether the object is_a?(duck).
  #   Array::
  #     Check whether the object quacks_like? at least one of the options in the
  #     array.
  #
  # @return <TrueClass, FalseClass>
  #   True if the object quacks like duck.
  def quacks_like?(duck)
    case duck
    when Symbol
      self.respond_to?(duck)
    when Class
      self.is_a?(duck)
    when Array
      duck.any? {|d| self.quacks_like?(d) }
    else
      false
    end
  end
  
  # @param arrayish<#include?> Container to check, to see if it includes the object.
  # @param *more<Array>:: additional args, will be flattened into arrayish
  #
  # @return <TrueClass, FalseClass>
  #   True if the object is included in arrayish (+ more)
  #
  # @example 1.in?([1,2,3]) #=> true
  # @example 1.in?(1,2,3) #=> true
  def in?(arrayish,*more)
    arrayish = more.unshift(arrayish) unless more.empty?
    arrayish.include?(self)
  end
end
