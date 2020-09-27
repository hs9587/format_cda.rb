require 'rexml/document'
require 'oga'

argf_read = ARGF.read

(start = Time.now)#.to_s.+("\n").display $stderr
#REXML::Document.new(ARGF.read) \
REXML::Document.new(argf_read) \
  .root \
  .get_elements('//component') \
  .map do |comp|
    {
      high:  [:attributes, :values],
      value: [:get_text,   :value ],
      unit:  [:get_text,   :value ],
      type:  [:get_text,   :value ],
    } \
    .map do |key, (method, value)|
      comp.get_elements("*//#{key}").first.send(method).send(value)
    end \
    .join(',') \
    .+("\n")
  end \
#  .sort \
  .reverse \
  .join \
  .display
(middle = Time.now)#.to_s.+("\n").display $stderr
#Oga::XML::Parser.new(ARGF.read) \
Oga::XML::Parser.new(argf_read) \
  .parse \
  .xpath('//component//component') \
  .map do |comp|
    {
      high:  [:attribute, :value],
      value: [:text],
      unit:  [:text],
      type:  [:text],
    }.map do |key, method|
      comp.xpath(".//#{key}").send(*method)
    end \
    .join(',') \
    .+("\n")
  end \
#  .sort \
  .reverse \
  .join \
  .display
(stop = Time.now)#.to_s.+("\n").display $stderr

("\n") .display $stderr
start  .to_s.+("\n").display $stderr
(middle - start).to_s.+("\n").display $stderr
middle .to_s.+("\n").display $stderr
(stop  - middle).to_s.+("\n").display $stderr
stop   .to_s.+("\n").display $stderr
