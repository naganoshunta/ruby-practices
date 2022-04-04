#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  options = ARGV.getopts('l')
  wc(ARGV, option_l: options['l'])
end

def wc(paths, option_l: false)
  return wc_from_stdin if paths.empty?

  wc_tables = generate_wc_tables(paths)
  output_wc(wc_tables, option_l: option_l)
end

def wc_from_stdin
  str = $stdin.read
  wc_table = {
    line_count: count_lines(str),
    word_count: count_words(str),
    bytesize: count_bytesize(str)
  }
  printf "%<line_count>8s%<word_count>8s%<bytesize>8s\n", wc_table
end

def generate_wc_tables(paths)
  wc_tables = []

  paths.each do |path|
    wc_tables << generate_wc_table(path)
  end

  return wc_tables if wc_tables.size <= 1

  wc_tables << generate_total_row(wc_tables)
end

def generate_wc_table(path)
  return { error_message: "wc: #{path}: read: Is a directory" } if File.directory?(path)
  return { error_message: "wc: #{path}: open: No such file or directory" } unless File.exist?(path)

  str = File.read(path)
  {
    line_count: count_lines(str),
    word_count: count_words(str),
    bytesize: count_bytesize(str),
    file_name: path
  }
end

def generate_total_row(wc_tables)
  {
    line_count: calculate_total(wc_tables, :line_count),
    word_count: calculate_total(wc_tables, :word_count),
    bytesize: calculate_total(wc_tables, :bytesize),
    file_name: 'total'
  }
end

def calculate_total(wc_tables, key)
  wc_tables.map { |wt| wt[key] }.compact.sum
end

def output_wc(wc_tables, option_l: false)
  wc_tables.each do |wc_table|
    if wc_table[:error_message].nil?
      next printf "%<line_count>8s %<file_name>s\n", wc_table if option_l

      printf "%<line_count>8s%<word_count>8s%<bytesize>8s %<file_name>s\n", wc_table
    else
      printf "%<error_message>s\n", wc_table
    end
  end
end

def count_lines(str)
  str.count("\n")
end

def count_words(str)
  str.strip.split(/\s+/).size
end

def count_bytesize(str)
  str.bytesize
end

main if __FILE__ == $PROGRAM_NAME
