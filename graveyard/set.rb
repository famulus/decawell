require 'set'
numbers = Set[1, 3, 4, 6, 9, 10, 11]
set = numbers.divide { |i| puts "#{i}" }
p set     # => #<Set: {#<Set: {1}>,
#            #<Set: {11, 9, 10}>,
#            #<Set: {3, 4}>,
#            #<Set: {6}>}>
