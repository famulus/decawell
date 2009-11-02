#! /usr/bin/env ruby
# $Id$
#
# toaster.rb: sample program to do multi-channel multi-sample
# analog input
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
# This was put together for instrumenting a toaster.
#
# Connections:
#
# USB-6009/1 (GND)
# USB-6009/2 (A0) thermistor/20K junction
# USB-6009/3 (A4) conn. to gnd (1)
# USB-6009/4 (GND) 
# USB-6009/5 (A1) humidity sensor HIH-3610 output
# USB-6009/6 (A5) humid sensor - supply; conn to GND (9)
# USB-6009/7 (GND)
# USB-6009/8 (A2) humid sensor + supply; conn to +5V (31)
# USB-6009/9 (A6) conn to GND (10)
# USB-6009/10 (GND)
#
# HIH-3610   USB-6009
# 1 -        6
# 2 OUT      5
# 3 +        8
#
# thermistor (10K NTC, Vishay B=3977K)
# USB-6009/2 to USB-6009/3
# 
# 20K resistor
# USB-6009/2 to USB-6009/8
#
# Jumper USB-6009/3 to USB-6009/1 (GND)
# Jumper USB-6009/9 to USB-6009/7 (GND)
# Jumper USB-6009/9 to USB-6009/6 (GND)
#
require 'daqmxbase'

# Task parameters
task = nil

# Channel parameters
# humidity, +5v, thermistor/resistor junction
channels = "Dev1/ai0:2"	
numberOfChannels = 3
terminalConfig = Daqmxbase::VAL_DIFF # differential
min = 0.0
max = 5.0
units = Daqmxbase::VAL_VOLTS

# Timing parameters
source = "OnboardClock"
sampleRate = 5000.0
activeEdge = Daqmxbase::VAL_RISING
sampleMode = Daqmxbase::VAL_CONT_SAMPS
samplesPerChan = 1000

# Data read parameters
timeout = 10.0
fillMode = Daqmxbase::VAL_GROUP_BY_CHANNEL
bufferSize = numberOfChannels * samplesPerChan

# constants
#
RRef = 20.0e3

# HIH-3610 Humidity sensor
# Vout = Vsupply (0.0062(Sensor RH) + 0.16)
# vout/vsupply = rh * 0.0062 + 0.16
# vout/vsupply - 0.16 = rh * 0.0062
# (vout/vsupply - 0.16) / 0.0062 = rh
#
# True RH = (Sensor RH)/(1.093 -0.0012T), T in degF
def humidity(vout, vsupply, tempF)
  sensorRH = (vout/vsupply - 0.16) / 0.0062
  trueRH = sensorRH / (1.093 - 0.0012 * tempF)
end

# FORMULAE TO DETERMINE NOMINAL RESISTANCE VALUES
# The resistance values at intermediate temperatures, or the
# operating temperature values, can be calculated using the
# following interpolation laws (extended Steinhart and Hart)
# T(R) = 1/(A1 + B1 * ln(R/Rref) + C1 * ln^2(R/Rref) + D1 * ln^3(R/Rref))
# where:
# A, B, C, D, A1, B1, C1 and D1 are constant values
# depending on the material concerned; see table below.
# Rref is the resistance value at a reference temperature (in
# this event 25 degC).
# T is the temperature in degK.

def temperatureFromResistance(r, rref)
  (a1, b1, c1, d1) = [ 3.354016E-03, 2.569850E-04, 2.620131E-06, 6.383091E-08 ]
  logRatio = Math.log(r/rref)
  tempK = 1.0/(a1 + (b1 * logRatio) + (c1 * logRatio ** 2.0) + (d1 * logRatio ** 3.0))
  tempC = tempK - 273.15
  tempF = (9.0 * tempC / 5.0) + 32
end

# Use Ohm's law to get the resistance
# reference resistor from vsupply to vdiff
# thermistor across vdiff
#
# Compensate for the resistor network and bias on the USB-6009 inputs
#
def thermistorResistance(vsupply, vdiff)
  i1 = (2.5 - vdiff) / 30.9e3
  i2 = vdiff / 39.2e3
  iin = i2 - i1 # positive = realv > 1.4V
  vdrop = iin / 127.0e3
  realv = vdiff + vdrop
  current = (vsupply - realv) / RRef # current through thermistor and reference resistor
  realv / current
end

def temperatureF(v1, v2)
  temperatureFromResistance(thermistorResistance(v1, v2), 10.0e3)
end

class Array
  def average
    inject(0.0) { |asum,ea| asum + ea } / size
  end
end

# Set up the analog input task for continuous input
task = Daqmxbase::Task.new()
task.create_aivoltage_chan(channels, terminalConfig, min, max, units) 
task.cfg_samp_clk_timing(source, sampleRate, activeEdge, sampleMode, samplesPerChan)
task.cfg_input_buffer(samplesPerChan)
task.start()

# Log the data both to a CSV file and display it to the console
File.open("toaster-#{Time.now.to_i}.csv", 'w') do |csvfile|
  csvfile.puts "# #{Time.now}\ntime,tempF,RH"

  samplePeriod = 0.5
  pointsToRead = samplesPerChan
  startTime = Time.now
  nextSample = startTime + samplePeriod
  while true
    now = Time.now
    (data, samplesPerChanRead) = task.read_analog_f64(pointsToRead, timeout, fillMode, bufferSize)
    # discard data if we're not to the next sample yet.
    if now >= nextSample
      nextSample += samplePeriod
      vresistor = data[0, samplesPerChanRead].average
      vhumid = data[samplesPerChanRead, samplesPerChanRead].average
      vsupply = data[samplesPerChanRead * 2, samplesPerChanRead].average
      tempF = temperatureF(vsupply, vresistor)
      tempFStr = '%.1f' % tempF
      relHumidStr = '%.1f' % humidity(vhumid, vsupply, tempF)
      timestamp = '%.1f' % (now-startTime)
      printf "\n%6s  %s degF   %5s %% RH    ", timestamp, tempFStr, relHumidStr
      csvfile.puts [timestamp, tempFStr, relHumidStr].join(',')
    else
      print "."
    end
  end
end
