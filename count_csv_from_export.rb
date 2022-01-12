# coding: utf-8
require 'csv'
require 'time'
require 'erb'

def erb_result(str, b)
  #ERB.new(str, nil, '-').result b
  ERB.new(str, trim_mode: '-').result b
  # str, safe_level=nil, trim_mode='-'
end # def erb_result(str, b)

require 'i18n'
  I18n.load_path += Dir[File.join(File.dirname(__FILE__),'locale','*.{rb,yml}')]
module TandL
  @@effective = false

  def self.effective; @@effective; end
  def self.effective=(v)
    @@effective = v
  end # def self.effective=(v)

  private
    def l(object, **options) 
      @@effective ? I18n.l(object, **options) : object
    end # def l(object, *options) 

    def t(object, **options) 
      #@@effective ? I18n.t(object, *options) : object
      #@@effective ? I18n.t(object, raise: true) : object
      result = @@effective ? I18n.t(object, **options) : object
      unless /translation missing: / =~ result then
        result
      else# unless /translation missing: / =~ result
        result.+("\n").display $stderr
        object
      end # unless /translation missing: / =~ result 
    end # def t(object, *options) 

    def u(object, type=nil)
      t object, scope: [:unit, type]
    end # def u(object, type=nil)
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

  def behinds
    values_at (Headers.size+2)..-1
  end # def behinds

  def rels
    if /Correlation/ =~ type then
      values.each_slice(3) \
      .map do |rel|
        rel.extend \
          Module.new{ Rel.each_with_index{ |k, i| define_method(k){ slice i }}} 
      end \
      .sort.reverse
      # type の文字列順、reverse で血圧が収縮期(Systolic)拡張期(Diastolic)の順に
    end # if /Correlation/ =~ type
  end # def rels
end # module TypeDates

module Integrate
  def integrate
    each_with_object([0.0, 0.0, 0.0]) do |row, s_w_i|
      delta    = (row.endDate - row.startDate)
      s_w_i[0] += row.value.to_f         # s_um
      s_w_i[1] += row.value.to_f * delta # w_eighted_sum
      s_w_i[2] += delta                  # i_nterval
    end # each_with_object([0.0, 0.0, 0.0]) do |row, s_w_i|
  end # def integrate

  private
    def minute(interval)
      '(%4.1f %s)' % [interval/60, u('min')]
    end # def minute(interval)
  # private
end # module Integrate

class Counts < Hash
  include TandL

  def initialize
    super() do |hash, key|
      arr = []
      arr.extend TandL, Integrate

      case key
      when /Correlation/ then
        def arr.report
          map do |row|
            [ row.startDate.strftime('%H:%M'),
              row.rels.map{ |rel|
                [t(rel.type), rel.value, u(rel.unit)].join(' ')
              }.join(' / ')
            ].join(' ')
          end # map do |row|
        end # def arr.report
      when /StepCount/,/FlightsClimbed/ then
        def arr.report
          #sum = inject(0){|s, row| s + row.value.to_i }
          #["      %d %s" % [sum, u(first.unit, first.type)]]
          sum, w, interval = self.integrate
          [['      %5d' % sum.to_i,
            '%s ' % u(first.unit, first.type),
            minute(interval),
            ].join(' ')]
        end # def arr.report
      when /DistanceWalkingRunning/ then
        def arr.report
          #sum = inject(0.0){|s, row| s + row.value.to_f }
          #["      %.3f %s %s" % [sum, u(first.unit), interval/60]]
          sum, w, interval = self.integrate
          [['      %.3f' % sum,
            '%s' % u(first.unit),
            minute(interval),
            ].join(' ')]
        end # def arr.report
      when /erWalking/ then
        # HKQuantityTypeIdentifierWalking..
        def arr.report
          s, weighted, interval = self.integrate
          w_sum = if first.unit=='%' then
            '%6.1f' % (weighted/interval * 100)
          else# if first.unit=='%'
            '%6.3f' % (weighted/interval)
          end # if first.unit=='%'
          [['     ',
            w_sum,
           '%-4s'.%('%2s'.%(u first.unit)),
            minute(interval),
            ].join(' ')]
        end # def arr.report
      when /BodyMass/,/BodyTemperature/ then
        def arr.report
          map do |row|
            [ row.startDate.strftime('%H:%M'),
             '%4.1f %s' % [row.value, u(row.unit)],
             ].join(' ')
          end # map do |row|
        end # def arr.report
      when /HeadphoneAudioExposure/ then
        def arr.report
          map do |row|
            [ row.startDate.strftime('%H:%M'),
             '%4.1f %s' % [row.value, u(row.unit)],
              minute(row.endDate-row.startDate),
            ].join(' ')
          end # map do |row|
        end # def arr.report
      else
        def arr.report
          map do |row|
            [ row.startDate.strftime('%H:%M'),
             #[row.value, u(row.unit)],
row.unit == '%' ? [row.value.to_f*100, u(row.unit)] : [row.value, u(row.unit)],
              row.behinds,
            ].flatten.join(' ')
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
      erb_result(<<-EOReport, binding).force_encoding 'UTF-8'
<%# coding: utf-8 -%>
  <%=t keyword %>:
  <%- arr.report.each do |line| -%>
    <%= line.gsub keyword, '' %>
  <%- end -%>
      EOReport
      # gsub keyword で BloodPressure の表示をちょっと抑制
      # それで translation missing エラーメッセージから識別が失われるの注意
    end \
      .join 
  end # def report
end # class Counts < Hash

class DailyCounts < Hash
  include TandL

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

  def report(startDate, endDate, options)
    reverse_or = options[:reverse] ? :reverse_each : :each
    startDate ||= keys.min
    endDate   ||= keys.max
    (startDate..endDate).send(reverse_or).map do |day|
      erb_result(<<-EOReport, binding).force_encoding 'UTF-8'
<%# coding: utf-8 -%>
<%=l day %>:
<%= self[day].report %>
      EOReport
    end.join
  end # def report(startDate, endDate, options)

  Entry = <<-EntryEnd # author title date category body img
AUTHOR: %<author>s
TITLE: %<title>s
DATE: %<date>s
PRIMARY CATEGORY: %<category>s
-----
BODY:
%<body>s%<img>s
-----
--------
  EntryEnd

  def to_mt(startDate, endDate, options)
    reverse_or = options[:reverse] ? :reverse_each : :each
    startDate ||= keys.min
    endDate   ||= keys.max
    (startDate..endDate).send(reverse_or).map do |day|
      Entry % {
        author:   'ヘルスケア',
        title:    l(day),
        date:     day.strftime('%m/%d/%Y 00:00:00'),
        category: 'ヘルスケア',
        body:  self[day].report.gsub(/^  /,'') \
          .gsub(/  /,'&nbsp;&nbsp;&nbsp;').chomp,
        img:      nil,
      }
        #body:     self[day].report.gsub(/^  /,'').gsub(/ +/,' ').chomp,
    end.join
  end # def to_mt(startDate, endDate, options)
end # class DailyCounts < Hash

CSV::Converters[:time13] = ->(cell, info) \
  { ((1..3).include? info.index) ? Time.parse(cell) : cell }

if $PROGRAM_NAME == __FILE__ then
  require 'optparse'

  OptionParser.accept(Date) do |s,|
    begin
      Date.parse(s) if s
    rescue
      raise OptionParser::InvalidArgument, s
    end
  end
  
  TandL.effective = false
  report = :report
  startDate, endDate = nil, nil
  reverse = false
  ARGV.options do |opts|
    opts.banner += ' <path to (oga_)export.csv> or stdin'
    opts.on('-l L', '--locale=L', 'activate translation to [ja|en]') \
      { |l| TandL.effective = true;  I18n.locale = l.to_sym }
    opts.on(        '--to_mt',    'report to MT') \
      { report = :to_mt }
    opts.on('--startDate=DATE', Date, 'format 2020/08/01') \
      { |date| startDate = date }
    opts.on('--endDate=DATE',   Date, 'format 2020/08/31') \
      { |date| endDate   = date }
    opts.on('--reverse', 'reverse order in dates') { |r| reverse = true }

    opts.parse!
  end # ARGV.options do |opts|

  CSV.parse(ARGF.read, converters: :time13, headers: TypeDates::Headers) \
    .inject(DailyCounts.new){ |dcs, row| dcs.add row } \
  .send(report, startDate, endDate, reverse: reverse).display
end # if $PROGRAM_NAME == __FILE__

