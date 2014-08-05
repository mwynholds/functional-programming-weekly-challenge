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

# todo: use foldR to implement this
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

walk = (tree) ->
  return [] unless tree?
  [left, middle, right] = tree
  walk(left).concat([middle]).concat(walk(right))

mid = (items) ->
  return [null, items[0], null] if items.length == 1
  return [items[0], items[1], null] if items.length == 2
  midpoint = Math.floor(items.length / 2)
  [items[0..midpoint-1], items[midpoint], items[midpoint+1..]]

midsort = (items) ->
  return [] unless items?
  [left, middle, right] = mid items
  #[middle].concat(midsort(left)).concat(midsort(right))
  [middle].concat(midsort(right)).concat(midsort(left))

bbst = (items) ->
  f = (item, memo) ->
    return memo unless item?
    return [null, item, null] unless memo?
    [left, middle, right] = memo
    if item < middle then [f(item, left), middle, right] else [left, middle, f(item, right)]
  bst = foldL f, null, items
  sorted = walk bst
  foldL f, null, midsort(sorted)

exists = (fun, tree) ->
  return false unless tree?
  [left, middle, right] = tree
  return true if fun(middle)
  return fun(middle) or exists(fun, left) or exists(fun, right)

mappedBbst = (fun, tree) ->
  bbst mapL(fun, walk(tree))

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

tree = [[[null, 1, null], 2, [null, 3, null]], 4, [[null, 5, null], 6, [null, 7, null]]]
assertEqual bbst([1, 2, 3, 4, 5, 6, 7]), tree
assertEqual bbst([3, 7, 2, 4, 1, 6, 5]), tree

is7 = (value) -> value == 7
is8 = (value) -> value == 8
assertEqual exists(is7, tree), true
assertEqual exists(is8, tree), false

weirdMult = (value) -> if value % 2 == 0 then value * 10 else value * 100
# [100, 20, 300, 40, 500, 60, 700] -> [20, 40, 60, 100, 300, 500, 700]
tree2 = [[[null, 20, null], 40, [null, 60, null]], 100, [[null, 300, null], 500, [null, 700, null]]]

assertEqual mappedBbst(weirdMult, tree), tree2

console.log ''
