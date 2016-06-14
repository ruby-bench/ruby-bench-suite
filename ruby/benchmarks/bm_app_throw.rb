i = 0
while i<300000
  i += 1
  catch(:ball) do
    throw(:ball)
  end
end
