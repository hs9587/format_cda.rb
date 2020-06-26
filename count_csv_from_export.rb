require 'csv'
require 'time'

class Counts < Hash

  def initialize
    super() do |hash, key|
      arr = []
      case key
      when /StepCount/, /DistanceWalkingRunning/ then
      else# case key
      end # case key

      def arr.report
        self.map do |v|
          "#{v.values_at(1,*(6..11).to_a).compact.inspect}"
        end
      end # def arr.report

      hash[key] = arr
    end # super() do |hash, key|
  end # def initialize

  def report
    map do |k,a|
      next if /BloodPressure(Systolic|Diastolic)/ =~ k
      <<-EOReport
  #{k}:
#{a.report.join("\n")}
      EOReport
    end \
      .join 
  end # def report
end # class Counts < Hash

class DailyCounts < Hash
  def initialize
    super() do |hash, key|
      hash[key] = Counts.new
    end # super() do |hash, key|
  end # def initialize

  def add(row)
    self[Date.parse row['startDate'].to_s][row['type']] << row
  end # def add(row)
end # class DailyCounts < Hash

 type_dates = %w[type startDate endDate creationDate sourceName sourceVersion]
# type_dates.+(%w[value unit]) 
#              %w[type value unit]
CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

csv = CSV.parse ARGF.read, converters: :time13, headers: type_dates
csv.size.to_s.+("\n").display

dcs = DailyCounts.new
csv.each{ |row| dcs.add row }

(dcs.keys.min..dcs.keys.max).map do |day|
  "#{day}:\n" \
  + dcs[day].report \
  + "\n"
end.join.display
