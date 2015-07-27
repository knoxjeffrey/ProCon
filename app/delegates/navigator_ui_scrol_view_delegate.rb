#############################
# UIScrollViewDelegate methods

# table_view_reference delegate method needs to be included in controller for reference to the table view. Also register cell for reuse
#############################

module NavigatorUIScrollViewDelegate
  
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

    pulldown.placeholder_cell.addSubview(render_text_field)
    render_text_field.frame = CGRectMake((table_view_reference.frame.size.width/4), 0,
        (table_view_reference.frame.size.width/4) * 2, table_view_reference.rowHeight)

    new_cell_cue_image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 25, 25))
 
    if -scroll_view_content_offset_y > table_view_reference.rowHeight
      new_cell_cue_image.setImage(UIImage.imageNamed('drag'))
      render_text_field.text = "Release to go back"
    else
      new_cell_cue_image.setImage(UIImage.imageNamed('drag_down'))
      render_text_field.text = "Pull down to go back"
    end

    render_text_field.leftView = new_cell_cue_image
    render_text_field.leftViewMode = UITextFieldViewModeAlways
    render_text_field.addSubview(new_cell_cue_image)

    pulldown.placeholder_cell.alpha = [1.0, -scroll_view_content_offset_y / table_view_reference.rowHeight].min
    pulldown.placeholder_cell.backgroundColor = UIColor.clearColor
  end

  def render_text_field
    @render_text_field ||= UITextField.alloc.initWithFrame(CGRectNull).tap do |render_text_field|
      render_text_field.textColor = UIColor.whiteColor
      render_text_field.backgroundColor = UIColor.clearColor
      render_text_field.font = UIFont.fontWithName("HelveticaNeue", size: 14.0)
      render_text_field.textAlignment = NSTextAlignmentRight
    end
  end

  def pull_down_is_in_progress?(scroll_view)
    pulldown.pull_down_in_progress = scroll_view.contentOffset.y <= 0.0
  end
  
end