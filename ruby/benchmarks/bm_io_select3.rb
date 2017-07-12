# IO.select performance. a lot of fd

ios = []
nr = 100
max = 4096
puts "max fd: #{max} (results not apparent with <= 1024 max fd)"

(max / 2).times do
  r, w = IO.pipe
  r.close
  ios.push w
end

nr.times do
  IO.select nil, ios
end

