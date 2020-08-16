require 'csv'
require 'time'
require 'erb'

def erb_result(str, b)
  ERB.new(str, nil, '-').result b
  # str, safe_level=nil, trim_mode='-'
end # def erb_result(str, b)

require 'i18n'
  I18n.load_path += Dir[File.join(File.dirname(__FILE__), '*.yml')]
  module TandL
    private
      def t(*args); I18n.t *args; end
      def l(*args); I18n.l *args; end
    # private
  end # module TandL

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

class Counts < Hash

  def initialize
    super() do |hash, key|
      arr = []

      case key
      when /Correlation/ then
        def arr.report
          map do |row|
            "#{row.startDate.strftime '%H:%M'} " \
              + row.rels.map{ |rel|
                "#{rel.type} #{rel.value} #{rel.unit}"
              }.join(' / ')
          end # map do |row|
        end # def arr.report
      when /StepCount/,/FlightsClimbed/ then
        def arr.report
          sum = inject( 0 ){|s, row| s + row.value.to_i }
          ["      %d %s" % [sum, first.unit]]
        end # def arr.report
      when /DistanceWalkingRunning/ then
        def arr.report
          sum = inject(0.0){|s, row| s + row.value.to_f }
          ["      %.3f %s" % [sum, first.unit]]
        end # def arr.report
      when /BodyMass/,/BodyTemperature/ then
        def arr.report
          map do |row|
            "#{row.startDate.strftime '%H:%M'} " \
              + '%4.1f %s' % [row.value, row.unit]
          end # map do |row|
        end # def arr.report
      when /HeadphoneAudioExposure/ then
        def arr.report
          map do |row|
            "#{row.startDate.strftime '%H:%M'} " \
              + '%4.1f %s' % [row.value, row.unit] \
              + ' (%4.1f min)' % ((row.endDate-row.startDate)/60)
          end # map do |row|
        end # def arr.report
      else
        def arr.report
          map do |row|
            "#{row.startDate.strftime '%H:%M'} #{row.values.join(' ')}"
          end # map do |row|
        end # def arr.report
      end # case key

      hash[key] = arr
    end # super() do |hash, key|
  end # def initialize

  def report
    map do |key, arr|
      next if /BloodPressure(Systolic|Diastolic)/ =~ key
      keyword = key.sub /HK.*Identifier/, ''
      erb_result <<-EOReport, binding
  <%= keyword %>:
  <%- arr.report.each do |line| -%>
    <%= line.gsub keyword, '' %>
  <%- end -%>
      EOReport
      # gsub keyword ‚Å BloodPressure ‚Ì•\¦‚ğ‚¿‚å‚Á‚Æ—}§
    end \
      .join 
  end # def report

  include TandL
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

  def report_i18n(locale=:ja)
    I18n.locale = locale
    if keys.min and keys.max then
      (keys.min..keys.max).map do |day|
      erb_result <<-EOReport, binding
<%=l day %>:
<%= self[day].report %>
      EOReport
      end.join
    end # if keys.min and keys.max
  end # def repot_i18n(l=:ja)

  include TandL
=begin
  private
    def t(*args); I18n.t *args; end
    def l(*args); I18n.l *args; end
  # private
=end
end # class DailyCounts < Hash

CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

if $PROGRAM_NAME == __FILE__ then
  CSV.parse(ARGF.read, converters: :time13, headers: TypeDates::Headers) \
    .inject(DailyCounts.new){ |dcs, row| dcs.add row } \
    .report.display
end # if $PROGRAM_NAME == __FILE__

