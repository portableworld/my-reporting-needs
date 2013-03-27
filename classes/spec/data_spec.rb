require 'rspec'
require_relative '../data'
require 'win32ole'

describe QueryData do
  let(:qdata) {QueryData.new}

  before(:all) do
    qdata.data = [1,2,3,4,5,6].zip(%W(a b c d e f g h i))
    qdata.fields = [:numbers, :letters]
  end

  describe '#new' do
    it 'should have two attributes of Array type' do
      qdata.data.should be_an_instance_of Array
      qdata.fields.should be_an_instance_of Array
    end
  end

  describe '#[]' do
    it 'should return data when passed a symbol' do
      qdata[:numbers].should eq([1,2,3,4,5,6])
    end

    it 'should return data when passed a numeric index' do
      qdata[0].should eq([1, 'a'])
    end
  end

  describe '#at(index)' do
    it 'should return data when passed a numeric index' do
      qdata.at(0).should eq([1, 'a'])
    end
  end

  describe '#count' do
    it 'should return length of @data' do
      qdata.count.should eq(6)
    end
  end

  describe '#size' do
    it 'should return length of @data' do
      qdata.size.should eq(6)
    end
  end

  describe '#length' do
    it 'should return length of @data' do
      qdata.length.should eq(6)
    end
  end

  describe '#clear' do
    it 'should clear out both attributes' do
      d = QueryData.new
      d.data = [1,2,3,4,5,6]
      d.fields = [:one, :two, :three]
      d.clear
      d.fields.empty?.should be_true
      d.data.empty?.should be_true
    end
  end

  describe '#set_data' do
    context 'when recordset is a WIN32OLE object' do
      context 'when WIN32OLE object contains data' do
        it 'should contain the data passed in' do
          # TODO - Write test
        end
      end
      context 'when WIN32OLE object is empty' do
        it 'should contain empty Array for @data' do
          # TODO - Write test
        end
      end
    end
    context 'when recordset is an Array of Arrays' do
      context 'when Array of Arrays contain data' do
        it 'should contain the data passed in' do
          nums = [1,2,3,4,5,6]
          d = QueryData.new
          lambda {d.set_data([1,2,3,4,5,6].zip(%W(a b c d e f g h i)))}.should_not raise_exception
          d.fields = [:numbers, :letters]
          d[0].should eq([1, 'a'])
          d[:numbers].should eq(nums)
        end
      end
      context 'when Array of Arrays is empty' do
        it 'should contain empty Array for @data' do
          # TODO - Write test
        end
      end
    end
  end

  describe '#field_name' do
    context 'when #numbers is called' do
      it 'should return all numbers' do
        qdata.numbers.should eq([1,2,3,4,5,6])
      end
    end 
    context 'when #does_not_exist is called' do
      it 'should return an error' do
        lambda {qdata.does_not_exist}.should raise_exception
      end
    end
  end

  describe '#set_fields' do
    context 'with WIN32OLE RecordSet' do
      # TODO - Write test
    end
  end
end