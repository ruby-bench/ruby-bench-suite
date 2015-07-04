[10_000,1_000_000,100_000_000].each do |n|
  ary = Array.new(n,0)
  GC.start
  ary.shift

  (0..4).each do |i|
    ary = Array.new(n,0)
    GC.start
    ary.shift(i)
  end
end
