class MainViewController < UIViewController
  
  extend IB
  include MainTableViewDataSource, MainTableViewDelegate, MainTableViewCellDelegate, UIScrollViewDelegate
  
  TODO_CELL_ID = "cell"

  outlet :table_view, UITableView
  
  def viewDidLoad
    super
    table_view.dataSource = self
    table_view.delegate = self
    # tells table_view to use CustomTableViewCell class when it needs a cell with reuse identifier TODO_CELL_ID
    table_view.registerClass(MainTableViewCell.self, forCellReuseIdentifier: TODO_CELL_ID)
    table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    table_view.backgroundColor = UIColor.blackColor
    table_view.rowHeight = 60.0
    # Very important. Without this the placeholder from UIScrollViewDelegate does not appear if the first action is a swipe to delete
    pulldown
  end
  
  #############################
  # add, delete, edit methods
  #############################

  def open_decision(decision)
    index = Decision.sort_by(:created_at, order: :descending).all.array.indexOfObject(decision)

    visible_cells = table_view.visibleCells

    visible_cells.each_with_index do |cell, cell_index|
      if cell_index == index
        animate_cell_slide_to_right(index, cell, cell_index)
      end
    end

    self.performSegueWithIdentifier("decision_segue", sender: decision)
  end

  def prepareForSegue(segue, sender: sender)
    if segue.identifier == "decision_segue"
      segue.destinationViewController.decision_object(sender)
      table_view.reloadData
    end
  end


  
  # delegate method for custom_table_view_cell
  def decision_deleted(decision) 
    index = Decision.sort_by(:created_at, order: :descending).all.array.indexOfObject(decision)
    
    visible_cells = table_view.visibleCells
    last_view = visible_cells[visible_cells.count - 1]
    start_animating = false
    
    decision.destroy
    cdq.save

    # slides the deleted cell to the left first and then shifts up the table
    # stock animation for deleteRowsAtIndexPaths merges the two animations and doesn't look as good    
    visible_cells.each_with_index do |cell, cell_index|
      if cell_index == index
        animate_cell_slide_to_left(index, cell, cell_index)
      elsif start_animating
        animate_table_slide_up(cell, cell_index, visible_cells)
      end
      
      start_animating = true if cell.decision == decision 
    end
    
    # although I use my own animation to handle the cell being deleted to the left I had to include this to 
    # properly manage deleting info from the table, including the cross view
    run_stock_animation(index, UITableViewRowAnimationLeft, "delete")
  end

  def animate_cell_slide_to_left(index, cell, cell_index)
    UIView.animateWithDuration(0.2, 
      delay: 0.0, 
      options: UIViewAnimationOptionCurveEaseOut,
      animations: proc { cell.frame = CGRectOffset(cell.frame, -cell.frame.size.width, 0) },
      completion: proc { |cell| break if cell_index == index }
    )
  end

  def animate_cell_slide_to_right(index, cell, cell_index)
    UIView.animateWithDuration(0.2, 
      delay: 0.0, 
      options: UIViewAnimationOptionCurveEaseOut,
      animations: proc { cell.frame = CGRectOffset(cell.frame, cell.frame.size.width, 0) },
      completion: proc { |cell| break if cell_index == index }
    )
  end

  def animate_table_slide_up(cell, cell_index, visible_cells)
    UIView.animateWithDuration(0.2, 
      delay: 0.2, 
      options: UIViewAnimationOptionCurveEaseIn,
      animations: proc { cell.frame = CGRectOffset(cell.frame, 0, -cell.frame.size.height) },
      completion: proc { |cell| table_view.reloadData if cell_index == visible_cells.count - 1 }
    )
  end

  def run_stock_animation(index, animation_type, insert_or_delete)
    table_view.beginUpdates
    indexPathForRow = NSIndexPath.indexPathForRow(index, inSection: 0)

    if insert_or_delete == "delete"
      table_view.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: animation_type)
    elsif insert_or_delete == "insert"
      table_view.insertRowsAtIndexPaths([indexPathForRow], withRowAnimation: animation_type)
    end

    table_view.endUpdates
  end
  
  def new_decision_added
    new_decision_to_make = Decision.create(title: "", created_at: Time.now, updated_at: Time.now)
    cdq.save

    run_stock_animation(0, UITableViewRowAnimationTop, "insert")
    
    # enter edit mode
    visible_cells = table_view.visibleCells
    visible_cells.each do |cell|
      if cell.decision == new_decision_to_make
        edit_cell = cell
        edit_cell.render_text_field.becomeFirstResponder # user can now type
        break
      end
    end
    
  end

   
end