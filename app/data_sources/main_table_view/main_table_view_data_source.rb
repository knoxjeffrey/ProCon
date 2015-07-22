#############################
# Main table view data source
# contains numberOfSectionsInTableView, numberOfRowsInSection, cellForRowAtIndexPath
#############################

module MainTableViewDataSource
  
  TODO_CELL_ID = "cell"
  
  def tableView(table_view, numberOfRowsInSection: section)
    Decision.count
  end

  def tableView(table_view, cellForRowAtIndexPath: indexPath)
    cell = table_view.dequeueReusableCellWithIdentifier(TODO_CELL_ID, forIndexPath: indexPath).tap do |cell|
      decision = decisions_ordered.all[indexPath.row]
      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.textLabel.backgroundColor = UIColor.clearColor

      # allows custom_table_view_cell to pass message to this view controller
      # todo_item_deleted is called to delete a row
      cell.table_view_cell_delegate = self
      
      # pass the content of the cell to custom_table_view_cell
      cell.decision = decision
    end
  end

  #def tableView(tableView, didSelectRowAtIndexPath: indexPath)
  #  performSegueWithIdentifier(see_decision, sender: sender)
  #end
  
  def tableView(table_view, heightForRowAtIndexPath: indexPath)
    table_view.rowHeight
  end
  
  def decisions_ordered
    @decisions_ordered ||= Decision.sort_by(:created_at, order: :descending)
  end

  def handle_long_press(long_press)
    puts "long"
  end
  
end