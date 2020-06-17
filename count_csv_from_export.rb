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

  def add(row)
    self[Date.parse row[2].to_s][row[4]] += row[0].to_f
  end # def add(row)
end # class DailyCounts < Hash

CSV::Converters[:time23] = ->(cell, info) \
  { ([2,3].include? info.index) ? Time.parse(cell) : cell }

csv = CSV.parse ARGF.read, converters: :time23
csv.size.to_s.+("\n").display

dcs = DailyCounts.new
csv.each{ |row| dcs.add row }

(dcs.keys.min..dcs.keys.max).each{ |day| "#{day}: #{dcs[day]}\n".display }

