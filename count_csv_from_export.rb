require 'csv'
require 'time'

class Counts < Hash
  def add(row)
    case key = row[4]
    when 'BloodPressureSystolic', 'BloodPressureDiastolic'
    when 'BodyMass', 'BodyTemperature' then
      self[key] = self[key] ? self[key] << row : [row]
    when 'StepCount', 'FlightsClimbed' then # sum of integer
      self[key] = if self[key] then
        [self[key][0] + row[0].to_i, self[key][1]]
      else# self[key] = if self[key]
        [row[0].to_i, row[1]] 
      end # self[key] = if self[key]
    when 'DistanceWalkingRunning' then # sum of float
      self[key] = if self[key] then
        [self[key][0] + row[0].to_f, self[key][1]]
      else# self[key] = if self[key]
        [row[0].to_f, row[1]] 
      end # self[key] = if self[key]
    when 'HeadphoneAudioExposure' then
      self[key] = self[key] ? self[key] << row : [row]
    else
      self[key] = self[key] ? self[key] << row : [row]
    end # case key = row[4]
  end # def add(row)
end # class Counts < Hash

class DailyCounts < Hash
  def initialize
    super() do |hash, key|
      hash[key] = Counts.new
    end # super() do |hash, key|
  end # def initialize

  def add(row)
    self[Date.parse row[2].to_s].add row
  end # def add(row)
end # class DailyCounts < Hash

# %w[value unit startDate endDate type]
CSV::Converters[:time23] = ->(cell, info) \
  { ([2,3].include? info.index) ? Time.parse(cell) : cell }

csv = CSV.parse ARGF.read, converters: :time23
csv.size.to_s.+("\n").display

dcs = DailyCounts.new
csv.each{ |row| dcs.add row }

(dcs.keys.min..dcs.keys.max).each{ |day| "#{day}: #{dcs[day]}\n".display }

