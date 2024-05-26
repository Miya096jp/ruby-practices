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

header = "#{month}月 #{year}"
puts header.center(20)

all_days = "   " * first_day.wday

(first_day..last_day).each do |date|
  all_days += date.day.to_s.rjust(2)
  all_days += date.saturday? ? "\n" : " "
end
#最後の行は改行
print all_days

