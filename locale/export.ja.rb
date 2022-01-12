# coding: UTF-8
{
  ja: {
    date: {
      formats: {
        default: ->(date, params = nil) \
          { "%Y-%m-%d(#{'日月火水木金土日'[date.wday]})" }
      }
    }
  }
}
