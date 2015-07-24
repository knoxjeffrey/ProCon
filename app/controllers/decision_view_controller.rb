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

    decision_table_view.addGestureRecognizer(long_press_gesture)
  end

  def long_press_gesture
    @long_press_gesture ||= UILongPressGestureRecognizer.alloc.initWithTarget(overlay, action: "handle_long_press:")
  end

  def overlay
  	@overlay ||= LongPressMenuView.alloc.initWithFrame(UIScreen.mainScreen.bounds).tap do |overlay|
      overlay.data_source = self
      overlay.delegate = self
    end
  end

  # method called by segue
  def decision_object(decision)
    @decision = decision
  end

  # activated by DecisionUIScrollViewDelegate on pull down
  def go_back
  	self.performSegueWithIdentifier("unwind_decision_segue", sender: self)
  end

  def number_of_menu_items
    2
  end

  def image_for_item_at_index(index)

    image_name = nil
    case index 
    when 0
      image_name = "facebook-white"
    when 1
      image_name = "twitter-white"
    when 2
      image_name = "google-plus-white"
    when 3
      image_name = "linkedin-white"
    when 4
      image_name = "pinterest-white"
    else
      image_name = "facebook-white"
    end

    UIImage.imageNamed(image_name).CGImage
  end

 def did_select_item_at_index_with_point(selected_index, point)

    image_name = nil
    case selected_index
    when 0
      msg = "Facebook Selected"
    when 1
      msg = "Twitter Selected"
    when 2
      msg = "Google Plus Selected"
    when 3
      msg = "Linkedin Selected"
    when 4
      msg = "Pinterest Selected"
    else
      return
    end
    
    alert_view = UIAlertView.alloc.initWithTitle(nil, message: msg, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil)
    alert_view.show

  end


end