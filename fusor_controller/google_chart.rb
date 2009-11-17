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
samples = Sample.find(:all,:conditions => {:created_at => (("november 15 2009".to_date)..("november 16 2009".to_date)),:channel => 0, }).map{|r| Hornet::convert_voltage(r.sample)}

number_of_data_points = 100

resamples = samples.in_groups_of(samples.size/number_of_data_points).map{|slice| slice.average rescue 0}


puts "http://chart.apis.google.com/chart?cht=lc&chs=600x125&chd=t:#{resamples.join(",")}&chds=#{resamples.min},#{resamples.max}&chxt=y&chxr=0,#{resamples.min},#{resamples.max}"