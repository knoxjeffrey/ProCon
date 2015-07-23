class DecisionViewController < UIViewController
  
  extend IB
  include DecisionUIScrollViewDelegate, DecisionTableViewDataSource
  
  outlet :decision_title, UILabel
  outlet :decision_table_view, UITableView

  NAVIGATION_CELL_ID = "navigation_cell"

  attr_accessor :decision

  def viewDidLoad
    super
    decision_table_view.dataSource = self
    decision_table_view.delegate = self
    decision_title.text = decision.title
    # tells table_view to use CustomTableViewCell class when it needs a cell with reuse identifier NAVIGATION_CELL_ID
    decision_table_view.registerClass(UITableViewCell, forCellReuseIdentifier: NAVIGATION_CELL_ID)
    decision_table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    decision_table_view.backgroundColor = UIColor.clearColor
    decision_table_view.rowHeight = 70.0

    #overlay = LongPressMenuView.alloc.init
    #overlay.dataSource = self
    #overlay.delegate = self
    # looks for long press action on screen and calls handle_long_press
    
    decision_table_view.addGestureRecognizer(long_press_gesture)
  end

  def long_press_gesture
    @long_press_gesture = UILongPressGestureRecognizer.alloc.initWithTarget(overlay, action: "handle_long_press:").tap do |long_press_gesture|
      long_press_gesture.delegate = self
    end
  end

  def overlay
  	@overlay ||= LongPressMenuView.alloc.initWithFrame(UIScreen.mainScreen.bounds)
  end

  # method called by segue
  def decision_object(decision)
    @decision = decision
  end

  # activated by DecisionUIScrollViewDelegate on pull down
  def go_back
  	self.performSegueWithIdentifier("unwind_decision_segue", sender: self)
  end

end