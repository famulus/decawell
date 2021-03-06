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


# samples = Sample.find(:all, :conditions => {:channel =>0, :created_at => (Time::now - 2000.minutes .. Time::now)}).map{|r| r.sample}

number_of_data_points = 250

CHANNEL_BANK.each_with_index do |@channel_proc, index| #generate a chart for each channel
	sample_records = Sample.find(:all,:conditions => {:created_at => (("november 15 2009 16:50:29 ".to_time)..("november 15 2009 19:11:29".to_time)),:channel => index, },:order => "created_at ASC")
	samples = sample_records.map{|r| @channel_proc.interpret_voltage(r.sample)}
	resamples = samples.in_groups_of(samples.size/number_of_data_points).map{|slice| slice.average.round_to(4) rescue 0} 
	url = "http://chart.apis.google.com/chart?cht=lc&chs=438x125&chd=t:#{resamples.join(",")}&chds=#{resamples.min},#{resamples.max}&chxt=y,x&chxr=0,#{resamples.min},#{resamples.max}|1,0,#{(sample_records.last.created_at - sample_records.first.created_at)/60.to_i}&chxl=0:test&chtt=#{@channel_proc.title.gsub(" ","+")}"
	puts "<img src=\"#{url}\" alt=\"\" />"
  # puts `open -a Safari '#{url}'`
end


