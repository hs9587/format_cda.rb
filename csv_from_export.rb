require 'rexml/document'

type_dates = %w[type startDate endDate creationDate sourceName sourceVersion]
csv = []

(start = Time.now).to_s.+("\n").display $stderr
  #.get_elements('//Record') \
REXML::Document.new(ARGF.read) \
  .root \
  .tap do |xml|
    xml \
    .get_elements('//Record') \
    .each do |record|
      csv <<
      (
        type_dates.+(%w[value unit]) \
        .map do |key|
          record.attribute(key).value
        end \
        .join(',') \
        .+("\n")
      )
    end # .each do |record|
  end \
    .get_elements('//Correlation') \
    .each do |cor|
      csv <<
      (
        type_dates \
        .map do |key|
          cor.attribute(key).value
        end \
        .join(',') \
        + ','  \
        + (
          cor \
          .get_elements('Record') \
          .map do |record|
            %w[type value unit]\
            .map do |key|
              record.attribute(key).value.sub('HKQuantityTypeIdentifier','')
            end \
            .join(',')
          end # .map do |record|
          .join(',')
        ) \
        .+("\n")
      )
    end # .each do |cor|
  # end \
# REXML::Document.new(ARGF.read) \
(stop = Time.now).to_s.+("\n").display $stderr
(stop-start).to_s.+("\n").display $stderr

csv.join.display

