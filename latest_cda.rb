cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *(ARGV[1].split(/\D/))
birthday = "#{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970})"

t, p, m = ARGV[2].to_s.split /\D/

[
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
    # .to_a .compact は ARGV[3 以降] が無かった時対策
  '',
  temperatures.take(t ? t.to_i : 25),
  '',
  pressures.sort.reverse.take(p ? p.to_i : 16),
  '',
  masses.take(m ? m.to_i : 13),
] \
  .flatten.join("\n").display
