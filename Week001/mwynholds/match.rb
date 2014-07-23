def match(input, query, n)
  m(input, query, 0) == n
end

def m(i, q, memo)
  return memo if i == ''
  return m(i[q.length..-1], q, memo + 1) if i.index(q) == 0
  m(i[1..-1], q, memo)
end

def assert(value)
  print ( value ? '.' : 'F' )
end

assert match('abcabc', 'abc', 1) == false
assert match('abcabc', 'abc', 2) == true
assert match('Hello Jello', 'ello', 2) == true
assert match('Hello Jello', 'ello', 3) == false
assert match('Ratatattat', 'at', 3) == false
assert match('Ratatattat', 'at', 4) == true
assert match('oooo', 'ooo', 2) == false # overlapping matches don’t count

puts ''
