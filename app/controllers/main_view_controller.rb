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
    table_view.rowHeight = 50.0
  end
  
  #############################
  # add, delete, edit methods
  #############################
  
  # delegate method for custom_table_view_cell
  def decision_deleted(decision) 
    index = Decision.sort_by(:created_at, order: :descending).all.array.indexOfObject(decision)
    #index = Decision.all.array.indexOfObject(decision)
    
    visible_cells = table_view.visibleCells
    #cell_being_deleted = visible_cells[index]
    last_view = visible_cells[visible_cells.count - 1]
    start_animating = false
    
    decision.destroy
    cdq.save

    # slides the deleted cell to the left first and then shifts up the table
    # stock animation for deleteRowsAtIndexPaths merges the two animations and doesn't look as good
    visible_cells.each_with_index do |cell, cell_index|
      if cell_index == index
        #toggle_cross_symobol_cell(cell_being_deleted)

        UIView.animateWithDuration(0.2, 
                delay: 0.0, 
                options: UIViewAnimationOptionCurveEaseOut,
                animations: proc { cell.frame = CGRectOffset(cell.frame, -cell.frame.size.width, 0) },
                completion: proc { |cell| break if cell_index == index }
        )
      elsif start_animating
        UIView.animateWithDuration(0.2, 
                delay: 0.2, 
                options: UIViewAnimationOptionCurveEaseIn,
                animations: proc { cell.frame = CGRectOffset(cell.frame, 0, -cell.frame.size.height) },
                completion: proc { |cell| table_view.reloadData if cell_index == visible_cells.count - 1 }
        )
      end
      
      start_animating = true if cell.decision == decision 
      table_view.reloadData if Decision.count == 1
    end
    
    # although I use my own animation to handle the cell being deleted to the left I had to include this to properly manage deleting info from the table, including the cross view
    table_view.beginUpdates
    indexPathForRow = NSIndexPath.indexPathForRow(index, inSection: 0)
    table_view.deleteRowsAtIndexPaths([indexPathForRow], withRowAnimation: UITableViewRowAnimationLeft)
    table_view.endUpdates
  end
  
  def new_decision_added
    new_decision_to_make = Decision.create(title: "", created_at: Time.now, updated_at: Time.now)
    cdq.save
    
    table_view.beginUpdates
    indexPathForRow = NSIndexPath.indexPathForRow(0, inSection: 0)
    table_view.insertRowsAtIndexPaths([indexPathForRow], withRowAnimation: UITableViewRowAnimationTop)
    table_view.endUpdates
    
    # enter edit mode
    visible_cells = table_view.visibleCells
    visible_cells.each do |cell|
      if cell.decision == new_decision_to_make
        edit_cell = cell
        edit_cell.render_label.becomeFirstResponder # user can now type
        break
      end
    end
    
  end

   
end