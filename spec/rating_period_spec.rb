require 'minitest_helper'

describe Glicko2::RatingPeriod do
  before do
    @player = Glicko2::Player.from_obj(Rating.new(1500, 200, 0.06))
    @player1 = Glicko2::Player.from_obj(Rating.new(1400, 30, 0.06))
    @player2 = Glicko2::Player.from_obj(Rating.new(1550, 100, 0.06))
    @player3 = Glicko2::Player.from_obj(Rating.new(1700, 300, 0.06))
    @players = [@player, @player1, @player2, @player3]
    @period = Glicko2::RatingPeriod.new(@players)
  end

  describe ".new" do
    it "must assign players" do
      @period.players.must_include @player
      @period.players.must_include @player1
      @period.players.must_include @player2
      @period.players.must_include @player3
    end
  end

  describe ".ranks_to_score" do
    it "must return 1.0 when rank is less" do
      Glicko2::RatingPeriod.ranks_to_score(1, 2).must_equal 1.0
    end

    it "must return 0.5 when rank is equal" do
      Glicko2::RatingPeriod.ranks_to_score(1, 1).must_equal 0.5
    end

    it "must return 0.0 when rank is more" do
      Glicko2::RatingPeriod.ranks_to_score(2, 1).must_equal 0.0
    end
  end

  describe "complete rating period" do
    it "must be close to example" do
      @period.game([@player, @player1], [1, 2])
      @period.game([@player, @player2], [2, 1])
      @period.game([@player, @player3], [2, 1])
      @period.generate_next.players.each { |p| p.update_obj }
      obj = @player.obj
      obj.rating.must_be_close_to 1464.06, 0.01
      obj.rating_deviation.must_be_close_to 151.52, 0.01
      obj.volatility.must_be_close_to 0.05999, 0.00001
    end
  end
end
