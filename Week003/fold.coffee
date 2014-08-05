isEqual = (actual, expected) ->
  if actual? && actual.length?
    value = actual.length == expected.length &&
      actual.every (elem, i) -> isEqual(elem, expected[i])
  else
    value = actual == expected

assertEqual = (actual, expected) ->
  value = isEqual actual, expected
  p = (obj) -> if obj? && obj.length? then JSON.stringify(obj) else obj
  if !value
    console.log ''
    console.log "#{p actual} != #{p expected}"
  process.stdout.write ( if value then '.' else 'F' )

foldR = (fun, memo, items) ->
  return memo if items.length == 0
  [rest..., last] = items
  foldR fun, fun(last, memo), rest

foldL = (fun, memo, items) ->
  return memo if items.length == 0
  [first, rest...] = items
  foldL fun, fun(first, memo), rest

mapL = (fun, items) ->
  f = (item, memo) -> memo.concat([fun(item)])
  foldL f, [], items

filterL = (fun, items) ->
  f = (item, memo) -> ( if fun(item) then memo.concat([item]) else memo )
  foldL f, [], items

find = (fun, items) ->
  (filterL fun, items)[0] ? null

pairs = (file) ->
  fs = require 'fs'
  contents = fs.readFileSync file, { encoding: 'ascii' }
  memo = { last: null, pairs: {} }
  words = contents.split /\s/
  pairify = (item, memo) ->
    item = item.toLowerCase().replace(/^\W*/, '').replace(/\W*$/, '').trim()
    return memo if item == ''
    #console.log "|#{item}|"
    if memo.last == null
      memo.last = item
    else
      pair = [memo.last, item].sort().join ':'
      count = memo.pairs[pair] || 0
      count += 1
      memo.pairs[pair] = count
      memo.last = item

  (pairify item, memo) for item in words
  result = ( { pair, count } for pair, count of memo.pairs )
  result.sort (a, b) ->
    b.count - a.count

# assertions

mc = (item, memo) -> memo.concat([item])
assertEqual foldR(mc, [], [5, 4, 25]), [25, 4, 5]
assertEqual foldL(mc, [], [5, 4, 25]), [5, 4, 25]

t2 = (item) -> item * 2
assertEqual mapL(t2, [10, 20, 30]), [20, 40, 60]

e2 = (item) -> item == 2
assertEqual filterL(e2, [1, 2, 3, 2]), [2, 2]

assertEqual find(e2, [1, 2, 3, 2]), 2
assertEqual find(e2, [1, 3, 4, 5]), null

console.log ''

result = pairs './moby10b.txt'
console.log result[0..2]
