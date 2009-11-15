# $Id: voltmeter.rb 89 2008-04-08 20:09:05Z bikenomad $
#
# voltmeter.rb: sample program to do multi-channel multi-sample
# analog input and display repeatedly
#
# Displays all 4 differential input channel voltages repeatedly;
#
# If you enter an AO channel number [1/0], a space, and a value, followed by a
# space or CR you will set the analog output as well.
#
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
#
$suppressStderr = false

BEGIN {
  $:.push("..")
  $stderr.reopen("/dev/null") if $suppressStderr
  trap('INT') { exit }
}

if ARGV[0] == '-h'
  puts "Usage: ruby #{$0} [-d]\n   -d chooses diff channels, else unipolar."
  exit 
end

require 'daqmxbase'
# require 'arraystats'

require 'rubygems'
require 'active_record'
require 'activeresource'


ActiveRecord::Base.establish_connection(
:adapter  => 'mysql',
:database => 'fusion',
:username => 'root',
:host     => 'localhost')

class Sample < ActiveRecord::Base
end

include Daqmxbase

# Task parameters
$aiTask = nil
$aoTask = nil

# Input channel parameters
if ARGV[0] == "-d"
  $aiChans = "Dev1/ai0:3"	# all 4 diff channels, ports 0 to 3 -> ai0:3
  $nAIChans = 4
  $terminalConfig = VAL_DIFF # voltage mode
  puts("Differential channels 0:3")
else
  $aiChans = "Dev1/ai0:7"	# all 8 unipolar channels
  $nAIChans = 8
  $terminalConfig = VAL_RSE
  puts("Single-ended channels 0:7")
end
$aiMin = -10.0
$aiMax = 10.0
$units = VAL_VOLTS

# Output channel parameters
$aoChans = "Dev1/ao0:1"
$nAOChans = 2
$aoMin = 0.0
$aoMax = 5.0

# Timing parameters
$source = "OnboardClock"
$sampleRate = 5.0
$activeEdge = VAL_RISING
$sampleMode = VAL_CONT_SAMPS
$numSamplesPerChan = 5

# Data read parameters
$timeout = 10.0
# $fillMode = VAL_GROUP_BY_CHANNEL # or VAL_GROUP_BY_SCAN_NUMBER
$fillMode = VAL_GROUP_BY_SCAN_NUMBER
$bufferSize = $numSamplesPerChan * $nAIChans


# Digital Output Channel parameters
@chan = "Dev1/port0/line0:1" # all 8 bits in this port
@autoStart = autoStart = 0

HV_ENABLE = 0




$scanNum = 0

@bit_mask = 0b00000000

def set_bit(bit=0, value = true)
  if value == true
    @bit_mask = (@bit_mask | (2**bit))
  else
    @bit_mask = (@bit_mask & (~(2**bit)))
  end
  return @bit_mask
end

def high_voltage_on
  @DO_task.write_digital_scalar_u32(@autoStart, $timeout, set_bit(HV_ENABLE,true))
end
def high_voltage_off
  @DO_task.write_digital_scalar_u32(@autoStart, $timeout, set_bit(HV_ENABLE,false))
end



def doOneScan(output)
  $scanNum = $scanNum + 1
  (data, samplesPerChanRead) = readAnalog()
  samples = data.in_groups_of($nAIChans)
  samples.each_with_index do |sample,i| 

    sample.each_with_index do  |value,channel|
      Sample.create({:sample => value,:channel => channel,  })
      # output.print("channel #{channel} is at value #{value}\n") 

    end


    output.print("#{$scanNum }:#{i} #{sample.join(",")}\n") 
  end



end

def createAITask
  $aiTask = Task.new()
  puts "New Task"
  $aiTask.create_aivoltage_chan($aiChans, $terminalConfig, $aiMin, $aiMax, $units) 
  $aiTask.cfg_samp_clk_timing($source, $sampleRate, $activeEdge, $sampleMode, $numSamplesPerChan)
  $aiTask.cfg_input_buffer($numSamplesPerChan * 10)
  $aiTask.start()
  puts "Start Task"
  
end


def createDOTask
  @DO_task = Task.new()
  @DO_task.create_dochan(@chan)
  @DO_task.start()
  
end

def readAnalog
  $aiTask.read_analog_f64($numSamplesPerChan, $timeout, $fillMode, $bufferSize)
end

def createAOTask
  $aoTask = Task.new()
  $aoTask.create_aovoltage_chan($aoChans, $aoMin, $aoMax, VAL_VOLTS)
  $aoTask.start()
end

def writeAnalog(vals)
  $aoTask.write_analog_f64(1, 0, 0.5, VAL_GROUP_BY_CHANNEL, vals)
end


# begin
output = $stdout
input = $stdin
input.sync= true
output.sync= true
inputLine = ""

createAITask()
createAOTask()
createDOTask()

# high_voltage_off # turn the high voltage off by default

outputVals = [0.0, 0.0]
writeAnalog(outputVals)

while true
  doOneScan(output)
  begin
    # process additional input chars for chnum/chval AO setting
    inputLine = inputLine + input.read_nonblock(100)
    inputLine.sub!(/^([01])\s+([0-9.]+)\s*/) { |match|
      chNum = $1.to_i
      chVal = $2.to_f
      outputVals[chNum] = chVal
      writeAnalog(outputVals)
      output.puts("\nwrote #{chVal} to AO#{chNum}")
      ""
    }
    inputLine.sub!(/^hv ([01])\s*/) { |match|
      if $1.to_i == 0
        high_voltage_off
        output.puts("\nhight voltage off")        
      end
      if $1.to_i == 1
        high_voltage_on
        output.puts("\nhight voltage on")        
      end
      
    }
  rescue SystemCallError => e
    retry if e.errno == Errno::EAGAIN
  end
end

# rescue  Exception => e
#   $stderr.reopen($stdout) if $suppressStderr
#   raise
# else
#  $stderr.reopen($stdout) if $suppressStderr
#  p data
# end
