require 'csv'
require 'time'

class Counts < Hash
  def add(row)
    case key = row[0]
    when /BloodPressureSystolic/, /BloodPressureDiastolic/
    else
      self[key] = self[key] ? self[key] << row : [row]
    end # case key = row[0]
  end # def add(row)
end # class Counts < Hash

class DailyCounts < Hash
  def initialize
    super() do |hash, key|
      hash[key] = Counts.new
    end # super() do |hash, key|
  end # def initialize

  def add(row)
    self[Date.parse row[1].to_s].add row
  end # def add(row)
end # class DailyCounts < Hash

# type_dates = %w[type startDate endDate creationDate sourceName sourceVersion]
# type_dates.+(%w[value unit]) 
#              %w[type value unit]
CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

csv = CSV.parse ARGF.read, converters: :time13
csv.size.to_s.+("\n").display

dcs = DailyCounts.new
csv.each{ |row| dcs.add row }

(dcs.keys.min..dcs.keys.max).map do |day|
  "#{day}:\n #{dcs[day].map{|k,a| "  #{k}:\n#{a.map{|v|v.values_at(1,*(6..11).to_a).compact.inspect}.join("\n")}\n"}.join}\n\n"
end.join.display
