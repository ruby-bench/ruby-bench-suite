a = ''
a.instance_eval do
  @a = :a
  @b = :b
  @c = :c
end
100000.times { a = Marshal.load(Marshal.dump(a)) }
