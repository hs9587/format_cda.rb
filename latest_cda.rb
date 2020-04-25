cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *ARGV[1..3]
[
  "#{ARGV[4]}, #{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970}), #{ARGV[5..-1].join(', ')}",
  '',
  temperatures.take(20),
  '',
  pressures.sort.reverse.take(30),
  '',
  masses.take(10),
] \
  .flatten.join("\n").display
