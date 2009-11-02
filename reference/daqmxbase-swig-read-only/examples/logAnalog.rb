# $Id: logAnalog.rb 93 2009-01-27 20:24:09Z bikenomad $
#
# logAnalog.rb: sample program to do multi-channel multi-sample
# analog input and output as CSV
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
require 'arraystats'

include Daqmxbase

# Task parameters
$aiTask = nil
$aoTask = nil

# Input channel parameters
if ARGV[0] == "-d"
  $aiChans = "Dev1/ai0:3"	# all 4 diff channels
  $nAIChans = 4
  $terminalConfig = VAL_DIFF
  puts("Differential channels 0:3")
else
  $aiChans = "Dev1/ai0:7"	# all 8 unipolar channels
  $nAIChans = 8
  $terminalConfig = VAL_RSE
  puts("Single-ended channels 0:7")
end
$aiMin = 0.0
$aiMax = 2.0
$units = VAL_VOLTS

# Output channel parameters
$aoChans = "Dev1/ao0:1"
$nAOChans = 2
$aoMin = 0.0
$aoMax = 5.0

# Timing parameters
$source = "OnboardClock"
$sampleRate = 1000.0
$activeEdge = VAL_RISING
$sampleMode = VAL_CONT_SAMPS
$numSamplesPerChan = 1000

# Data read parameters
$timeout = 10.0
$fillMode = VAL_GROUP_BY_CHANNEL # or VAL_GROUP_BY_SCAN_NUMBER
$bufferSize = $numSamplesPerChan * $nAIChans

$scanNum = 0

def doOneScan(output)
  $scanNum = $scanNum + 1
  (data, samplesPerChanRead) = readAnalog()
  # output.printf(",%d", $scanNum)
  $nAIChans.times { |c| 
    avg = data[c * samplesPerChanRead, samplesPerChanRead].average
    output.printf(",%.4f", avg)
  }
  output.printf("\n")
end

def createAITask
  $aiTask = Task.new()
  $aiTask.create_aivoltage_chan($aiChans, $terminalConfig, $aiMin, $aiMax, $units) 
  $aiTask.cfg_samp_clk_timing($source, $sampleRate, $activeEdge, $sampleMode, $numSamplesPerChan)
  $aiTask.cfg_input_buffer($numSamplesPerChan * 10)
  $aiTask.start()
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


begin
  output = $stdout
  input = $stdin
  input.sync= true
  output.sync= true
  inputLine = ""

  createAITask()

  createAOTask()
  outputVals = [0.0, 0.0]
  writeAnalog(outputVals)

  started = Time.now

  while true
    output.printf("%.1f", Time.now-started)
    doOneScan(output)
  end

rescue  Exception => e
  $stderr.reopen($stdout) if $suppressStderr
  raise
else
 $stderr.reopen($stdout) if $suppressStderr
 p data
end
