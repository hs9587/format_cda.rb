cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *ARGV[1..3]
birthday = "#{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970})"

[
  ARGV[4..-1].insert(1, birthday).join(', '),
  '',
  temperatures.take(27),
  '',
  pressures.sort.reverse.take(14),
  '',
  masses.take(13),
] \
  .flatten.join("\n").display
