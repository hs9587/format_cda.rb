cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *(ARGV[1].split('/'))
birthday = "#{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970})"

[
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
  '',
  temperatures.take(27),
  '',
  pressures.sort.reverse.take(18),
  '',
  masses.take(15),
] \
  .flatten.join("\n").display
