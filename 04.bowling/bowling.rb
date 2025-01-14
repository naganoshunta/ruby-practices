#!/usr/bin/env ruby
# frozen_string_literal: true

class BowlingScorer
  def self.calculate(score)
    new.calculate(score)
  end

  def calculate(score)
    frames = to_frames(score)
    [
      calculate_base_points(frames),
      calculate_strike_points(frames),
      calculate_spare_points(frames)
    ].sum
  end

  private

  def to_frames(score)
    shots = convert_score_to_shots(score)
    convert_shots_to_frames(shots)
  end

  def convert_score_to_shots(score)
    scores = score.split(',')
    shots = []
    scores.each do |s|
      if s == 'X'
        shots << 10
        shots << 'no shot'
      else
        shots << s.to_i
      end
    end
    shots
  end

  def convert_shots_to_frames(shots)
    frames = {}
    shot_id = 0
    (1..9).each do |id|
      frames[id] = shots[shot_id, 2] || []
      shot_id += 2
    end
    frames[10] = shots[18..-1] || []
    frames.each_value do |frame|
      frame.delete('no shot')
    end
    frames
  end

  def strike?(frame)
    frame.first == 10
  end

  def spare?(frame)
    !strike?(frame) && frame.sum == 10
  end

  def calculate_base_points(frames)
    frames.values.flatten.sum
  end

  def calculate_strike_points(frames)
    strike_points = 0
    frames.each do |id, current_frame|
      break if id == 10

      if strike?(current_frame) && strike?(frames[id + 1]) && id != 9
        strike_points += frames[id + 1][0] + frames[id + 2][0]
      elsif strike?(current_frame)
        strike_points += frames[id + 1][0, 2].sum
      end
    end
    strike_points
  end

  def calculate_spare_points(frames)
    spare_points = 0
    frames.each do |id, current_frame|
      break if id == 10

      spare_points += frames[id + 1][0] if spare?(current_frame)
    end
    spare_points
  end
end

if $PROGRAM_NAME == __FILE__
  score = ARGV[0]
  puts BowlingScorer.calculate(score)
end
