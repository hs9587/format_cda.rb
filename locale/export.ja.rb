# coding: UTF-8
{
  ja: {
    date: {
      formats: {
        default: ->(date, params) \
          { "%Y-%m-%d(#{%w[日 月 火 水 木 金 土 日][date.wday]})" }
      }
    }
  }
}
