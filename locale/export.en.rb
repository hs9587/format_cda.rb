{
  en: {
    date: {
      formats: {
        default: ->(date, params) \
          { "%Y-%m-%d(#{%w[Sun Mon Tue Wed Thu Fri Sat Sun][date.wday]})" }
      }
    }
  }
}
