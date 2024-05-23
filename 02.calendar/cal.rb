#!/usr/bin/env ruby
require 'date'
require 'optparse'
require 'debug'

default_year = Date.today.year
default_month = Date.today.month

options = ARGV.getopts('y:', 'm:')

year = options["y"] ? options["y"].to_i : default_year
month = options["m"] ? options["m"].to_i : default_month

first_day = Date.new(year, month, +1)
last_day = Date.new(year, month, -1)

days_and_weekdays = (first_day..last_day).map do |date_object|
  [date_object.day.to_s.rjust(2), date_object.wday]
end

first_weekday = days_and_weekdays[0][1]
first_weekday.times {days_and_weekdays.unshift(["  ", "x"])}

header = "#{month}月 #{year}"
puts header.center(20)

print "日 月 火 水 木 金 土\n"
days_and_weekdays.each do |day, weekday|
  if weekday == 6
    all_days = day + "\n"
  else
    all_days = day + " "
  end
  print all_days
end

