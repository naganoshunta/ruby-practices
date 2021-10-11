#!/usr/bin/env ruby
# frozen_string_literal: true

module Bowling
  class ScoreSheet
    attr_reader :frames

    def initialize(score)
      @frames = to_frames(score)
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
      (1..9).each do |i|
        frames[i] = shots.shift(2)
      end
      frames[10] = shots.shift(shots.size)
      frames.each_value do |s|
        s.delete('no shot')
      end
      frames
    end
  end

  class Scorer
    def self.calculate(scoresheet)
      new.calculate(scoresheet.frames)
    end

    def calculate(frames)
      [
        calculate_base_points(frames),
        calculate_strike_points(frames),
        calculate_spare_points(frames)
      ].sum
    end

    private

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
      strike_points += frames[10][0] + frames[10][1] if strike?(frames[9])
      frames.each_key do |id|
        break if id == 9

        if strike?(frames[id]) && strike?(frames[id + 1])
          strike_points += frames[id + 1][0] + frames[id + 2][0]
        elsif strike?(frames[id])
          strike_points += frames[id + 1].sum
        end
      end
      strike_points
    end

    def calculate_spare_points(frames)
      spare_points = 0
      frames.each_key do |id|
        break if id == 10

        spare_points += frames[id + 1][0] if spare?(frames[id])
      end
      spare_points
    end
  end
end

if $PROGRAM_NAME == __FILE__
  score = ARGV[0]
  scoresheet = Bowling::ScoreSheet.new(score)
  puts Bowling::Scorer.calculate(scoresheet)
end
