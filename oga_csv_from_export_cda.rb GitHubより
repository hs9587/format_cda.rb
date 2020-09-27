require 'oga'

Oga::XML::Parser.new(ARGF.read) \
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
