{
  en: {
    date: {
      formats: {
        default: ->(date, params = nil) \
          { "%Y-%m-%d(#{%w[Sun Mon Tue Wed Thu Fri Sat Sun][date.wday]})" }
      }
    }
  }
}
