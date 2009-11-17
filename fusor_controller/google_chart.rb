# http://chart.apis.google.com/chart?cht=lc&chs=200x125&chd=t:40,60,60,45,47,75,70,72

require 'rubygems'
require 'activerecord'
require 'devices'

ActiveRecord::Base.establish_connection(
:adapter  => 'mysql',
:database => 'fusion',
:username => 'root',
:host     => 'localhost')

class Sample < ActiveRecord::Base
end

class Array
	def average
		inject(0.0) { |sum, e| sum + e } / length
	end
end

class Float
	def round_to(x)
		(self * 10**x).round.to_f / 10**x
	end
end

# samples = Sample.find(:all, :conditions => {:channel =>0, :created_at => (Time::now - 2000.minutes .. Time::now)}).map{|r| r.sample}

channel_bank = [Hornet,GlassmanVoltage,GlassmanCurrent,Stec]
number_of_data_points = 100

channel_bank.each_with_index do |@channel_proc, index| #generate a chart for each channel
	samples = Sample.find(:all,:conditions => {:created_at => (("november 15 2009 16:50:29 ".to_time)..("november 18 2009 19:11:29".to_time)),:channel => index, },:order => "created_at ASC").map{|r| @channel_proc.interpret_voltage(r.sample)}
	resamples = samples.in_groups_of(samples.size/number_of_data_points).map{|slice| slice.average rescue 0} 
	url = "http://chart.apis.google.com/chart?cht=lc&chs=600x125&chd=t:#{resamples.join(",")}&chds=#{resamples.min},#{resamples.max}&chxt=y&chxr=0,#{resamples.min},#{resamples.max}&chtt=#{@channel_proc.title.gsub(" ","+")}"
	puts url
	puts `open -a Safari '#{url}'`
end


