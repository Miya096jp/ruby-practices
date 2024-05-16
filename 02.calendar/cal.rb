#!/usr/bin/env ruby
require 'date'
require 'optparse'

#デフォルト年月を取得
default_year = Date.today.year
default_month = Date.today.month

#オプション入力を取得
options = ARGV.getopts('y:', 'm:')

#オプション入力があればその値を、なければデフォルト値をそれぞれ設定
year = options["y"] ? options["y"].to_i : default_year
month = options["m"] ? options["m"].to_i : default_month

#月の初日と最終日をもとめる
first_day = Date.new(year, month, +1).day
last_day = Date.new(year, month, -1).day

#月の日数を配列に格納
all_days = (first_day..last_day).to_a

#月のそれぞれの日に対応する曜日の配列を作成
weekdays = all_days.map{|day| 
  dates =  Date.new(year, month, day)
  dates.wday
  }

#[日付,曜日]のセットになるように配列を結合
days_and_weekdays = all_days.zip(weekdays)

#月初日の曜日番号を取得
first_weekday = days_and_weekdays[0][1]

#曜日番号は第1週の空欄数と等しいため、スペースを該当する回数配列先頭に挿入
first_weekday.times {days_and_weekdays.unshift(["  ", "x"])}

#月と年度を表示し中央揃え 
header = "#{month}月 #{year}"
puts header.center(20)


#1から9の日付の先頭に半角スペースを追加
days_in_calendar = days_and_weekdays.each { |day| day[0] = day[0].to_s.rjust(2) }


#土曜日で折り返してカレンダーを表示
print "日 月 火 水 木 金 土\n"
days_in_calendar.each do |date, weekday|
  if weekday == 6
    all_days = date + "\n"
  else
    all_days = date + " "
  end
  print all_days
end
