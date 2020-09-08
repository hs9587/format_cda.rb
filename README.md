# format_cda.rb
apple_health_export and format_cda

# iPhone �̃w���X�P�A apple_health_export
[https://hs9587.hatenablog.com/entry/2020/04/12/215431]

iPhone �̃w���X�P�A �A�v���A�̏d�Ƃ��̉��Ƃ����͂��Ă�񂾂��ǁA�O�ɂ͏����o���Ȃ��̂��ȁB

1. �w���X�P�A �A�v��
   1. �u�T�v�v���
      1.  �E�� �l�^�}�[�N
   2. �l�^�}�[�N ���
      1. ��ʍŉ����Ɂu���ׂẴw���X�P�A�f�[�^�������o���v�����N
         1. ����
      2. �u�w���X�P�A�f�[�^�������o���v�_�C�A���[�O
         1. �u�����o���v�t
            1. ����
      3. �����o����
      4. �u�����o�����f�[�^�vzip�f�[�^
         1. �����I��
         - ���[���Ƃ����b�Z�[�W���Ȃ��A���邢��"�t�@�C��"�ɕۑ�
         - �t�@�C�������Ӂu�����o�����f�[�^.zip�v�O�̂�����ƒu��������
      5. �ۑ����܂���
   3. �l�^�}�[�N��ʁu�����v
      1. ����
   4. �u�T�v�v���

�Ƃ��āA�f�[�^���t�@�C���Ŏ�ɓ���B���Ƃ����� PC�Ɏ����ė��悤�B

Windows PowerShell
```PowerShell
> Expand-Archive .\�����o�����f�[�^.zip
```
```PowerShell
\�����o�����f�[�^> tree /F
�t�H���_�[ �p�X�̈ꗗ
�c�c
����apple_health_export
        export.xml
        export_cda.xml
```
XML �f�[�^�B  
������������ CSV �ɂ��܂��傤���B

export_cda.xml �����̓f�[�^���ۂ��A�����͂����ǂށB  
export.xml �̕��̓T�C�Y���傫���ʂ������AIPhone �Ŏ������W�����f�[�^�A�����Ƃ��A�����Ă�݂����B
([�ʂ̂�� csv_from_export.rb](#�ʂ̂��-csv_from_exportrb))

## �ڎ�
- [format_cda.rb](#format_cdarb)
- [iPhone �̃w���X�P�A apple_health_export](#iPhone-�̃w���X�P�A-apple_health_export)
  - [�ڎ�](#�ڎ�)
- [CSV�� csv_from_export_cda.rb](#CSV��-csv_from_export_cdarb)
- [apple_health_export �o�͂̐��` format_cda.rb](#apple_health_export-�o�͂̐��`-format_cdarb)
- [�ŋ�1���� latest_cda.rb](#�ŋ�1����-latest_cdarb)
- [�ʂ̂�� csv_from_export.rb](#�ʂ̂��-csv_from_exportrb)
  - [oga_csv_from_export.rb](#oga_csv_from_exportrb)
- [�ʂ̂�W�v���` count_csv_from_export.rb](#�ʂ̂�W�v���`-count_csv_from_exportrb)
- [���܂�](#���܂�)

# CSV�� csv_from_export_cda.rb
csv_from_export_cda.rb
```ruby:csv_from_export_cda.rb
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
XML���ڂ̐����͓��ɂ��Ȃ����A���t observation/effectiveTime/high �͑����l�ɒl������̂� #attributes.values �Œl�����A��������Ɣz��ɂȂ�̂����A������������Ȃ��̂ł܂����Ƃ��Ȃ�B
```PowerShell
>ruby csv_from_export_cda.rb �����o�����f�[�^\apple_health_export\export_cda.xml
```
����Ȋ������ȁB


# apple_health_export �o�͂̐��` format_cda.rb
[https://hs9587.hatenablog.com/entry/2020/04/19/140001]

�O�i  
iPhone �ɓ��ꂽ�w���X�P�A���� csv �ɏo�����B

��������Ƃ���Ȋ����ɂȂ�
```csv
20200418053000+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
20200417211100+0900,36,degC,HKQuantityTypeIdentifierBodyTemperature
20200417155800+0900,36.1,degC,HKQuantityTypeIdentifierBodyTemperature
20200417055000+0900,36.2,degC,HKQuantityTypeIdentifierBodyTemperature
20200416221500+0900,36,degC,HKQuantityTypeIdentifierBodyTemperature
20200416054000+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
20200415052400+0900,35.9,degC,HKQuantityTypeIdentifierBodyTemperature
```
�\���킩��Ղ��`�����A�R���s���[�^�[�œǂނ̂ł͂Ȃ��A�l������Ȃ�����������`���Ă��ǂ��B

format_cda.rb
```ruby:format_cda.rb
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
��������Ƃ���Ȋ���
```csv
20-04-18 05:30 +09      35.9    degC    BodyTemperature
20-04-17 21:11 +09      36.0    degC    BodyTemperature
20-04-17 15:58 +09      36.1    degC    BodyTemperature
20-04-17 05:50 +09      36.2    degC    BodyTemperature
20-04-16 22:15 +09      36.0    degC    BodyTemperature
20-04-16 05:40 +09      35.9    degC    BodyTemperature
20-04-15 05:24 +09      35.9    degC    BodyTemperature
```
CSV([https://docs.ruby-lang.org/ja/latest/library/csv.html]) �̕��i�l���]��g��Ȃ��@�\���g�����̂ŏ����R�[�h�̐����B

���i CSV.parse �Ƃ� CSV.read �œǂނƔz��̔z��ɂȂ�̂ł��낢�낵�Ă����B
����͓��͂��������`���Ă����o�͂���t�B���^�[���ǂ��Ǝv�����A CSV.filter
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#S_FILTER] ���������B

�J���}��؂�̓R���s���[�^�Ƃ̂����ɂ͗ǂ��̂����ǁA�l������ɂ͂�����Ƃ��邳�����ȁA�o�͂̓^�u�ɂ��܂��傤�A�I�v�V�����Ɂuout_col_sep: "\t"�v�B
���o�̓I�v�V�����ق��̂͂��̕�
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#S_NEW] ���Q�l�ɁA�o�͂Ȃ̂œ��Ɂuout_�v���uoutput_�v��t����Ƃ̂��ƁB

�����̕ϊ��ɂ� converters: �I�v�V������ CSV::Converters
[https://docs.ruby-lang.org/ja/latest/class/CSV.html#C_-CONVERTERS] ���g���Ă݂�B

�R�����@�[�^�[�̎���
```ruby
  row3: ->(cell, info){ info.index != 3 ? cell : cell[24..-1]   },
  row1: ->(cell, info){ info.index != 1 ? cell : '%6.1f' % cell },
  row0: ->(cell, info){ info.index != 0 ? cell : \
          Time.parse(cell).strftime('%Y-%m-%d %H:%M %z')[2..-3] },
```
���̓K�p���A�񐔂̎w��Ƃ��͂Ȃ��݂����B�ǂ̗�ɂ��݂�ȓK�p�����̂ő���������񐔂��m�F����B�u?�v�O�����Z�q(
[https://docs.ruby-lang.org/ja/latest/doc/spec=2foperator.html#cond]
)�A�{���͔ے�̏����͔�����ׂ��Ȃ񂾂��A�ϕ������ɂ�������������Ղ����Ƃ��������B���� row2 �͘ԂȂ̂ŏ����Ȃ��B

�R�����@�[�^�[���g�����Ƃɂ�����ACSV.filter �̃u���b�N�ł�邱�Ƃ������Ȃ����̂ŋ���ۂ̃u���b�N��t����u {} �v
```ruby
CSV.filter(out_col_sep: "\t", converters: [:row0, :row1, :row3]) {}
```
����ۂ̃u���b�N���āA���ɂȂ񂩏����������̂��ȁB


# �ŋ�1���� latest_cda.rb

���񂾂񐔎����܂��Ă��āA��ޕʂɍŋ߂� 1,2�T�ԕ������W�߂āA��1�����ɂ܂Ƃ߂悤���ȁB��������Ȃ񂩉������������Ƃ������A�N��v�Z�Ƃ��B
```ruby:latest_cda.rb
cdas = File.read(ARGV[0]).split "\n"

temperatures = cdas.select{ |cda| /Temperature/ =~ cda }
pressures    = cdas.select{ |cda| /Pressure/    =~ cda }
masses       = cdas.select{ |cda| /Mass/        =~ cda }

hs = Time.local *(ARGV[1].split /\D/)
birthday = "#{hs.strftime '%Y/%m/%d'} (#{Time.at(Time.now - hs).year - 1970})"

t, p, m = ARGV[2].to_s.split /\D/

[
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
    # .to_a .compact �� ARGV[3 �ȍ~] �������������΍�
  '',
  temperatures.take(t ? t.to_i : 25),
  '',
  pressures.sort.reverse.take(p ? p.to_i : 16),
  '',
  masses.take(m ? m.to_i : 13),
] \
  .flatten.join("\n").display

```
ARGV �ŏ��̈����Ƀf�[�^�\�[�X�̃t�@�C�����A�O�f format_cda.rb �̏o�́B  
���̈����ɐ��N�����A�K�X�񐔎������ŋ�؂�B
```ruby
cdas = File.read(ARGV[0]).split "\n"
```
```ruby
hs = Time.local *(ARGV[1].split /\D/)
```
#read �Ƃ� #split �Ƃ� #local �ŃG���[�ɂȂ邵�A���������܂ł͕K�{�Ƃ������ƂɁB

��3�����ɁA�̉������̏d�̕\���s�������̏��ɁA�񐔎������ŋ�؂��āB
```ruby
t, p, m = ARGV[2].to_s.split /\D/
```
���������� #to_s �������đS�� nil ������B
�����͏��Ȃ�������� nil ���ƁA���� #take ���̎O�����Z�q�Ŋ���l�ɂ���ւ��B

����l�͑̉�2�T�ԕ��ɍ��킹�� A4�ꖇ�ɓ���悤�ɈĔz�B  
�z���Ƃ��]���̒������l���Ĉ����ɐݒ�ł���悤�ɂ����B

���������͑O�q�N��v�Z������ŕ����Ƀ�����
```ruby
  ARGV[3..-1].to_a.insert(1, birthday).compact.join(', '),
```
#to_a #compact �� ARGV[3 �ȍ~] �������������΍�B

# �ʂ̂�� csv_from_export.rb
�O�q export.xml �̕��� CSV �ɂ���B

csv_from_export.rb
```ruby:csv_from_export.rb
require 'rexml/document'

REXML::Document.new(ARGF.read) \
  .root \
  .get_elements('//Record') \
  .map do |record|
    #record.attributes.inspect
    #record.attribute('type').value
    %w[value unit startDate endDate creationDate type sourceName sourceVersion]\
    .map do |name|
      record.attribute(name).value.sub('HKQuantityTypeIdentifier','')
    end \
    .join(',')
  end \
  .join("\n") \
  .display

```
���ƁA�X�N���v�g�`�������Ɍv���p�� err�v�����g�c���Ă邩���B

�v���O�����͂����Ƃ��āA�f�[�^�ɂ��Ă�����ƃR�����g�B
��{�I�ɁARecord�v�f������ł���B  
���̒��ŁA�����́A�ō�����(Systolic)�ƍŒጌ��(Diastolic)�����ꂼ��Ƀt���b�g�ɕ���ł���̂ƁA
Correlation�v�f�̒��ɓ���g�ɂȂ��Ă�̂ƁA��d�ɋL�q����Ă���B
�v���O�����ł� Correlation�^�O�̂��Ƃ͋C�ɂƂ߂Ȃ��� CSV �ɂ͂��̂܂ܓ�d�ɏo�ė���B  
���Ȃ݂Ɍ��̔z�u�ꏊ�������Ⴄ(�t���b�g�̂͑O�̕��A�g�ɂȂ��Ă�͍̂Ō�)�̂ŁA
�o�ė��鏊������Ă�B

## oga_csv_from_export.rb
```ruby:oga_csv_from_export.rb
require 'oga'

Oga::XML::Parser.new(ARGF.read) \
  .parse \
  .xpath('//Record') \
  .map do |record|
    %w[value unit startDate endDate creationDate type sourceName sourceVersion]\
    .map do |key|
      record[key].sub('HKQuantityTypeIdentifier','')
    end \
    .join(',')
  end \
  .join("\n") \
  .display
```
�W���Y�t�� REXML ��������ƒx���̂ŁA
Oga�W�F�����C���X�g�[�����Ă���Ă݂��AC�G�N�X�e���V��������A���̑����C�u�����s�g�p�B
<pre>
 csv from export: require Oga. 6sec(nano) Ruby 2.4.5
 <-  900sec(CF-RZ6) REXML Ruby 2.4.4
 <- 3800sec(CF-S10) REXML Ruby 1.9.3
</pre>
�����Ⴄ���̑��������A����ł��b�̒P�ʂ̎��Ԃ��|����B

����ŕ����̓��ʏW�v�Agrep�L�[���[�h�� Climbed �ɂ���Əオ�����K���ADistance �ŃE�H�[�L���O�����j���O�̋����B
<pre>
 grep Step oga.export.csv | ruby -rtime -aF, -lne 'BEGIN{steps=Hash.new{0}}; steps[Date.parse $F[2]] += $F[0].to_i; END{steps.sort.map{|k,v| "#{k.strftime "%y-%m-%d(%a)"}:#{"%5d"%v}\n" }.join.display}' | less
</pre>

# �ʂ̂�W�v���` count_csv_from_export.rb
���̕ʂ̂�� CSV ������ƂɏW�v���`����B  
������Ƃ��đ��������(�����A�K���A��)�͑������A�����łȂ�����(�̉��A�̏d�A��)�͎������L���ĕ��ׂ�B
- erb �̂���
- i18n �ƁAt, l ���\�b�h

# ���܂�

head �̑���
```ruby
| ruby -pe "exit if $.==8"
```
����
```ruby
ruby -e "ARGF.readlines.select{|l|/2020-09/=~l}.join.display" oga.export.csv |
```
```ruby
| ruby -rnkf -ne "NKF.nkf('-Ws',$_).display"
```
