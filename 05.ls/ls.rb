#!/usr/bin/env ruby
# frozen_string_literal: true

COLUMN_COUNT = 3

def main
  path = ARGV[0] || Dir.pwd
  ls(path)
end

def ls(path)
  files = read_files(path)
  return if files.empty?

  row_count       = calculate_row_count(files)
  max_width       = calculate_max_width(files)
  formatted_files = format_files(files, row_count)
  printf_files(formatted_files, max_width)
end

def read_files(path)
  raise ArgumentError, "#{File.basename(__FILE__)}: #{path}: No such file or directory" unless File.exist?(path) || File.symlink?(path)
  return Dir.glob('*', base: path) if File.directory?(path)

  [path]
end

def calculate_row_count(files)
  (files.size.to_f / COLUMN_COUNT).ceil
end

def calculate_max_width(files, margin = 1)
  files.map(&:length).max + margin
end

def format_files(files, row_count)
  sliced_files = files.each_slice(row_count).to_a
  sliced_files.last << nil while sliced_files.last.size < row_count
  sliced_files.transpose.map(&:compact)
end

def printf_files(formatted_files, max_width)
  formatted_files.each do |formatted_file|
    format_specifier = generate_format_specifier(formatted_file.size, max_width)
    printf format_specifier, *formatted_file
  end
end

def generate_format_specifier(column_count, max_width)
  base_format_specifier = "%-#{max_width}s"
  "#{base_format_specifier * column_count}\n"
end

main if __FILE__ == $PROGRAM_NAME
