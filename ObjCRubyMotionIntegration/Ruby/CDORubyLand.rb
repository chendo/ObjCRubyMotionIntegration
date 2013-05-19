class CDORubyland
  def run
    retain # Otherwise this instance gets deallocated in Obj-C land and we get EXC_BAD_ACCESS
    RACSignal.interval(1.0).each! do |date|
      NSLog("This is from Ruby: #{date}")
    end
  end
end
