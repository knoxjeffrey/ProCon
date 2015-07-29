#############################
# UIScrollViewDelegate methods

# table_view_reference delegate method needs to be included in controller for reference to the table view. Also register cell for reuse
#############################

module NewCellScrollViewDelegate
  
  PullDown = Struct.new(:placeholder_cell, :pull_down_in_progress)
  
  NEW_CELL_PLACEHOLDER_ID = "new_cell_placeholder"
  
  def pulldown
    @pulldown ||= PullDown.new(table_view_reference.dequeueReusableCellWithIdentifier(NEW_CELL_PLACEHOLDER_ID) , false)
  end

  def placeholder_height
    UIScreen.mainScreen.bounds.size.height / 10
  end

  def placeholder_width
    UIScreen.mainScreen.bounds.size.width
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
    if pulldown.pull_down_in_progress && -scroll_view.contentOffset.y > placeholder_height
      self.performSelector("new_decision_added", withObject: nil, afterDelay: 0.3)
    end
  end

  # remove placeholder when scroll view stops moving
  def scrollViewDidEndDecelerating(scroll_view)
    pulldown.placeholder_cell.removeFromSuperview
  end

  def create_placeholder(scroll_view_content_offset_y)
    # maintain the location of the placeholder
    pulldown.placeholder_cell.frame = CGRectMake(0, -placeholder_height,
        placeholder_width, placeholder_height)

    pulldown.placeholder_cell.addSubview(render_text_field)
    render_text_field.frame = CGRectMake(10, 0,
        placeholder_width, placeholder_height)

    new_cell_cue_image = UIImageView.alloc.initWithFrame(CGRectMake(0, 0, 25, 25))
 
    if -scroll_view_content_offset_y > placeholder_height
      new_cell_cue_image.setImage(UIImage.imageNamed('drag'))
      render_text_field.text = "  Release to add item"
    else
      new_cell_cue_image.setImage(UIImage.imageNamed('drag_down'))
      render_text_field.text = "  Pull down to add item"
    end

    render_text_field.leftView = new_cell_cue_image
    render_text_field.leftViewMode = UITextFieldViewModeAlways
    render_text_field.addSubview(new_cell_cue_image)

    pulldown.placeholder_cell.alpha = [1.0, -scroll_view_content_offset_y / placeholder_height].min
    pulldown.placeholder_cell.backgroundColor = UIColor.redColor
  end

  def render_text_field
    @render_text_field ||= UITextField.alloc.initWithFrame(CGRectNull).tap do |render_text_field|
      render_text_field.textColor = UIColor.whiteColor
      render_text_field.backgroundColor = UIColor.clearColor
      render_text_field.font = UIFont.fontWithName("HelveticaNeue", size: 16.0)
      render_text_field.textAlignment = NSTextAlignmentLeft
    end
  end

  def pull_down_is_in_progress?(scroll_view)
    pulldown.pull_down_in_progress = scroll_view.contentOffset.y <= 0.0
  end
  
end