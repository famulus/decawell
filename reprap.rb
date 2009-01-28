require 'facets'


all_files = Dir["/Users/mark/Downloads/reprap-cartesian-bot-1/printed-parts/**"]

stl_files =  all_files.select{ |file|  file.include?(".stl")  }


stl_files.each do |stl|
	`stl-g -b #{stl} #{stl}.g`
	
	`cat <<EOF | mged -c #{stl}.g
B r.stl	
ae 135 -35 180
set perspective 20
zoom .40
saveview #{stl}.rt
EOF
`
`#{stl}.rt -s1024`
`pix-png -s1024 < #{stl}.rt.pix > #{stl}.png`
`open #{stl}.png`
`rm -f #{stl}.rt `
`rm -f #{stl}.g `
`rm -f #{stl}.rt.pix `
`rm -f #{stl}.rt.log`


	
end

