require 'rspec'
require_relative '../../classes/lib/array'

describe Array do
  describe '#not_empty' do
    it 'should return true for an Array with more than zero elements' do
      [1,2].not_empty?.should be_true
    end

    it 'should return false for an Array with zero elements' do
      [].not_empty?.should be_false
    end
  end

  describe '#average' do
    it 'should return 5 for [1..9]' do
      (1..9).to_a.average.should eq(5)
    end

    it 'should return 5.5 for [1..10]' do
      (1..10).to_a.average.should eq(5.5)
    end

    it 'should return 0.0 for [nil]' do
      [nil].average.should eq(0.0)
    end

    it 'should return 0.0 for []' do
      [].average.should eq(0.0)
    end

    it 'should not alter original Array' do
      a = [1, 2, 3, nil, 5, nil]
      original_length = a.length
      a.average
      a.length.should eq(original_length)
    end

    it 'should return nil for [String, String, String]' do
      %W(Nothing but Strings).average.should be_nil
    end

    it 'should return 5 for [1..9, String, String]' do
      a = (1..9).to_a
      a += %W(Some added strings)
      a.average.should eq(5)
    end

    it 'should return 5 for ["1".."9"]' do
      ('1'..'9').to_a.average.should eq(5)
    end

    it 'should return 5 for ["1".."9", String, String]' do
      a = ('1'..'9').to_a
      a += %W(Some added strings)
      a.average.should eq(5)
    end
  end
end