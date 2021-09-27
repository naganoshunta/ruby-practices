#!/usr/bin/env ruby
require 'optparse'
require 'date'

class Options
  attr_reader :year, :month
  def initialize
    get_options
  end

  private

  def get_options
    opts = OptionParser.new
    opts.on("-m", "--month MONTH", Integer) do |month|
      @month = month
    end
    opts.on("-y", "--year YEAR", Integer) do |year|
      @year = year
    end
    begin
      opts.parse!(ARGV)
    rescue => e
      puts e.message
      @month = nil
      @year = nil
    end
  end
end

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

  def invert_color(string)
    "\e[7m#{string}\e[0m"
  end

  def get_title
    [
      "#{@month}月 #{@year}年".center(20),
      "\n",
      ["日", "月", "火", "水", "木", "金", "土"].join(" "),
      "\n"
    ].
    join
  end

  def get_head_blanks
    "   " * @first_day.wday
  end

  def is_saturday?(date)
    date.saturday?
  end

  def is_today?(date)
    date == @today
  end

  def get_output
    @output = [get_title, get_head_blanks]
    @table.each do |date, string|
      case
      when is_saturday?(date) && is_today?(date)
        @output << invert_color(string) + "\n"
      when is_saturday?(date) && !is_today?(date)
        @output << string + "\n"
      when !is_saturday?(date) && is_today?(date)
        @output << invert_color(string) + " "
      when !is_saturday?(date) && !is_today?(date)
        @output << string + " "
      end
    end
    @output = @output.join
  end
end

options = Options.new
calendar = Calendar.new(options.year, options.month)
calendar.print_output
