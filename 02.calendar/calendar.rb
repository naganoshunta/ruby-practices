#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'date'

class Options
  attr_reader :year, :month

  def initialize
    parse_options
  end

  private

  def parse_options
    opts = OptionParser.new
    opts.on('-m', '--month MONTH', /(^[1-9]$)|(^1[0-2]$)/, Integer) do |month|
      @month = month
    end
    opts.on('-y', '--year YEAR', /^-?\d+$/, Integer) do |year|
      @year = year
    end
    begin
      opts.parse!(ARGV)
    rescue OptionParser::ParseError => e
      puts e.message
    end
  end
end

class Calendar
  attr_reader :today, :validity, :first_day, :last_day, :year, :month, :date_table, :calendar

  def initialize(year, month)
    @today = Date.today
    @validity = valid_date?(year, month)
    @first_day = identify_first_day(year, month)
    @last_day = identify_last_day(year, month)
    @year = @first_day.year
    @month = @first_day.month
    generate_date_table
    generate_calendar
  end

  def output
    print @calendar
  end

  private

  def valid_date?(year, month)
    Date.valid_date?(year, month, 1)
  end

  def identify_first_day(year, month)
    if valid_date?(year, month)
      Date.new(year, month, 1)
    else
      Date.new(@today.year, @today.month, 1)
    end
  end

  def identify_last_day(year, month)
    if valid_date?(year, month)
      Date.new(year, month, -1)
    else
      Date.new(@today.year, @today.month, -1)
    end
  end

  def generate_date_table
    @date_table = {}
    @first_day.step(@last_day) do |date|
      @date_table[date] = date.strftime('%e')
    end
    mark_today
    add_newline_or_halfspace
  end

  def invert_color(string)
    "\e[7m#{string}\e[0m"
  end

  def mark_today
    @date_table[@today] = invert_color(@date_table[@today]) if @date_table.include?(@today)
  end

  def add_newline_or_halfspace
    @date_table.each do |date, string|
      @date_table[date] = date.saturday? ? "#{string}\n" : "#{string} "
    end
  end

  def calendar_title
    [
      "#{@month}月 #{@year}年".center(20),
      "\n",
      %w[日 月 火 水 木 金 土].join(' '),
      "\n"
    ].join
  end

  def calendar_head_blank
    '   ' * @first_day.wday
  end

  def generate_calendar
    @calendar = [
      calendar_title,
      calendar_head_blank,
      @date_table.values.join,
      "\n"
    ].join
  end
end

options = Options.new
calendar = Calendar.new(options.year, options.month)
calendar.output
