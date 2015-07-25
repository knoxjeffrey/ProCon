#############################
# Decision table view data source
#############################

module DecisionTableViewDataSource
  
  NAVIGATION_CELL_ID = "navigation_cell"
  
  def tableView(table_view, numberOfRowsInSection: section)
    0
  end

  def tableView(table_view, cellForRowAtIndexPath: indexPath)
    cell = table_view.dequeueReusableCellWithIdentifier(NAVIGATION_CELL_ID, forIndexPath: indexPath).tap do |cell|

      cell.selectionStyle = UITableViewCellSelectionStyleNone
      cell.table_view_cell_delegate = self
    end
  end
  
  def tableView(table_view, heightForRowAtIndexPath: indexPath)
    decision_table_view.rowHeight
  end
  
end