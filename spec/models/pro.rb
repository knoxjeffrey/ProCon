describe 'Pro' do

  before do
    class << self
      include CDQ
    end
    cdq.setup
  end

  after do
    cdq.reset!
  end

  it 'should be a Pro entity' do
    Pro.entity_description.name.should == 'Pro'
  end
end
