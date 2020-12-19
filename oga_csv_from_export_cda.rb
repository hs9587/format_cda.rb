require 'oga'

Oga::XML::Parser.new(ARGF.read) \
  .parse \
  .xpath('//component//component/observation') \
  .map do |comp|
    {
      'effectiveTime/high': [:attribute, :value],
      'text/value':         [:text],
      'text/unit':          [:text],
      'text/type':          [:text],
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
