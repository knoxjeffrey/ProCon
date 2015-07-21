schema "0001 initial" do

  entity "Decision" do
    string :title

    has_many :pros
    has_many :cons
  end
  
  entity "Pro" do
    string :detail
    integer32 :score
    
    belongs_to :decision
  end
  
  entity "Con" do
    string :detail
    integer32 :score
    
    belongs_to :decision
  end
  
end
