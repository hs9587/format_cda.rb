require 'oga'
# csv from export: require Oga. 6sec(nano) Ruby 2.4.5
# <-  900sec(CF-RZ6) REXML Ruby 2.4.4
# <- 3800sec(CF-S10) REXML Ruby 1.9.3
#
# grep Step oga.export.csv | ruby -rtime -aF, -lne 'BEGIN{steps=Hash.new{0}}; steps[Date.parse $F[2]] += $F[0].to_i; END{steps.sort.map{|k,v| "#{k.strftime "%y-%m-%d(%a)"}:#{"%5d"%v}\n" }.join.display}' | less


(start = Time.now).to_s.+("\n").display $stderr
Oga::XML::Parser.new(ARGF.read) \
  .parse \
  .xpath('//Record') \
  .map do |record|
    %w[value unit startDate endDate creationDate type sourceName sourceVersion]\
    .map do |key|
      record[key].sub('HKQuantityTypeIdentifier','')
    end \
    .join(',')
  end \
  .join("\n") \
  .display
(stop = Time.now).to_s.+("\n").display $stderr
(stop-start).to_s.+("\n").display $stderr
