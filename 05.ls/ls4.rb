#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

COLUMN_COUNT = 3

def main
  options = ARGV.getopts('l')
  path = ARGV[0] || Dir.pwd
  ls(path, option_l: options['l'])
end

def ls(path, option_l: false)
  files = read_files(path)
  return if files.empty?

  if option_l
    file_stats = read_file_stats(path, files)
    return ls_with_option_l(file_stats)
  end

  ls_with_no_options(files)
end

def read_files(path)
  raise ArgumentError, "#{File.basename(__FILE__)}: #{path}: No such file or directory" unless File.exist?(path) || File.symlink?(path)
  return Dir.glob('*', base: path) if File.directory?(path)

  [path]
end

def ls_with_no_options(files)
  row_count       = calculate_row_count(files)
  max_width       = calculate_max_width(files)
  formatted_files = format_files(files, row_count)
  printf_files(formatted_files, max_width)
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

def read_file_stats(path, files)
  file_stats = []
  files.each do |file|
    file_stat                 = {}
    fs                        = File.lstat("#{path}/#{file}")
    octal_type                = format('%06o', fs.mode)[0..1]
    octal_permissions         = format('%06o', fs.mode)[3..-1]
    octal_special_permissions = format('%06o', fs.mode)[2]
    file_stat[:type]          = translate_octal_type_into_symbol(octal_type)
    file_stat[:permissions]   = translate_octal_permissions_into_symbols(octal_permissions, octal_special_permissions)
    file_stat[:link]          = fs.nlink.to_s
    file_stat[:user]          = Etc.getpwuid(fs.uid).name
    file_stat[:group]         = Etc.getgrgid(fs.gid).name
    file_stat[:size]          = fs.size.to_s
    file_stat[:timestamp]     = generate_timestamp(fs.mtime)
    file_stat[:name]          = generate_file_name(path, file)
    file_stat[:blocks]        = fs.blocks

    file_stats << file_stat
  end

  file_stats
end

def ls_with_option_l(file_stats)
  format_specifier = generate_format_specifier_of_file_stats(file_stats)

  puts "total #{file_stats.map { |file_stat| file_stat[:blocks] }.sum}"
  file_stats.each do |file_stat|
    printf(format_specifier, file_stat)
  end
end

def generate_format_specifier_of_file_stats(file_stats)
  type_width        = file_stats.map { |file_stat| file_stat[:type].length }.max
  permissions_width = file_stats.map { |file_stat| file_stat[:permissions].length }.max
  link_width        = file_stats.map { |file_stat| file_stat[:link].length }.max
  user_width        = file_stats.map { |file_stat| file_stat[:user].length }.max
  group_width       = file_stats.map { |file_stat| file_stat[:group].length }.max
  size_width        = file_stats.map { |file_stat| file_stat[:size].length }.max
  timestamp_width   = file_stats.map { |file_stat| file_stat[:timestamp].length }.max
  name_width        = file_stats.map { |file_stat| file_stat[:name].length }.max

  "%<type>#{type_width}s%<permissions>#{permissions_width}s  %<link>#{link_width}s %<user>-#{user_width}s  %<group>-#{group_width}s  %<size>#{size_width}s %<timestamp>#{timestamp_width}s %<name>-#{name_width}s\n"
end

def translate_octal_type_into_symbol(octal_type)
  {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }[octal_type]
end

def translate_octal_permissions_into_symbols(octal_permissions, octal_special_permissions)
  symbolic_permissions = []
  octal_permissions.chars.each do |octal_permission, index|
    binary_permissions = format('%03b', octal_permission)
    symbolic_permissions << translate_binary_permissions_into_symbols(binary_permissions)
  end

  binary_special_permissions = format('%03b', octal_special_permissions)
  symbolic_permissions = overwrite_symbols_with_special_permissions(symbolic_permissions, binary_special_permissions)

  symbolic_permissions.join
end

def translate_binary_permissions_into_symbols(binary_permissions)
  list_of_permission_symbols = ['r', 'w', 'x']
  symbolic_permissions       = []
  binary_permissions.chars.each_with_index do |permission, index|
    if permission == '1'
      symbolic_permissions << list_of_permission_symbols[index]
    else
      symbolic_permissions << '-'
    end
  end

  symbolic_permissions
end

def overwrite_symbols_with_special_permissions(symbolic_permissions, binary_special_permissions)
  return symbolic_permissions if binary_special_permissions == '000'

  if binary_special_permissions[0] == '1'
    symbolic_permissions[0][2] =
      if symbolic_permissions[0][2] == 'x'
        's'
      elsif symbolic_permissions[0][2] == '-'
        'S'
      end
  end

  if binary_special_permissions[1] == '1'
    symbolic_permissions[1][2] =
      if symbolic_permissions[1][2] == 'x'
        's'
      elsif symbolic_permissions[1][2] == '-'
        'S'
      end
  end

  if binary_special_permissions[2] == '1'
    symbolic_permissions[2][2] =
      if symbolic_permissions[2][2] == 'x'
        't'
      elsif symbolic_permissions[2][2] == '-'
        'T'
      end
  end

  symbolic_permissions
end

def generate_timestamp(time)
  timestamp = []
  timestamp << time.strftime('%_m')
  timestamp << time.strftime('%_d')
  timestamp <<
    if time.to_date.between?(Time.now.to_date << 6, Time.now.to_date >> 6)
      time.strftime('%H:%M')
    else
      time.year.to_s
    end
  timestamp.join(' ')
end

def generate_file_name(path, file)
  return "#{file} -> #{File.readlink("#{path}/#{file}")}" if File.symlink?("#{path}/#{file}")

  file
end

main if __FILE__ == $PROGRAM_NAME
