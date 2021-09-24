#!/usr/bin/env ruby
require 'optparse'
require 'date'

opts = OptionParser.new
opts.on("-m", "--month [MONTH]", desc = "Specify MONTH (in Integer) for display") { |month|
  month.to_i
}
opts.on("-y", "--year [YEAR]", desc = "Specify YEAR (in Integer) for display") { |year|
  year.to_i
}
params = {}
opts.parse!(ARGV, into: params)

class Calendar
  attr_reader :today, :validity, :first_day, :last_day, :year, :month, :table, :output
  def initialize(year, month)
    @today = Date.today
    @validity = valid_date?(year, month)
    @first_day = get_first_day(year, month)
    @last_day = get_last_day(year, month)
    @year = get_year(year, month)
    @month = get_month(year, month)
    get_table
    get_output
  end

  def print_output
    print @output
  end

  private
  def valid_date?(year, month)
    Date.valid_date?(year, month, 1)
  end

  def get_first_day(year, month)
    if valid_date?(year, month)
      Date.new(year, month, 1)
    else
      Date.new(@today.year, @today.month, 1)
    end
  end

  def get_last_day(year, month)
    if valid_date?(year, month)
      Date.new(year, month, -1)
    else
      Date.new(@today.year, @today.month, -1)
    end
  end

  def get_year(year, month)
    get_first_day(year, month).year
  end

  def get_month(year, month)
    get_first_day(year, month).month
  end

  def get_table
    @table = {}
    @first_day.step(@last_day) do |date|
      @table[date] = date.strftime("%e")
    end
  end

  def copy_table
    @output = {}
    @table.each do |date, string|
      @output[date] = string
    end
  end

  def invert_color(string)
    "\e[7m#{string}\e[0m"
  end

  def mark_today
    @output[@today] = invert_color(@output[@today]) if @output.include?(@today)
  end

  def add_newline_or_space
    @output.each do |date, string|
      if date.saturday?
        @output[date] = string + "\n"
      else
        @output[date] = string + " "
      end
    end
  end

  def get_title
    "#{@month}月 #{@year}年".center(20) + "\n" + ["日", "月", "火", "水", "木", "金", "土"].join(" ") + "\n"
  end

  def get_head_blanks
    "   " * @first_day.wday
  end

  def get_output
    copy_table
    mark_today
    add_newline_or_space
    @output = [
      get_title,
      get_head_blanks,
      @output.values.join
    ].join
  end

end

calendar = Calendar.new(params[:year], params[:month])
calendar.print_output
