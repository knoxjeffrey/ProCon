#############################
# UIScrollViewDelegate methods
# contains scrollViewDidScroll, and other methods, to keep track of dragging the scrollView
#############################

module UIScrollViewDelegate
  
  PullDown = Struct.new(:placeholder_cell, :pull_down_in_progress)
  
  TODO_CELL_ID = "cell"
  
  def pulldown
    @pulldown ||= PullDown.new(table_view_reference.dequeueReusableCellWithIdentifier(TODO_CELL_ID) , false)
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
      self.performSelector("new_decision_added", withObject: nil, afterDelay: 0.3)
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

    pulldown.placeholder_cell.render_text_field.text = -scroll_view_content_offset_y > table_view_reference.rowHeight ?
        "Release to add item" : "Pull to add item"

    pulldown.placeholder_cell.alpha = [1.0, -scroll_view_content_offset_y / table_view_reference.rowHeight].min
    pulldown.placeholder_cell.backgroundColor = UIColor.redColor
    pulldown.placeholder_cell.font = UIFont.fontWithName("HelveticaNeue", size: 16.0)
  end

  def pull_down_is_in_progress?(scroll_view)
    pulldown.pull_down_in_progress = scroll_view.contentOffset.y <= 0.0
  end
  
  def table_view_reference
    table_view
  end
  
end