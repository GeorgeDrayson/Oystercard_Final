require 'oystercard'

describe Oystercard do

  subject(:oystercard) { described_class.new }

  let(:fake_station) { double :station }
  let(:fake_station2) { double :station2 }

  maximum_balance = Oystercard::MAXIMUM_BALANCE
  minimum_fare = Oystercard::MINIMUM_FARE
  penalty_fare = Journey::PENALTY_FARE

  describe '#balance' do
    it 'initializes with a balance of zero' do
      expect(oystercard.balance).to eq 0
    end
  end

  describe '#top_up' do
    it 'allows balance to be topped up' do
      expect { oystercard.top_up(5) }.to change { oystercard.balance }.by 5
    end
    it "doesn't allow topping up past a maximum limit of £90" do
      illegal_topup =  maximum_balance + 1 - oystercard.balance
      expect { oystercard.top_up(illegal_topup) }.to raise_error "Maximum balance of £#{maximum_balance} exceeded!"
    end
  end

  context 'When balance is 10' do

    before do
      oystercard.top_up(10)
    end

    describe '#touch_in' do
      it 'changes status :in_transit' do
        expect { oystercard.touch_in(fake_station) }.to change { oystercard.entry_station }.from(nil).to fake_station
      end

      it 'stores entry station data on card' do
        expect { oystercard.touch_in(fake_station) }.to change { oystercard.entry_station }.from(nil).to fake_station
      end
    end

    describe '#touch_out' do
      it 'changes status :not_in_transit' do
        oystercard.touch_in(fake_station)
        expect { oystercard.touch_out(fake_station) }.to change { oystercard.entry_station }.from(fake_station).to nil
      end
      it 'deducts minimum fare' do
        oystercard.touch_in(fake_station)
        expect { oystercard.touch_out(fake_station) }.to change { oystercard.balance }.by -minimum_fare
      end
    end

    describe '#in_journey?' do
      it 'returns true if status is :in_transit' do
        oystercard.touch_in(fake_station)
        expect(oystercard).to be_in_journey
      end

      it 'returns false if status is :not_in_transit' do
        oystercard.touch_in(fake_station)
        oystercard.touch_out(fake_station)
        expect(oystercard).not_to be_in_journey
      end
    end

    describe '#journey_history' do
      it 'intializes with a blank journey history' do
        expect(oystercard.journey_history).to be_empty
      end
      it 'returns the last journey made' do
        oystercard.touch_in(fake_station)
        oystercard.touch_out(fake_station2)
        expect(oystercard.journey_history[0].entry_station).to eq fake_station
        expect(oystercard.journey_history[0].exit_station).to eq fake_station2
      end
    end

    describe 'touch_out edge cases' do
      it 'charges penalty fare for no touch in' do
        expect { oystercard.touch_out(fake_station2)}.to change { oystercard.balance }.by -penalty_fare
      end
    end

    describe 'touch_in edge cases' do
      it 'charges penalty fare for no touch out, double touch in' do
        oystercard.touch_in(fake_station)
        expect { oystercard.touch_in(fake_station)}.to change { oystercard.balance }.by -penalty_fare
      end
    end

    describe 'journey_history edge cases' do
      it "should add an incomplete journey when you don't touch in" do
        oystercard.touch_out(fake_station2)
        expect( oystercard.journey_history[0].entry_station ).to eq nil
        expect( oystercard.journey_history[0].exit_station ).to eq fake_station2
      end
      it "should add an incomplete journey when you don't touch out" do
        oystercard.touch_in(fake_station)
        oystercard.touch_in(fake_station)
        oystercard.touch_out(fake_station2)
        expect( oystercard.journey_history[0].entry_station ).to eq fake_station
        expect( oystercard.journey_history[0].exit_station ).to eq nil
        expect( oystercard.journey_history[1].entry_station ).to eq fake_station
        expect( oystercard.journey_history[1].exit_station ).to eq fake_station2
      end
    end

  end

  describe '#minimum_fare' do
    it 'denies touch_in if balance is less than Minimum Fare' do
      expect{ oystercard.touch_in(fake_station) }.to raise_error("Minimum balance for travel is £#{minimum_fare}")
    end
  end


end
