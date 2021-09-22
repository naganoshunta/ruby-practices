#!/usr/bin/env ruby
require 'optparse'
require 'date'

opts = OptionParser.new
opts.on("-m", "--month [MONTH]", desc = "表示する月を指定してください") { |month|
  month.to_i
}
opts.on("-y", "--year [YEAR]", desc = "表示する年を指定してください") { |year|
  year.to_i
}
params = {}
opts.parse!(ARGV, into: params)

def valid_date?(params)
  if Date.valid_date?(params[:year], params[:month], 1)
    true
  else
    false
  end
end

def identify_first_day(params)
  if valid_date?(params)
    Date.new(params[:year], params[:month], 1)
  else
    Date.new(Date.today.year, Date.today.month, 1)
  end
end

def identify_last_day(params)
  if valid_date?(params)
    Date.new(params[:year], params[:month], -1)
  else
    Date.new(Date.today.year, Date.today.month, -1)
    end
end

def identify_year(params)
  identify_first_day(params).year
end

def identify_month(params)
  identify_first_day(params).month
end


def obtain_calendar_info(params)
  {
    first_day: identify_first_day(params),
    last_day: identify_last_day(params),
    year: identify_year(params),
    month: identify_month(params),
    validity: valid_date?(params)
  }
end

def obtain_calendar(calendar_info)
  calendar = {}
  calendar_info[:first_day].step(calendar_info[:last_day], 1) do |date|
    calendar[date] = date.strftime("%e")
  end
  calendar
end

def mark_today(calendar)
  calendar[Date.today] = "\e[7m#{calendar[Date.today]}\e[0m" if calendar.has_key?(Date.today)
  calendar
end

def add_newlinechar_and_space(calendar)
  calendar.each do |date, date_for_display|
    if date.saturday?
      calendar[date] = date_for_display + "\n"
    else
      calendar[date] = date_for_display + " "
    end
  end
  calendar
end

def obtain_calendar_for_display(calendar)
  calendar.values.join
end

def make_calendar_title(calendar_info)
  month_year_title = "#{calendar_info[:month]}月 #{calendar_info[:year]}年".center(20)
  weeks_title = ["日", "月", "火", "水", "木", "金", "土"].join(" ")
  calendar_title = month_year_title + "\n" + weeks_title + "\n"
  calendar_title
end

def make_calendar_head_blanks(calendar_info)
  calendar_head_blanks = "   " * calendar_info[:first_day].wday
  calendar_head_blanks
end

def make_warning_message(calendar_info)
  if !calendar_info[:validity]
    "引数が未指定もしくは無効です。今月・今年のカレンダーを表示します。\n"
  end
end

def format_calendar_for_display(calendar_info, calendar_for_display)
  calendar_title = make_calendar_title(calendar_info)
  calendar_head_blanks = make_calendar_head_blanks(calendar_info)
  warning_message = make_warning_message(calendar_info)
  [warning_message, calendar_title, calendar_head_blanks, calendar_for_display].join
end

calendar_info = obtain_calendar_info(params)
calendar = obtain_calendar(calendar_info)
calendar = mark_today(calendar)
calendar = add_newlinechar_and_space(calendar)
calendar_for_display = obtain_calendar_for_display(calendar)
formatted_calendar = format_calendar_for_display(calendar_info, calendar_for_display)

print formatted_calendar

