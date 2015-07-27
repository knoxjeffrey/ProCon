class DecisionViewController < UIViewController
  
  extend IB
  include NavigatorUIScrollViewDelegate, DecisionTableViewDataSource
  
  outlet :decision_title, UILabel
  outlet :decision_table_view, UITableView

  NAVIGATION_CELL_ID = "navigation_cell"

  attr_accessor :decision

  def viewDidLoad
    super
    decision_table_view.dataSource = self
    decision_table_view.delegate = self
    decision_title.text = decision.title
    
    decision_table_view.registerClass(UITableViewCell, forCellReuseIdentifier: NAVIGATION_CELL_ID)
    decision_table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    decision_table_view.backgroundColor = UIColor.clearColor
    decision_table_view.rowHeight = UIScreen.mainScreen.bounds.size.height / 10

    decision_table_view.addGestureRecognizer(long_press_gesture)
  end

  # table reference for the scroll view delegate
  def table_view_reference
    decision_table_view
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
      image_name = "thumbs_up"
    when 1
      image_name = "thumbs_down"
    end

    UIImage.imageNamed(image_name).CGImage
  end

 def did_select_item_at_index_with_point(selected_index, point)

    image_name = nil
    case selected_index
    when 0
      msg = "Pros Selected"
    when 1
      msg = "Cons Selected"
    else
      return
    end
    
    alert_view = UIAlertView.alloc.initWithTitle(nil, message: msg, delegate: nil, cancelButtonTitle: "OK", otherButtonTitles: nil)
    alert_view.show

  end

  def background_color_for_index(index)
    color = nil
    case index
    when 0
      color = UIColor.greenColor
    when 1
      color = UIColor.redColor
    else
      color = UIColor.blackColor
    end
    self.view.backgroundColor = color
  end


end