#############################
# TableViewCellDelegate methods
# contains cellDidBeginEditing, cellDidEndEditing
#############################

module MainTableViewCellDelegate  
  
  StoredOffset = Struct.new(:offset_value, :counter, :scroll_position)

  def stored_offset
    @stored_offset ||= StoredOffset.new(CGPoint)
  end
=begin
  def cellDidBeginEditing(editing_cell)
    origin = editing_cell.frame.origin
    point = editing_cell.superview.convertPoint(origin, toView: table_view)
    puts point.y
    offset = table_view.contentOffset 
    stored_offset.offset_value = offset
    stored_offset.point = point

    #stored_offset.offset_value = offset 
    # Adjust the below value as you need
    offset.y > 0 ? offset.y = point.y : offset.y += point.y

    stored_offset.offset_value = point
    #puts stored_offset.offset_value.y
    table_view.setContentOffset(offset, animated: true)
  end


  def cellIsEditing(editing_cell) 
    
    offset = CGPointMake(0.0, 0.0)
    table_view.setContentOffset(offset, animated: false)
    frame = CGRectMake(0, 998.50, 1, 1)
    table_view.scrollRectToVisible(frame, animated: false)
    #table_view.setContentOffset(stored_offset.offset_value, animated: false)

    offset = table_view.contentOffset
    offset = CGPointMake(0.0, 0.0)
    table_view.setContentOffset(offset, animated: false)

    offset = stored_offset.offset_value
    table_view.setContentOffset(offset, animated: false)

    origin = editing_cell.frame.origin
    point = editing_cell.superview.convertPoint(origin, toView: table_view)
    offset = table_view.contentOffset  
    # Adjust the below value as you need
    offset.y > 0 ? offset.y = point.y : offset.y += point.y


    table_view.setContentOffset(stored_offset.offset_value, animated: false)

  end

  def cellDidEndEditing(editing_cell)

  end
=end

  # Using a transform below has the big advantage that it is easy to move a cell back to its original location: you simply “zero” the translation (i.e., apply the identity), instead of having to store the original frame for each and every cell that is moved

  # indicates that the edit process has begun for the given cell and animates the cell to scroll to the top of screen. Other cells are faded.
  def cellDidBeginEditing(editing_cell) 
    editing_offset = table_view.contentOffset.y - editing_cell.frame.origin.y

    stored_offset.offset_value = editing_offset
    stored_offset.counter = 0
    stored_offset.scroll_position = table_view.contentOffset.y

    visible_cells = table_view.visibleCells
  

    visible_cells.each do |cell|                                                                                                                 
      UIView.animateWithDuration(0.3,
        animations: proc {
          cell.transform = CGAffineTransformMakeTranslation(0, editing_offset)
          cell.alpha = 0.3 if cell != editing_cell
        }
      )
    end
    
    
  end

  def cellIsEditing(editing_cell) 
    stored_offset.counter += 1
    visible_cells = table_view.visibleCells
    
    visible_cells.each do |cell|
      cell.transform = CGAffineTransformIdentity
      #table_view.setContentOffset(CGPointMake(0, -table_view.contentInset.top), animated: false)
      #cell.alpha = 1.0 if cell != editing_cell
    end

    editing_offset = table_view.contentOffset.y - editing_cell.frame.origin.y
    visible_cells = table_view.visibleCells
    
    visible_cells.each do |cell|
      cell.transform = CGAffineTransformMakeTranslation(0, editing_offset)
      cell.alpha = 0.3 if cell != editing_cell
    end

    
  end
  
  # indicates that the edit process has committed for the given cell and cell moved back to its location
  def cellDidEndEditing(editing_cell)
    visible_cells = table_view.visibleCells
    visible_cells.each do |cell|
      UIView.animateWithDuration(0.2,
        animations: proc {
          cell.transform = CGAffineTransformMakeTranslation(0, stored_offset.offset_value * stored_offset.counter)
          #cell.transform = CGAffineTransformIdentity
          #reload_table_after_edit
          cell.alpha = 1.0 if cell != editing_cell
          
          #table_view.setContentOffset(CGPointMake(0, 0), animated: true)
          #reload_table_after_edit
          self.performSelector("reload_table_after_edit:", 
            withObject: cell, 
            afterDelay: 0.5)  
        }
      )
    end
    
    return table_view_cell_delegate.decision_deleted(editing_cell.decision) if editing_cell.decision.title == ""
  end

  def reload_table_after_edit(cell)
    UIView.animationsEnabled = false
    table_view_cell_delegate.table_view.beginUpdates
    cell.transform = CGAffineTransformIdentity
    table_view_cell_delegate.table_view.endUpdates
    UIView.animationsEnabled = true
    puts stored_offset.scroll_position
    #cell.transform = CGAffineTransformIdentity
    #table_view.setContentOffset(CGPointMake(0, -table_view.contentInset.top), animated: true)
    #table_view.reloadData
    puts table_view.contentOffset.y
    #table_view.contentOffset = CGPointZero

    #topPath = NSIndexPath.indexPathForRow(0, inSection: 0)
    #table_view.scrollToRowAtIndexPath(topPath,
    #             atScrollPosition: UITableViewScrollPositionTop,
    #                     animated: true)

    #table_view.setContentOffset(CGPointZero, animated: false)

    #table_view.setContentOffset(CGPointMake(0, 380))
    #table_view.setContentOffset(CGPointMake(0, stored_offset.scroll_position))
  end

  def table_view
    table_view_cell_delegate.table_view
  end
  
end