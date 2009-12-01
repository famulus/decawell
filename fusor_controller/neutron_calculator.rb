#area of sphere

area_of_sphere=4*Math::PI*(9.5)**2 #95 millimeters away from center fo grid
puts area_of_sphere

area_of_detector = 50 # this is a guess !!! 


detector_multiplier = area_of_sphere/area_of_detector

puts detector_multiplier
counts_per_second = (1.0/8.0)/60.0

puts counts_per_second * detector_multiplier