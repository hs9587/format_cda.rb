require 'csv'
require 'time'

CSV::Converters.merge!( {
  row3: ->(cell, info){ info.index != 3 ? cell : cell[24..-1]   },
  row1: ->(cell, info){ info.index != 1 ? cell : '% 6.1f' % cell },
  row0: ->(cell, info){ info.index != 0 ? cell : \
          Time.parse(cell).strftime('%Y-%m-%d %H:%M %z')[2..-3] },
} )

CSV.filter(out_col_sep: "\t", converters: [:row0, :row1, :row3]) {}