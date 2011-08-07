#!ruby


require 'xrvg'
include XRVG





def body(minor_radius)
	# units in mm
	# minor_radius = 10.0
	# major_radius = 100

	@tape_major = tape_major = 4.0

	# @tape_minor = tape_minor = 0.3
	@tape_minor = tape_minor = 0.055

	# we rasterize the radius of the circle to the thickness of the YBCO, then we solve for the intersecrion of the each slice line and the circle

	slice_count = (minor_radius / tape_minor).floor # slice count for one radius
	slice_count += 1 if slice_count.odd? # force to be even so it's symmetrical 

	row_positions = slice_count.times.map{|slice| (tape_minor * slice)  }

	row_counts = row_positions.map do |row|
		# puts "y:#{row}"	
		intersection =  Math.sqrt(((minor_radius**2.0)- (row**2.0))) 
		columns_count_for_row = ((2.0*intersection)/tape_major).floor	
	end

	row_counts = row_counts.reverse + row_counts #mirror to make the full circle


	turns = row_counts.inject(0.0){|sum,n| sum+n}
	major_radius = minor_radius*3.0
	average_circumference = 2.0*Math::PI*major_radius 
	critical_current = 80.0
	ampturns = (critical_current*turns)
	magnetic_constant = (4.0*Math::PI * (10.0**(-7.0)))


	b_field_at_center_of_coil = (ampturns * magnetic_constant) / (2.0* (minor_radius/1000.0))

	dollar_per_meter_ybco = 48.0
	cost = average_circumference*turns*6.0/1000.0*dollar_per_meter_ybco

	puts "minor_radius:#{minor_radius} mm"
	puts "tape dimentions: #{tape_major} mm by #{tape_minor} mm "
	# puts "major_radius:#{major_radius}"
	puts "major_outside_diameter:#{minor_radius*6} mm"
	puts "TURNS:#{turns}"
	puts "critical_current: #{critical_current} amps"
	puts "Ampturns:#{ampturns}"
	# puts "b_field_at_center_of_coil:#{format("%.6f\n",b_field_at_center_of_coil)}"
	puts "b_field_at_center_of_coil:#{b_field_at_center_of_coil} tesla"
	# 
	# puts "circumference:#{average_circumference}"
	puts "tape required for one coil:#{average_circumference*turns/1000.0} meters"
	puts "tape required for 6 coils:#{average_circumference*turns*6.0/1000.0/1000.0} kilometers"
	puts "cost for 6 coils:#{cost} dollars"
	# puts row_counts

	# row_counts.each do |row|
	# 	row.times{print "_" }
	# 	puts "\r"
	# end
	return minor_radius,b_field_at_center_of_coil,cost, row_counts

end

def rect(center, height, width)

	Line[ :points, [        
		(center + V2D[(width/2),(height/2)])  ,
		(center + V2D[(width/2),0-(height/2)])  ,

		(center - V2D[(width/2),(height/2)])  ,
		(center - V2D[(width/2),0-(height/2)])  ,
		(center + V2D[(width/2),(height/2)])  ,

		# V2D::O, V2D::X * (height/2),V2D::Y	
		] ]
	end




	# render = SVGRender[ :filename, "test.svg" ,:imagesize,"6.5cm"]
	render = SVGRender[ :filename, "test.svg" ,:imagesize,"30cm"]

	(2...12).each do |size|
		size = size.to_f
		result = 	body(size.to_f)
		row_counts = result[3].select{|r|r>0} # remove rows with no counts
		puts "radius: #{result[0]}, efficiency: #{result[1]/result[2]}, B field: #{result[1]}, Cost: $#{result[2]}"

		puts "_________________________________________________________________"

		origin_i = V2D[0,1.1*size**2]
		render.add( Circle[ :center, V2D[0,1.1*size**2], :radius, size.to_f ] )
		render.add( Circle[ :center, V2D[size*2.3,1.1*size**2], :radius,size.to_f ] )
		render.add( Circle[ :center, origin_i, :radius, 0.2 ] )

		coil_offset = V2D[(0-(row_counts.size.to_i)*@tape_minor/2)+(@tape_minor/2),@tape_major/2]
		# render.add( Circle[ :center, origin_i+coil_offset, :radius, 0.4 ] )
			row_counts.each_with_index do |row,index|
			# puts "index:#{index},winds: #{row}"
			center_offset = row*@tape_major/2

			row.times do |wind|
				render.add( rect(origin_i+coil_offset+V2D[index*@tape_minor,wind*@tape_major-center_offset],@tape_major,@tape_minor),Style[ :strokewidth, 0.01,:stroke,Color.orange ])

			end

		end
		render.end


	end
