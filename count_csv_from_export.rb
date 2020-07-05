require 'csv'
require 'time'
require 'erb'

def erb_result(str, b)
  ERB.new(str, nil, '-').result b
  # str, safe_level=nil, trim_mode='-'
end # def erb_result(str, b)

TypeDates = %w[type startDate endDate creationDate sourceName sourceVersion]
# TypeDates.+(%w[value unit]) 
# Correlation %w[type value unit]

class Counts < Hash

  def initialize
    super() do |hash, key|
      arr = []

      def arr.report
        self.map do |v|
          "#{v['startDate'].strftime '%H:%M'} #{v.values_at(6..-1).join(' ')}"
        end
      end # def arr.report

      case key
      when /StepCount/,/FlightsClimbed/ then
        def arr.report
          sum = inject( 0 ){|s, record| s + record[TypeDates.size+0].to_i }
          ["      %6d %s" % [sum, first[TypeDates.size+1]]]
        end # def arr.report
      when /DistanceWalkingRunning/ then
        def arr.report
          sum = inject(0.0){|s, record| s + record[TypeDates.size+0].to_f }
          ["      %6f %s" % [sum, first[TypeDates.size+1]]]
        end # def arr.report
      when /Correlation/ then
        def arr.report
          map do |record|
            "#{record['startDate'].strftime '%H:%M'} " \
            + record.values_at(TypeDates.size..-1).each_slice(3).to_a.sort.reverse.map{ |item|  item.join(' ') }.join(' / ')
            #+ "#{record.values_at(6..-1).join(' ')}" \
          end # map do |record|
        end # def arr.report
      when /Correlation/ then
      end # case key

      hash[key] = arr
    end # super() do |hash, key|
  end # def initialize

  def report
    map do |key, arr|
      next if /BloodPressure(Systolic|Diastolic)/ =~ key
      erb_result <<-EOReport, binding
  <%= key.sub /HK.*Identifier/, '' %>:
  <%- arr.report.each do |line| -%>
    <%= line %>
  <%- end -%>
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

CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

csv = CSV.parse ARGF.read, converters: :time13, headers: TypeDates
csv.size.to_s.+("\n").display

dcs = DailyCounts.new
csv.each{ |row| dcs.add row }

(dcs.keys.min..dcs.keys.max).map do |day|
  erb_result <<-EOReport, binding
<%= day %>:
<%= dcs[day].report %>
  EOReport
end.join.display
