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

(first_day..last_day).each do |date|
  if date.day == 1
    x = date.wday
    if date.wday == 6
      all_days = "   " * x + " 1\n"
    else
      all_days = "   " * x + " 1 "
    end
  elsif date.wday == 6
    all_days = date.day.to_s.rjust(2) + "\n"
  else
    all_days = date.day.to_s.rjust(2) + " "
  end
  print all_days
end

