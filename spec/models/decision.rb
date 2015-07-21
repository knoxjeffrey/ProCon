describe 'Decision' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Decision entity' do
    Decision.entity_description.name.should == 'Decision'
  end
end
