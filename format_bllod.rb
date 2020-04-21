require 'csv'
require 'time'

CSV::Converters.merge!( {
  row0: ->(cell, info){ info.index != 0 ? cell : \
          Time.parse(cell).strftime('%Y-%m-%d')[2..-1] },
  row1: ->(cell, info){ info.index != 1 ? cell : \
          "#{cell[0,2]}:#{cell[2,2]}" },
} )

CSV.filter(headers: :first_row,
    return_headers: true,
       out_col_sep: "   ", 
        converters: [:row0, :row1]) {}
