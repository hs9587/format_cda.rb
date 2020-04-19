require 'rexml/document'

REXML::Document.new(ARGF.read) \
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
    .join(',')
  end \
#  .sort \
  .reverse \
  .join("\n") \
  .display
