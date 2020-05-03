cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *(ARGV[1].split(/\D/))
birthday = "#{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970})"

t, p, m = ARGV[2].to_s.split /\D/

[
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
  '',
  temperatures.take(t ? t.to_i : 27),
  '',
  pressures.sort.reverse.take(p ? p.to_i : 18),
  '',
  masses.take(m ? m.to_i : 15),
] \
  .flatten.join("\n").display
