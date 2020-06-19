require 'rexml/document'

(start = Time.now).to_s.+("\n").display $stderr
REXML::Document.new(ARGF.read) \
  .root \
  .get_elements('//Record') \
  .map do |record|
    #record.attributes.inspect
    #record.attribute('type').value
    %w[value unit startDate endDate creationDate type sourceName sourceVersion]\
    .map do |name|
      record.attribute(name).value.sub('HKQuantityTypeIdentifier','')
    end \
    .join(',')
  end \
  .join("\n") \
  .display
(stop = Time.now).to_s.+("\n").display $stderr
(stop-start).to_s.+("\n").display $stderr
