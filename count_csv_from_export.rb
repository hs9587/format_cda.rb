require 'csv'
require 'time'

class Counts < Hash
end # class Counts < Hash
class DailyCounts < Hash
  def initialize
    super() do |hash, key|
      hash[key] = Counts.new{0.0}
    end # super() do |hash, key|
  end # def initialize
end # class DailyCounts < Hash

CSV::Converters[:time23] = ->(cell, info) \
  { ([2,3].include? info.index) ? Time.parse(cell) : cell }

csvs = CSV.parse ARGF.read, converters: :time23
csvs.size.to_s.+("\n").display

dcs = csvs.each_with_object(DailyCounts.new) do |csv, dc|
  dc[Date.parse csv[2].to_s][csv[4]] += csv[0].to_f
end # dcs = csvs.each_with_object(DailyCounts.new) do |csv, dc|

(dcs.keys.min..dcs.keys.max).each{ |day| "#{day}: #{dcs[day]}\n".display }
