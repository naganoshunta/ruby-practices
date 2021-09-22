#!/usr/bin/env ruby
require 'optparse'
require 'date'

Current_Month = Date.today.month
Current_Year = Date.today.year

params = {}
opts = OptionParser.new
opts.on("-m", "--month MONTH", desc = "表示する月を指定してください") { |month|
  params[:month] = month.to_i
}

opts.on("-y", "--year YEAR", desc = "表示する年を指定してください") { |year|
  params[:year] = year.to_i
}
opts.parse!(ARGV)

def valid_date?(params)
  if Date.valid_date?(params[:year], params[:month], 1)
    true
  else
    false
  end
end

if valid_date?(params)
  first_day = Date.new(params[:year], params[:month], 1)
  last_day = Date.new(params[:year], params[:month], -1)
else
  first_day = Date.new(Current_Year, Current_Month, 1)
  last_day = Date.new(Current_Year, Current_Month, -1)
end

dates = {}
first_day.step(last_day, step = 1) { |date|
  dates[date] = date.strftime('%e')
}

dates.each do |date, str|
  dates[date] = "\e[7m#{str}\e[0m" if date == Date.today
end

dates.each do |date, str|
  if date.saturday?
    dates[date] = str + "\n"
  else
    dates[date] = str + " "
  end
end

month_year_title = "#{first_day.month}月 #{first_day.year}年".center(20)
weeks = ["日", "月", "火", "水", "木", "金", "土"]
weeks_title = weeks.join(" ")
calendar_title = month_year_title + "\n" + weeks_title + "\n"
calendar_blanks = "   " * first_day.wday

calendar = [calendar_title, calendar_blanks, dates.values.join, "\n"]
print calendar.join
