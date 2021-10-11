# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'bowling'

class BowlingTest < Minitest::Test
  def test_score139
    score = '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,6,4,5'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 139
    assert_equal expected, result
  end

  def test_score164
    score = '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,X,X'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 164
    assert_equal expected, result
  end

  def test_score107
    score = '0,10,1,5,0,0,0,0,X,X,X,5,1,8,1,0,4'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 107
    assert_equal expected, result
  end

  def test_score134
    score = '6,3,9,0,0,3,8,2,7,3,X,9,1,8,0,X,X,0,0'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 134
    assert_equal expected, result
  end

  def test_score300
    score = 'X,X,X,X,X,X,X,X,X,X,X,X'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 300
    assert_equal expected, result
  end

  def test_score0
    score = '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0'
    scoresheet = Bowling::ScoreSheet.new(score)
    result = Bowling::Scorer.calculate(scoresheet)
    expected = 0
    assert_equal expected, result
  end
end
