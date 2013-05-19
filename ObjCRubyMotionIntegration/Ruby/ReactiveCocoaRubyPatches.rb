# From https://github.com/kastiglione/RACSignupDemo-RubyMotion

class RACSignal
  # RubyMotion's bridge support does not handle Objective-C methods that take block
  # arguments typed as id so as to take blocks of varying arity. To work around this,
  # an Objective-C category has been created with numbered methods, each explicitly
  # typed, which pass the arguments to the original method.
  #
  # The same work-around will be required for all other methods that take an id block.
  def self.reduceLatest(*signals, &block)
    raise "Block must take #{signals.size} arguments to match the number of signals." if signals.size != block.arity
    case block.arity
    when 1 then combineLatest(signals, reduce1: block)
    when 2 then combineLatest(signals, reduce2: block)
    when 3 then combineLatest(signals, reduce3: block)
    when 4 then combineLatest(signals, reduce4: block)
    when 5 then combineLatest(signals, reduce5: block)
    end
  end

  # In RubyMotion, signals for boolean properties are resulting in values of 0 and 1,
  # both of which evaluate as true in Ruby. Consequently the stream is full of true
  # values. The work-around is to explicitly map the values to a boolean.
  # See #to_bool defined below for TrueClass, FalseClass and Fixnum
  def boolean
    map ->(primitive) { primitive.to_bool }
  end

  # Create ! versions of a few ReactiveCocoa methods, allowing the methods to take
  # a block the Ruby way and avoid explicit lambda expressions.
  # This conflicts with the common semantics of using ! to imply the method modifies
  # the receiver, but the alternatives (ex: map_, map?) are less appealing.
  def map!(&block)
    map(block)
  end

  def filter!(&block)
    filter(block)
  end

  def each!(&block)
    subscribeNext(block)
    self
  end

  def complete!(&block)
    subscribeCompleted(block)
    self
  end

  alias_method :each, :each!

  def add_signal(&block)
    addSignalBlock(block)
  end

  def reduce!(initial, &block)
    scanWithStart(initial, combine: block)
  end
  alias_method :inject!, :reduce!

  def first
    take(1)
  end

  def main_thread
    deliverOn(RACScheduler.mainThreadScheduler)
  end

  def background
    deliverOn(RACScheduler.scheduler)
  end

  def latest
    switchToLatest
  end

  # Map a signal of truth values to a true value and false value.
  def flip_flop(trueValue, falseValue)
    map! do |truth|
      truth ? trueValue : falseValue
    end
  end
end

[TrueClass, FalseClass].each do |boolClass|
  boolClass.class_exec do
    def to_bool; self end
  end
end

class Fixnum
  def to_bool; self != 0 end
end

class RACMotionKeyPathAgent
  def initialize(object, observer)
    @object = object
    @observer = observer
    @keyPath = []
  end

  def key(key)
    @keyPath << key.to_s
    self
  end

  def method_missing(method, *args)
    # Conclude when the method corresponds to a RACSignal method; see to RACAble() macro
    if RACSignal.method_defined?(method)
      @object.rac_signalForKeyPath(keyPath, observer: @observer).send(method, *args)

    # Conclude when assigning a signal; see RAC() macro
    elsif args.size == 1 && args.first.is_a?(RACSignal) && method.to_s.end_with?('=')
      key(method)
      @object.rac_deriveProperty(keyPath.chop, from: args.first)

    # Conclude when calling a non-RAC method with a signal argument, lift it
    elsif !@keyPath.empty? && args.any? { |arg| arg.is_a?(RACSignal) }
      # method_missing sets method to just the first argument's portion of the called selector.
      # Construct the full selector. Obviously works only for Objective-C methods.
      options = args.last.is_a?(Hash) ? args.pop : {}
      selector = [method].concat(options.keys).join(':') << ':'
      objects = args.concat(options.values)
      target = @object.valueForKeyPath(keyPath)
      if target.respondsToSelector(selector)
        # RubyMotion can't splat an array into a varags paramter. Case it out.
        o = objects
        case objects.size
        when 2 then target.rac_liftSelector(selector, withObjects: o[0], o[1])
        when 3 then target.rac_liftSelector(selector, withObjects: o[0], o[1], o[2])
        when 4 then target.rac_liftSelector(selector, withObjects: o[0], o[1], o[3], o[4])
        end
      else
        raise "#{target.inspect} (via keyPath '#{keyPath}') does not respond to `#{selector}`"
      end

    # Continue when simple getter is called and extend the key path
    else
      key(method)
    end
  end

  def keyPath
    @keyPath.join('.')
  end
  alias_method :to_s, :keyPath
end

class Object
  def rac(object=self)
    RACMotionKeyPathAgent.new(object, self)
  end
  # Capitalized doesn't work as well due to the required () to avoid it being treated as a constant
  alias_method :RAC, :rac
end
