require 'oga'

(start = Time.now).to_s.+("\n").display $stderr
Oga::XML::Parser.new(ARGF.read) \
  .parse \
  .xpath('//Record') \
  .map do |record|
    %w[value unit startDate endDate type] \
    .map do |key|
      record[key].sub('HKQuantityTypeIdentifier','')
    end \
    .join(',')
  end \
  .join("\n") \
  .display
(stop = Time.now).to_s.+("\n").display $stderr
(stop-start).to_s.+("\n").display $stderr
