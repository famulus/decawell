# $Id: efield.rb 89 2008-04-08 20:09:05Z bikenomad $
#
# efield.rb: drive the channel select  lines of a MC33794 eval board and
# sample the levels.
#
# Changed to sample continuously.
#--------------------------------------------------------------------------------
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
#--------------------------------------------------------------------------------

require 'daqmxbase'

$stdout.sync = true

class Efield
  include Daqmxbase

  # electrode addresses
  INT_SRC = 0
  E1 = 1; E2 = 2; E3 = 3; E4 = 4; E5 = 5; E6 = 6; E7 = 7; E8 = 8; E9 = 9
  REF_A = 10; REF_B = 11
  INT_OSC = 12; INT_OSC_AFTER_R = 13; INT_GND = 14; RESERVED=15

  # voltages
  MinLevel = 0.0 # V
  MaxLevel = 5.0 # V

  # sampling parameters

  # 32nd note at 120 bpm = 1/32 * 1/2 = 1/64 sec = 15+ msec
  MaxLatency = 0.06
  MaxSampleRate = 6000 # can't be more than 48KHz or so
  MaxSamplesPerChannel = 200
  Timeout = 0.5 # seconds
  IgnoreTime = 0.001  # after changing channel, discard for this time
  MaxPercentIgnored = 20

  def createAITask
    task = Task.new()
    task.create_aivoltage_chan(@devName+"/"+@levelInput, VAL_RSE, MinLevel, MaxLevel, VAL_VOLTS)
    # configure for continuous sampling at @sampleRate
    task.cfg_samp_clk_timing("OnboardClock", @sampleRate, VAL_RISING, VAL_CONT_SAMPS, 0)
    task.start
    task
  end

  def createDOTask
    task = Task.new()
    task.create_dochan(@devName+"/"+@selectOutputs)
    task.start
    task
  end

  def readRawChannelLevel(channelAddress)
    # don't re-write the same address
    if @lastAddress != channelAddress
      @changedAddressAt = Time.now
      @digitalOutputTask.write_digital_scalar_u32(0, Timeout, channelAddress)
      @lastAddress = channelAddress
    end
    # throw some away
    @analogInputTask.read_analog_f64(@samplesToIgnore, Timeout, VAL_GROUP_BY_CHANNEL, @samplesToIgnore)
    # read good ones
    (data, samplesPerChanRead) =
      @analogInputTask.read_analog_f64(@samplesPerChannel, Timeout, VAL_GROUP_BY_CHANNEL, @samplesPerChannel)
    retval = data.inject(0.0) { |s,i| s + i} / data.size  # average
    if channelAddress == REF_A
      @refA = retval
    elsif channelAddress == REF_B
      @refB = retval
    end
    return retval
  end

  # REF_A = 10pF
  # REF_B = 56pF
  def readReferences
    @refA = readRawChannelLevel(REF_A)
    @refB = readRawChannelLevel(REF_B)
  end

  def refA
    self.references()[0]
  end

  def refB
    self.references()[1]
  end

  def initialize(channels, devName = "Dev1", levelInput = "ai0", selectOutputs = "port0")
    @devName = devName
    @levelInput = levelInput
    @selectOutputs = selectOutputs
    @channels = channels.to_a.collect { |c| c.to_i }
    (@sampleRate, @samplesPerChannel, @samplesToIgnore) = computeSamplingParameters()
  end

  attr_reader :channels,:samplesPerChannel,:samplesToIgnore,:sampleRate

  def startup
    @analogInputTask = createAITask()
    @digitalOutputTask = createDOTask()
    @changedAddressAt = nil
    @lastAddress = nil
    @refA = @refB = nil
  end

  def computeSamplingParameters
    channelPeriod = MaxLatency / @channels.size
    samplesPerChannel = [channelPeriod * MaxSampleRate, MaxSamplesPerChannel].min.to_i
    sampleRate = samplesPerChannel / channelPeriod
    # ignore samples for IgnoreTime, up to 20% of samples
    samplesToIgnore = [sampleRate * IgnoreTime, samplesPerChannel * MaxPercentIgnored / 100.0 ].min.to_i
    return *[sampleRate, samplesPerChannel, samplesToIgnore]
  end

  def references
    self.readReferences if @refA.nil? or @refB.nil?
    return [ @refA, @refB ]
  end

  def channels_collect
    @channels.collect { |ch| yield ch }
  end

  # channels: array of channel numbers
  # scale: global scale factor to multiply by
  # offsets: array of offsets to be subtracted before scaling
  def readChannels(scale, offsets)
    return channels_collect { |cn| readRawChannelLevel(cn) }.zip(offsets).collect { |a| (a[0] - a[1]) * scale }
  end

  def testRun(filename="efield.csv", startChan=E5, endChan=E7, duration=10.0)
    startup

    baseline = channels_collect { |cn|
      10.times { readRawChannelLevel(cn) }
      readRawChannelLevel(cn)
    }
    puts "baseline: #{ baseline.inspect }"
    scale = 46 / (self.references[1] - self.references[0]) # 46 pf is 56-10pf, reference range
    min = self.references[0]
    puts "scale: #{ scale }, min: #{ min }"
    baseline = baseline.collect { |v| v - min }
    puts "scaled baseline: #{ baseline.inspect }"

    puts "Sampling channels #{@channels.inspect } at #{@sampleRate} for #{duration} seconds"
    started = Time.now
    totalSamples = 0
    now = nil
    File.open(filename, 'w') do |outfile|
      outfile.puts((self.channels_collect {|cn| "E" + cn.to_s }.push("N")).join(", "))
      while (now = Time.now) - started < duration
#        values = readChannels(scale, baseline)
        values = readChannels(1.0, @channels.collect { |c| 0.0 })
        if totalSamples > 0
          outfile.puts((values.collect {|d| "%6.4f"% d }.push(totalSamples.to_s)).join(", "))
        end
        totalSamples = totalSamples + self.channels.size
      end
    end
    puts "\nelapsed: #{now-started} samples: #{totalSamples} rate: #{totalSamples/(now-started)}"
    puts "output in #{filename}"
  end
end

if __FILE__ == $0
  ef = Efield.new(ARGV[1].to_i .. ARGV[2].to_i)
  p ef
  ef.testRun(ARGV[0])
end

# vim: ft=ruby ts=2 sw=2 et ai
