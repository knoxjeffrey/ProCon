describe 'Con' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Con entity' do
    Con.entity_description.name.should == 'Con'
  end
end
