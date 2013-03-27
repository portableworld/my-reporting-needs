require 'rspec'
require_relative '../active_support'

describe Time do

  describe '#yesterday' do
    it 'returns exactly one previous day with no regard for business days' do
      time_to_test = Time.new(2012, 6, 5, 9, 0, 0) #=> June 5, 2012 9:00 AM (Tuesday)
      day_before   = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      time_to_test.yesterday.should eq(day_before)
    end

    it 'should work going from one month to another' do
      time_to_test = Time.new(2012, 6, 1, 9, 0, 0) #=> June 1, 2012 9:00 AM (Friday)
      day_before   = Time.new(2012, 5, 31, 9, 0, 0) #=> May 31, 2012 9:00 AM (Thursday)
      time_to_test.yesterday.should eq(day_before)
    end

    it 'should work going from one year to another' do
      time_to_test = Time.new(2012, 1, 1, 9, 0, 0) #=> June 1, 2012 9:00 AM (Sunday)
      day_before   = Time.new(2011, 12, 31, 9, 0, 0) #=> May 31, 2011 9:00 AM (Saturday)
      time_to_test.yesterday.should eq(day_before)
    end
  end

  describe '#last_business_day' do
    it 'should return Monday if given Tuesday' do
      time_to_test = Time.new(2012, 6, 5, 9, 0, 0) #=> June 5, 2012 9:00 AM (Tuesday)
      day_before   = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      time_to_test.last_business_day.should eq(day_before)
    end

    it 'should return Friday if given Monday' do
      time_to_test = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      day_before   = Time.new(2012, 6, 1, 9, 0, 0) #=> June 1, 2012 9:00 AM (Friday)
      time_to_test.last_business_day.should eq(day_before)
    end

    it 'should return Friday if given Tuesday where Monday is holiday' do
      # For 2012
      time_to_test = Time.new(2012, 5, 29, 9, 0, 0) #=> May 29, 2012 9:00 AM (Tuesday)
      day_before   = Time.new(2012, 5, 25, 9, 0, 0) #=> May 25, 2012 9:00 AM (Friday)
      time_to_test.last_business_day.should eq(day_before)

      # For 2013 (To assure that holidays don't need changing every year)
      time_to_test = Time.new(2013, 5, 28, 9, 0, 0) #=> May 28, 2013 9:00 AM (Tuesday)
      day_before   = Time.new(2013, 5, 24, 9, 0, 0) #=> May 24, 2013 9:00 AM (Friday)
      time_to_test.last_business_day.should eq(day_before)

      time_to_test = Time.new(2013, 11, 29, 9, 0, 0) #=> November 29, 2013 9:00 AM (Friday)
      day_before   = Time.new(2013, 11, 27, 9, 0, 0) #=> November 27, 2013 9:00 AM (Wednesday)
      time_to_test.last_business_day.should eq(day_before)

    end

    it 'should skip a holiday in the middle of the week' do
      time_to_test = Time.new(2012, 11, 23, 9, 0, 0) #=> November 23, 2012 9:00 AM (Friday)
      day_before   = Time.new(2012, 11, 21, 9, 0, 0) #=> November 21, 2012 9:00 AM (Wednesday)
      time_to_test.last_business_day.should eq(day_before)
    end

    it 'should return Thursday if given Monday and Friday is holiday' do
      time_to_test = Time.new(2014, 7, 7, 9, 0, 0) #=> July 7, 2014 9:00 AM (Monday)
      day_before   = Time.new(2014, 7, 3, 9, 0, 0) #=> July 3, 2014 9:00 AM (Thursday)
      time_to_test.last_business_day.should eq(day_before)
    end

    it 'should return Friday if given Sunday' do
      time_to_test = Time.new(2013, 2, 10, 9, 0, 0) #=> February 10, 2013 9:00 AM (Sunday)
      day_before   = Time.new(2013, 2, 8, 9, 0, 0) #=> February 8, 2013 9:00 AM (Friday)
      time_to_test.last_business_day.should eq(day_before)
    end

  end

  describe '#business_days_ago' do
    it 'should return Monday if Tuesday and (1) is given' do
      time_to_test = Time.new(2012, 6, 5, 9, 0, 0) #=> June 5, 2012 9:00 AM (Tuesday)
      day_before   = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      time_to_test.business_days_ago(1).should eq(day_before)
    end

    it 'should return Friday if Monday and (1) is given' do
      time_to_test = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      day_before   = Time.new(2012, 6, 1, 9, 0, 0) #=> June 1, 2012 9:00 AM (Friday)
      time_to_test.business_days_ago(1).should eq(day_before)
    end

    it 'should return Wednesday if Monday and (3) is given' do
      time_to_test = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      day_before   = Time.new(2012, 5, 30, 9, 0, 0) #=> May 30, 2012 9:00 AM (Wednesday)
      time_to_test.business_days_ago(3).should eq(day_before)
    end

    it 'should skip holidays' do
      time_to_test = Time.new(2012, 6, 4, 9, 0, 0) #=> June 4, 2012 9:00 AM (Monday)
      day_before   = Time.new(2012, 5, 25, 9, 0, 0) #=> May 25, 2012 9:00 AM (Friday)
      time_to_test.business_days_ago(5).should eq(day_before)
    end
  end

  describe 'Time#week_of_month' do
    context 'given October 3rd, 2012' do
      before {Time.stub(:now) {Time.new(2012, 10, 3)}}
      it 'returns 1' do
        Time.week_of_month.should eq(1)
      end
    end

    context 'given October 9th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 10, 9)}}
      it 'returns 2' do
        Time.week_of_month.should eq(2)
      end
    end

    context 'given October 15th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 10, 15)}}
      it 'returns 3' do
        Time.week_of_month.should eq(3)
      end
    end

    context 'given November 6th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 11, 6)}}
      it 'returns 2' do
        Time.week_of_month.should eq(2)
      end
    end

    context 'given November 30th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 11, 30)}}
      it 'returns 5' do
        Time.week_of_month.should eq(5)
      end
    end

    context 'given December 4th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 12, 4)}}
        it 'returns 1' do
          Time.week_of_month.should eq(1)
        end
    end

    context 'given December 7th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 12, 7)}}
        it 'returns 1' do
          Time.week_of_month.should eq(1)
        end
    end

    context 'given December 31th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 12, 31)}}
      it 'returns 5' do
        Time.week_of_month.should eq(5)
      end
    end

    context 'given July 11th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 7, 11)}}
      it 'returns 2' do
        Time.week_of_month.should eq(2)
      end
    end

    context 'given June 4th, 2012' do
      before {Time.stub(:now) {Time.new(2012, 6, 4)}}
      it 'returns 2' do
        Time.week_of_month.should eq(2)
      end
    end

    context 'given June 28th, 2013' do
      before {Time.stub(:now) {Time.new(2013, 6, 28)}}
      it 'returns 4' do
        Time.week_of_month.should eq(4)
      end
    end

    context 'given August 13th, 2013' do
      before {Time.stub(:now) {Time.new(2013, 8, 13)}}
      it 'returns 3' do
        Time.week_of_month.should eq(3)
      end
    end

    context 'given September 13th, 2013' do
      before {Time.stub(:now) {Time.new(2013, 9, 13)}}
      it 'returns 2' do
        Time.week_of_month.should eq(2)
      end
    end
  end

  describe '#between_times' do
    it 'returns "12:00 - 12:30" for "12:06"' do
      Time.new(2012, 11, 12, 12, 06).between_times.should eq('12:00 - 12:30')
    end

    it 'returns "13:30 - 14:00" for "13:45"' do
      Time.new(2012, 11, 12, 13, 45).between_times.should eq('13:30 - 14:00')
    end

    it 'returns "23:30 - 24:00" for "23:55"' do
      Time.new(2012, 11, 12, 23, 55).between_times.should eq('23:30 - 24:00')
    end

    it 'returns "00:00 - 00:30" for "00:14"' do
      Time.new(2012, 11, 12, 0, 14).between_times.should eq('00:00 - 00:30')
    end

    it 'returns "10:30 - 11:00 for "10:30"' do
      Time.new(2012, 11, 12, 10, 30).between_times.should eq('10:30 - 11:00')
    end

    it 'returns "10:00 - 10:30" for "10:00"' do
      Time.new(2012, 11, 12, 10, 00).between_times.should eq('10:00 - 10:30')
    end

  end
end