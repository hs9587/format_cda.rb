# coding: UTF-8
{
  ja: {
    date: {
      formats: {
        default: ->(date, params) \
          { "%Y-%m-%d(#{'日月火水木金土日'[date.wday]})" }
          #{ "%Y-%m-%d(#{%w[日 月 火 水 木 金 土 日][date.wday]})" }
      }
    }
  }
}
