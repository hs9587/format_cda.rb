require 'oga'
# csv from export: require Oga. 6sec(nano) Ruby 2.4.5
# <-  900sec(CF-RZ6) REXML Ruby 2.4.4
# <- 3800sec(CF-S10) REXML Ruby 1.9.3
#
# grep Step oga.export.csv | ruby -rtime -aF, -lne 'BEGIN{steps=Hash.new{0}}; steps[Date.parse $F[2]] += $F[0].to_i; END{steps.sort.map{|k,v| "#{k.strftime "%y-%m-%d(%a)"}:#{"%5d"%v}\n" }.join.display}' | less

type_dates = %w[type startDate endDate creationDate sourceName sourceVersion]
csv = []

(start = Time.now).to_s.+("\n").display $stderr
Oga::XML::Parser.new(ARGF.read) \
  .parse \
  .tap do |xml|
    xml \
    .xpath('//Record') \
    .each do |record|
      csv << 
      (
        type_dates.+(%w[value unit]) \
        .map do |key|
          record[key]
        end \
        .join(',') \
        .+("\n")
      )
    end # .each do |record|
  end \
    .xpath('//Correlation') \
    .each do |cor|
      csv <<
      (
        type_dates \
        .map do |key|
          cor[key]
        end \
        .join(',') \
        + ','  \
        + (
          cor \
          .xpath('Record') \
          .map do |record|
            %w[type value unit]\
            .map do |key|
              record[key].sub('HKQuantityTypeIdentifier','')
            end \
            .join(',')
          end # .map do |record|
          .join(',')
        ) \
        .+("\n")
      )
    end # .each do |cor|
  # end \
# Oga::XML::Parser.new(ARGF.read) \
(stop = Time.now).to_s.+("\n").display $stderr
(stop-start).to_s.+("\n").display $stderr

csv.join.display
