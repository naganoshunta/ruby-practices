# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative 'ls3'

class LSTest < Minitest::Test
  def test_0_file_directory
    Dir.mktmpdir do |path|
      result = capture_io { ls(path) }
      assert_equal '', result.first
    end
  end

  def test_1_file_in_directory
    Dir.mktmpdir do |path|
      File.new("#{path}/file1", 'w')
      result = capture_io { ls(path) }
      assert_equal "file1 \n", result.first
    end
  end

  def test_2_files_in_directory
    Dir.mktmpdir do |path|
      index = 1
      2.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path) }
      assert_equal "file1 file2 \n", result.first
    end
  end

  def test_3_files_in_directory
    Dir.mktmpdir do |path|
      index = 1
      3.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path) }
      assert_equal "file1 file2 file3 \n", result.first
    end
  end

  def test_4_files_in_directory
    Dir.mktmpdir do |path|
      index = 1
      4.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path) }
      assert_equal "file1 file3 \nfile2 file4 \n", result.first
    end
  end

  def test_5_files_in_directory
    Dir.mktmpdir do |path|
      index = 1
      5.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path) }
      assert_equal "file1 file3 file5 \nfile2 file4 \n", result.first
    end
  end

  def test_6_files_in_directory
    Dir.mktmpdir do |path|
      index = 1
      6.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path) }
      assert_equal "file1 file3 file5 \nfile2 file4 file6 \n", result.first
    end
  end

  def test_invalid_path
    path = 'invalid_path'
    assert_raises(ArgumentError) { ls(path) }
  end
end

class LS3Test < Minitest::Test
  def test_with_r_option
    options = { 'r' => true }
    Dir.mktmpdir do |path|
      index = 1
      6.times do
        File.new("#{path}/file#{index}", 'w')
        index += 1
      end
      result = capture_io { ls(path, option_r: options['r']) }
      assert_equal "file6 file4 file2 \nfile5 file3 file1 \n", result.first
    end
  end
end
