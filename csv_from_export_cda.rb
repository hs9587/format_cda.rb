require 'rexml/document'
unit = nil

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
      .tap{|row| unit = row[2] }.map.with_index{|cell, i| (i==1 and unit == '%' and cell.to_f<1) ? cell.to_f.*(100).to_s : cell} \
    .join(',') \
    .+("\n")
  end \
#  .sort \
  .reverse \
  .join \
  .display
