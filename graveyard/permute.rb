 class Array
   # The accumulation is a bit messy but it works ;-)
   def sequence(i = 0, *a)
     return [a] if i == size
     self[i].map {|x|
       sequence(i+1, *(a + [x]))
     }.inject([]) {|m, x| m + x}     # this has to be used instead of flatten so I can sequence something
                                     # like [[[4]]] -> [[[4]]] rather than -> [[4]]; ruby 1.9 has an option for flatten
   end
 end
 
 
 p [(0..3), [4,6]].sequence             #=> [[0, 4], [0, 6], [1, 4], [1, 6], [2, 4], [2, 6], [3, 4], [3, 6]]      
 p [(0..3).collect, [4, 6]].sequence
 
 
 
 # http://wiki.rubygarden.org/Ruby/page/show/ArrayPermute
 # Permute an array, and call a block for each permutation
 # Author: Paul Battley
 
     class Array
         def permute(prefixed=[])
             if (length < 2)
                 # there are no elements left to permute
                 yield(prefixed + self)
             else
                 # recursively permute the remaining elements
                 each_with_index do |e, i|
                     (self[0,i]+self[(i+1)..-1]).permute(prefixed+[e]) { |a| yield a }
                 end
             end
         end
     end
 
 
 %w[a b c].permute { |x| puts(x.join('')) } 
 
 [0, 1, 2, 3 ].permute { |x| puts(x.join('-')) } 
 
 
 
 # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/32844
 # Author: Steven Grady
 
 class Array
   def permutations
     return [self] if size < 2
     perm = []
     each { |e| (self - [e]).permutations.each { |p| perm << ([e] + p) } }
     perm
   end
 end
 
 p (1..20).to_a.permutations
 
 
 
 # http://blade.nagaokaut.ac.jp/~sinara/ruby/math/combinatorics/array-perm.rb
 # Author: Shin-ichiro Hara
 # For many more permutation snippets see: 
 # http://blade.nagaokaut.ac.jp/~sinara/ruby/math/combinatorics/
 
 class Array
   def perm(n = size)
     if size < n or n < 0
     elsif n == 0
       yield([])
     else
       self[1..-1].perm(n - 1) do |x|
 	(0...n).each do |i|
 	  yield(x[0...i] + [first] + x[i..-1])
 	end
       end
       self[1..-1].perm(n) do |x|
 	yield(x)
       end
     end
   end
 end
 
 if $0 == __FILE__
   ["a", "b", "c", "d"].perm(3) do |x|  
     p x
   end
 end
 
 
 
 # Based on:
 # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/139290
 # Author: Endy Tjahjono
 
 class String
    def perm
        return [self] if self.length < 2
        ret = []
     
        0.upto(self.length - 1) do |n|
           #rest = self.split('')                
           rest = self.split(//u)            # for UTF-8 encoded strings
           picked = rest.delete_at(n)
           rest.join.perm.each { |x| ret << picked + x }
        end
 
        ret
    end
 end
 
 p "abc".perm      #=>  ["abc", "acb", "bac", "bca", "cab", "cba"]
 
 
 
 require 'permutation'
 
 # http://permutation.rubyforge.org 
 # http://permutation.rubyforge.org/doc/classes/Permutation.html
 # sudo gem install permutation --remote
 # For more examples see permutation-0.1.4/examples/tsp.rb and permutation_0.1.4/lib/permutation.rb:
 # curl http://files.rubyforge.vm.bytemark.co.uk/permutation/permutation-0.1.4.tgz | tar xfz -
 
 perm = Permutation.new(3)   
 p perm.map { |p| p.value }        #=>  [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
