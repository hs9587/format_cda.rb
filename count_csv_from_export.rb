require 'csv'
require 'time'
require 'erb'

def erb_result(str, b)
  ERB.new(str, nil, '-').result b
  # str, safe_level=nil, trim_mode='-'
end # def erb_result(str, b)


module TypeDates
  Headers = %w[type startDate endDate creationDate sourceName sourceVersion]
  # Headers  +  %w[value unit]
  Rel = %w[type value unit] # Correlation
  
  Headers.each{ |key| define_method(key){ field key }}
  def value
    field Headers.size+0 unless /Correlation/ =~ type
  end # def value
  def unit
    field Headers.size+1 unless /Correlation/ =~ type
  end # def unit

  def values
    values_at (Headers.size+0)..-1
  end # def values

  def rels
    if /Correlation/ =~ type then
      values.each_slice(3) \
      .map do |rel|
        rel.extend \
          Module.new{ Rel.each_with_index{ |k, i| define_method(k){ slice i }}} 
      end \
      .sort.reverse
      # type ‚Ì•¶š—ñ‡Areverse ‚ÅŒŒˆ³‚ªûkŠú(Systolic)Šg’£Šú(Diastolic)‚Ì‡‚É
    end # if /Correlation/ =~ type
  end # def rels
end # module TypeDates

class Count  < Array
  def report
    map do |v|
      "#{v.startDate.strftime '%H:%M'} #{v.values.join(' ')}"
    end # map do |v|
  end # def report
end # class Count  < Array

class Counts < Hash

  def initialize
    super() do |hash, key|
      arr = Count.new

      case key
      when /StepCount/,/FlightsClimbed/ then
        def arr.report
          sum = inject( 0 ){|s, record| s + record.value.to_i }
          ["      %6d %s" % [sum, first.unit]]
        end # def arr.report
      when /DistanceWalkingRunning/ then
        def arr.report
          sum = inject(0.0){|s, record| s + record.value.to_f }
          ["      %6f %s" % [sum, first.unit]]
        end # def arr.report
      when /Correlation/ then
        def arr.report
          map do |record|
            "#{record.startDate.strftime '%H:%M'} " \
              + record.rels.map{ |rel|
                "#{rel.type} #{rel.value} #{rel.unit}"
              }.join(' / ')
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
    row.extend TypeDates
    self[Date.parse row.startDate.to_s][row.type] << row
    self
  end # def add(row)

  def report
    (keys.min..keys.max).map do |day|
      erb_result <<-EOReport, binding
<%= day %>:
<%= self[day].report %>
      EOReport
    end.join
  end # def report
end # class DailyCounts < Hash

CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

if $PROGRAM_NAME == __FILE__ then
  CSV.parse(ARGF.read, converters: :time13, headers: TypeDates::Headers) \
    .inject(DailyCounts.new){ |dcs, row| dcs.add row } \
    .report.display
end # if $PROGRAM_NAME == __FILE__

