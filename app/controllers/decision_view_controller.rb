class DecisionViewController < UIViewController
  
  extend IB
  include DecisionUIScrollViewDelegate
  
  outlet :decision_title, UILabel
  outlet :decision_table_view, UITableView

  NAVIGATION_CELL_ID = "navigation_cell"

  def viewDidLoad
    super
    decision_table_view.dataSource = self
    decision_table_view.delegate = self
    decision_title.text = @decision.title
    # tells table_view to use CustomTableViewCell class when it needs a cell with reuse identifier TODO_CELL_ID
    decision_table_view.registerClass(UITableViewCell, forCellReuseIdentifier: NAVIGATION_CELL_ID)
    decision_table_view.separatorStyle = UITableViewCellSeparatorStyleNone
    decision_table_view.backgroundColor = UIColor.clearColor
    decision_table_view.rowHeight = 70.0
  end

  def decision_object(decision)
    @decision = decision
  end

  def tableView(table_view, numberOfRowsInSection: section)
    0
  end

  def tableView(table_view, cellForRowAtIndexPath: indexPath)
    cell = table_view.dequeueReusableCellWithIdentifier(NAVIGATION_CELL_ID, forIndexPath: indexPath).tap do |cell|

      cell.selectionStyle = UITableViewCellSelectionStyleNone
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

  def go_back
  	self.performSegueWithIdentifier("unwind_decision_segue", sender: self)
  end

end