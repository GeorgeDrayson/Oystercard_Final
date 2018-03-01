require './lib/journey.rb'
require 'journey_log'
class Oystercard

  MAXIMUM_BALANCE = 90
  MINIMUM_FARE = 1

  attr_reader :balance, :entry_station, :journey_log

  def initialize
    @balance = 0.0
    @entry_station = nil
    @journey_log = JourneyLog.new
  end

  def top_up(amount)
    raise Exception.new("Maximum balance of £#{MAXIMUM_BALANCE} exceeded!") if @balance + amount > MAXIMUM_BALANCE
    @balance += amount
  end

  def touch_in(station)
    raise Exception.new("Minimum balance for travel is £#{MINIMUM_FARE}") if @balance < MINIMUM_FARE
    deduct(journey_log.journey.fare) if journey_log.journey != nil
    journey_log.start(station)
  end

  def touch_out(station)
    journey_log.finish(station)
    deduct(journey_log.history[-1].fare)
    journey_log.journey = nil
  end

  def in_journey?
    !!journey_log.journey
  end

  private

  def deduct(fare)
    @balance -= fare
  end

end
