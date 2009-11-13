# $Id$
#-----------------------------------------------------------------------
# ruby-daqmxbase: A SWIG interface for Ruby and the NI-DAQmx Base data
# acquisition library.
# 
# Copyright (C) 2007 Ned Konz
# 
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#-----------------------------------------------------------------------
$suppressStderr = false

BEGIN { $stderr.reopen("/dev/null") if $suppressStderr }

require 'daqmxbase'
require 'rubygems'
require 'active_record'

ActiveRecord::Base.establish_connection(
:adapter  => 'mysql',
:database => 'fusion',
:username => 'root',
:host     => 'localhost')


# Task parameters
task = nil

# Channel parameters
chan = "Dev1/port0/line0:1" # all 8 bits in this port

# Data read parameters
@timeout = timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
numSampsPerChan = 1
@autoStart = autoStart = 0




# begin
task = Daqmxbase::Task.new()
@task = task
task.create_dochan(chan);
task.start()

def step()
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000000)
  sleep(0.1)
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000001)
  sleep(0.1)
  puts "step"
  

end

def increase
  sleep(0.1)
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000011)
  sleep(0.1)
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000001)
  sleep(0.1)
  puts "increase"

end
def decrease
  sleep(0.1)
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000010)
  sleep(0.1)
  @task.write_digital_scalar_u32(@autoStart, @timeout, 0b00000000)
  sleep(0.1)
  puts "decrease"

end

def zero
  decrease
  64.times  do 
    step
  end
end

started = Time.now
zero
10.times do |time|
  increase
  16.times do 
    step() 
  end
  decrease
  16.times do 
    step() 
  end

end
# task.write_digital_scalar_u32(autoStart, timeout, 0x00)
# task.write_digital_scalar_u32(autoStart, timeout, 0xFF)
# sleep(0.10 - (Time.now - started))
# task.write_digital_scalar_u32(autoStart, timeout, 0x00)
# sleep(0.10)
# (0..7).to_a.collect { |n| 2**n }.each  do |n|
#   task.write_digital_scalar_u32(autoStart, timeout, n)
# end

puts("")

# rescue  Exception => e
#   $stderr.reopen($stdout) if $suppressStderr
#   raise
# else
#  $stderr.reopen($stdout) if $suppressStderr
# end

# vim: ft=ruby ts=2 sw=2 et