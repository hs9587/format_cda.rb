# format_cda.rb
apple_health_export and format_cda

# iPhone のヘルスケア apple_health_export
[https://hs9587.hatenablog.com/entry/2020/04/12/215431]

iPhone のヘルスケア アプリ、体重とか体温とか入力してるんだけど、外には書き出せないのかな。

1. ヘルスケア アプリ
   1. 「概要」画面
      1.  右肩 人型マーク
   2. 人型マーク 画面
      1. 画面最下部に「すべてのヘルスケアデータを書き出す」リンク
         1. 押下
      2. 「ヘルスケアデータを書き出す」ダイアローグ
         1. 「書き出す」釦
            1. 押下
      3. 書き出し中
      4. 「書き出したデータ」zipデータ
         1. 送り先選択
         - メールとかメッセージかなあ、あるいは"ファイル"に保存
         - ファイル名注意「書き出したデータ.zip」前のがあると置き換える
      5. 保存しました
   3. 人型マーク画面「完了」
      1. 押下
   4. 「概要」画面

として、データがファイルで手に入る。何とかして PCに持って来よう。

Windows PowerShell
```PowerShell
> Expand-Archive .\書き出したデータ.zip
```
```PowerShell
\書き出したデータ> tree /F
フォルダー パスの一覧
……
└─apple_health_export
        export.xml
        export_cda.xml
```
XML データ。  
見たいあたり CSV にしましょうか。

export_cda.xml が入力データっぽい、今日はそれを読む。export.xml の方はサイズが大きい量も多く、IPhone で自動収集されるデータ、歩数とか、入ってるみたい。

helth_care_data.rb
```ruby
require 'rexml/document'

REXML::Document.new(ARGF.read) \
  .root \
  .get_elements('//component') \
  .map do |comp|
    {
      high:  [:attributes, :values],
      value: [:get_text,   :value ],
      unit:  [:get_text,   :value ],
      type:  [:get_text,   :value ],
    } \
    .map do |key, (method, value)|
      comp.get_elements("*//#{key}").first.send(method).send(value)
    end \
    .join(',')
  end \
#  .sort \
  .join("\n") \
  .display
```
XML項目の説明は特にしないが、日付 observation/effectiveTime/high は属性値に値があるので #attributes.values で値を取る、そうすると配列になるのだが、属性が一つしかないのでまあ何とかなる。
```PowerShell
>ruby helth_care_data.rb 書き出したデータ\apple_health_export\export_cda.xml
```
こんな感じかな。


# apple_health_export 出力の整形
[https://hs9587.hatenablog.com/entry/2020/04/19/140001]

前段  
iPhone に入れたヘルスケア情報を csv に出来た。

そうするとこんな感じになる
```csv
20200418053000+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
20200417211100+0900,36,degC,HKQuantityTypeIdentifierBodyTemperature
20200417155800+0900,36.1,degC,HKQuantityTypeIdentifierBodyTemperature
20200417055000+0900,36.2,degC,HKQuantityTypeIdentifierBodyTemperature
20200416221500+0900,36,degC,HKQuantityTypeIdentifierBodyTemperature
20200416054000+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
20200415052400+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
```
十分わかり易い形だが、コンピューターで読むのではなく、人が見るならもう少し整形しても良い。

format_cda.rb
```ruby
require 'csv'
require 'time'

CSV::Converters.merge!( {
  row3: ->(cell, info){ info.index != 3 ? cell : cell[24..-1]   },
  row1: ->(cell, info){ info.index != 1 ? cell : '%6.1f' % cell },
  row0: ->(cell, info){ info.index != 0 ? cell : \
          Time.parse(cell).strftime('%Y-%m-%d %H:%M %z')[2..-3] },
} )

CSV.filter(out_col_sep: "\t", converters: [:row0, :row1, :row3]) {}
```
そうするとこんな感じ
```csv
20-04-18 05:30 +09      35.9    degC    BodyTemperature
20-04-17 21:11 +09      36.0    degC    BodyTemperature
20-04-17 15:58 +09      36.1    degC    BodyTemperature
20-04-17 05:50 +09      36.2    degC    BodyTemperature
20-04-16 22:15 +09      36.0    degC    BodyTemperature
20-04-16 05:40 +09      35.9    degC    BodyTemperature
20-04-15 05:24 +09      35.9    degC    BodyTemperature
```
CSV([https://docs.ruby-lang.org/ja/latest/library/csv.html]) の普段僕が余り使わない機能を使ったので少しコードの説明。

普段 CSV.parse とか CSV.read で読むと配列の配列になるのでいろいろしていた。
今回は入力を少し整形してすぐ出力するフィルターが良いと思った、 CSV.filter
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#S_FILTER] があった。

カンマ区切りはコンピュータとのやり取りには良いのだけど、人が見るにはちょっとうるさいかな、出力はタブにしましょう、オプションに「out_col_sep: "\t"」。
入出力オプションほかのはこの辺
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#S_NEW] を参考に、出力なので頭に「out_」か「output_」を付けるとのこと。

書式の変換には converters: オプションと CSV::Converters
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#C_-CONVERTERS] を使ってみる。

コンヴァーターの実装
```ruby
  row3: ->(cell, info){ info.index != 3 ? cell : cell[24..-1]   },
  row1: ->(cell, info){ info.index != 1 ? cell : '%6.1f' % cell },
  row0: ->(cell, info){ info.index != 0 ? cell : \
          Time.parse(cell).strftime('%Y-%m-%d %H:%M %z')[2..-3] },
```
その適用時、列数の指定とかはないみたい。どの列にもみんな適用されるので第二引数から列数を確認する。「?」三項演算子(
[https://docs.ruby-lang.org/ja/latest/doc/spec=2foperator.html#cond]
)、本当は否定の条件は避けるべきなんだが、可変部を後ろにした方が分かり易いかとそうした。二列目 row2 は儘なので書かない。

コンヴァーターを使うことにしたら、CSV.filter のブロックでやることが無くなったので空っぽのブロックを付ける「 {} 」
```ruby
CSV.filter(out_col_sep: "\t", converters: [:row0, :row1, :row3]) {}
```
空っぽのブロックって、他になんか書き方無いのかな。


# latest_cda.rb

だんだん数字溜まってきて、種類別に最近の 1,2週間分だけ集めて、紙1枚分にまとめようかな。そしたらなんか憶えもメモしとこうか、年齢計算とか。
```ruby
cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *(ARGV[1].split /\D/)
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

```
ARGV 最初の引数にデータソースのファイル名、前掲 format_cda.rb の出力。  
次の引数に生年月日、適宜非数字文字で区切る。
```ruby
cdas = File.read(ARGV[0]).split "\n"
```
```ruby
hs = Time.local *(ARGV[1].split /\D/)
```
#read とか #split とか #local でエラーになるし、引数ここまでは必須ということに。

第3引数に、体温血圧体重の表示行数をその順に、非数字文字で区切って。
```ruby
t, p, m = ARGV[2].to_s.split /\D/
```
引数無いと #to_s が走って全部 nil が入る。
或いは少なかったりで nil だと、続く #take 内の三項演算子で既定値にすり替わる。

既定値は体温2週間分に合わせて A4一枚に入るように案配。  
配分とか余白の調整を考えて引数に設定できるようにした。

続く引数は前述年齢計算を挟んで文頭にメモる
```ruby
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
```
#to_a #compact は ARGV[3 以降] が無かった時対策。


# おまけ

head の代わり
```ruby
| ruby -pe "exit if $.==8"
```
