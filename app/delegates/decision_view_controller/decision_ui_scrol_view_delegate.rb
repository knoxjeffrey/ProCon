#############################
# UIScrollViewDelegate methods
# contains scrollViewDidScroll, and other methods, to keep track of dragging the scrollView
#############################

module DecisionUIScrollViewDelegate
  
  NavPullDown = Struct.new(:placeholder_cell, :pull_down_in_progress)
  
  NAVIGATION_CELL_ID = "navigation_cell"
  
  def pulldown
    @pulldown ||= NavPullDown.new(table_view_reference.dequeueReusableCellWithIdentifier(NAVIGATION_CELL_ID) , false)
  end
  
  def scrollViewDidScroll(scroll_view)
    # add the placeholder
    if pull_down_is_in_progress?(scroll_view) && scroll_view.contentOffset.y <= 0.0 
      create_placeholder(scroll_view.contentOffset.y)
      table_view_reference.insertSubview(pulldown.placeholder_cell, atIndex: 0) 
    end
  end
  
  def scrollViewDidEndDragging(scroll_view, willDecelerate: decelerate)
    # check whether the user pulled down far enough
    if pulldown.pull_down_in_progress && -scroll_view.contentOffset.y > table_view_reference.rowHeight
      self.performSelector("go_back", withObject: nil, afterDelay: 0.3)
    end
  end

  # remove placeholder when scroll view stops moving
  def scrollViewDidEndDecelerating(scroll_view)
    pulldown.placeholder_cell.removeFromSuperview
  end

  def create_placeholder(scroll_view_content_offset_y)
    # maintain the location of the placeholder
    pulldown.placeholder_cell.frame = CGRectMake(0, -table_view_reference.rowHeight,
        table_view_reference.frame.size.width, table_view_reference.rowHeight)

    pulldown.placeholder_cell.text = -scroll_view_content_offset_y > table_view_reference.rowHeight ?
        "Release to go back" : "Pull to go back"

    pulldown.placeholder_cell.alpha = [1.0, -scroll_view_content_offset_y / table_view_reference.rowHeight].min
    pulldown.placeholder_cell.backgroundColor = UIColor.blackColor
    pulldown.placeholder_cell.textColor = UIColor.whiteColor
    pulldown.placeholder_cell.textAlignment = NSTextAlignmentCenter
  end

  def pull_down_is_in_progress?(scroll_view)
    pulldown.pull_down_in_progress = scroll_view.contentOffset.y <= 0.0
  end
  
  def table_view_reference
    decision_table_view
  end
  
end