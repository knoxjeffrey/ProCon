#############################
# Table view delegate methods
# contains willDisplayCell and helper method color_for_index
#############################

module MainTableViewDelegate
 
  def tableView(table_view, willDisplayCell: cell, forRowAtIndexPath: index_path)
    cell.backgroundColor = color_for_index(index_path.row)
  end

  def tableView(table_view, estimatedHeightForRowAtIndexPath: index_path)
  	UITableViewAutomaticDimension
  end
  
  # creates the color gradient from top to bottom cell
  def color_for_index(index_value)
    item_count = Decision.count
    index_value == 0 ? val = 0 : val = index_value.to_f / item_count.to_f * 0.7

    UIColor.colorWithRed(1.0, green: val, blue: 0.0, alpha: 1.0)
  end
  
end