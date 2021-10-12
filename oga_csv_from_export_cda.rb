require 'oga'
unit = nil

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
      .tap{|row| unit = row[2] } \
      .map.with_index do |cell, i|
        (i==1 and unit == '%' and cell.to_f<1) ? cell.to_f.*(100).to_s : cell
        # 単位が % で値が 1に満たないときパーセント表記用に 100倍する
      end \
    .join(',') \
    .+("\n")
  end \
#  .sort \
  .reverse \
  .join \
  .display
