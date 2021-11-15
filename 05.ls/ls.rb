#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_COLUMN_COUNT = 3

def main
  path = ARGV[0] || Dir.pwd
  ls(path: path)
end

def ls(path:)
  files = read_files(path: path)
  printf_files(files: files)
end

def read_files(path:)
  if File.directory?(path)
    Dir.glob('*', base: path)
  elsif File.file?(path)
    [path]
  else
    raise ArgumentError, "無効なパスです：#{path}"
  end
end

def printf_files(files:)
  format_specifier = generate_format_specifier(files: files)
  formatted_files  = format_files(files: files)
  formatted_files.each do |formatted_file|
    printf format_specifier, *formatted_file
  end
end

def generate_format_specifier(files:)
  column_count          = calculate_column_count(files: files)
  max_width             = calculate_max_width(files: files)
  base_format_specifier = "%-#{max_width}s"
  "#{base_format_specifier * column_count}\n"
end

def format_files(files:)
  column_count = calculate_column_count(files: files)
  row_count    = calculate_row_count(files: files)
  file_count   = calculate_file_count(files: files)
  sliced_files = files.each_slice(row_count).to_a
  unless (file_count % column_count).zero?
    (row_count - sliced_files.last.size).times do
      sliced_files.last << nil
    end
  end
  sliced_files.transpose
end

def calculate_column_count(files:)
  file_count = calculate_file_count(files: files)
  if file_count > MAX_COLUMN_COUNT
    MAX_COLUMN_COUNT
  else
    file_count
  end
end

def calculate_row_count(files:)
  column_count = calculate_column_count(files: files)
  file_count   = calculate_file_count(files: files)
  if (file_count % column_count).zero?
    file_count / column_count
  else
    file_count / column_count + 1
  end
end

def calculate_max_width(files:, margin: 1)
  files.map(&:length).max + margin
end

def calculate_file_count(files:)
  files.size
end

main if __FILE__ == $PROGRAM_NAME
