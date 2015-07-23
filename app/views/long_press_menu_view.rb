class LongPressMenuView < UIView

	MenuAttributes = Struct.new(:item_bg_color, :item_bg_highlighted_color, :prev_index, :long_press_location, :is_showing, :is_paning, :current_location)

	attr_accessor :handle_long_press, :menu_attributes

	def initWithFrame(frame)
		super.tap do
	  	# Initialization code
	    self.userInteractionEnabled = true
	    self.backgroundColor = UIColor.clearColor

	    display_link = CADisplayLink.displayLinkWithTarget(self, selector: "highlight_menu_item_for_point")
	    display_link.addToRunLoop(NSRunLoop.mainRunLoop, forMode: NSDefaultRunLoopMode)
	    
	    menu_items = []
	    item_locations = []
	    arc_angle = Math::PI / 2
	    radius = 90

	    @menu_attributes = MenuAttributes.new(UIColor.grayColor.CGColor, UIColor.redColor.CGColor, -1, CGPoint, false, false, CGPoint)
	  end
	end

	def highlight_menu_item_for_point

	end

	def animate_menu

	end

	

	def handle_long_press(gesture_recognizer)
		if gesture_recognizer.state == UIGestureRecognizerStateBegan
      
      point_in_View = gesture_recognizer.locationInView(gesture_recognizer.view)
      #if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(shouldShowMenuAtPoint:)] && ![self.dataSource shouldShowMenuAtPoint:pointInView]){
      #    return;
      #}
      
      UIApplication.sharedApplication.keyWindow.addSubview(self)
      menu_attributes.long_press_location = gesture_recognizer.locationInView(self)
      
      self.layer.backgroundColor = UIColor.colorWithWhite(0.1, alpha: 0.8).CGColor
      menu_attributes.is_showing = true
      #self.animate_menu = true
      self.setNeedsDisplay
    end

    if gesture_recognizer.state == UIGestureRecognizerStateChanged
	    if menu_attributes.is_showing 
	     	menu_attributes.is_paning = true
	      menu_attributes.current_location = gesture_recognizer.locationInView(self)
	    end
    end
    
    # Only trigger if we're using the GHContextMenuActionTypePan (default)
    if gesture_recognizer.state == UIGestureRecognizerStateEnded
    	menu_at_point = self.convertPoint(menu_attributes.long_press_location, toView: gesture_recognizer.view)
    	self.dismiss_with_selected_index_for_menu_at_point(menu_at_point)
    end

	end

	def dismiss_with_selected_index_for_menu_at_point(point)
		#if self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex: forMenuAtPoint:)] && self.prevIndex >= 0){
     #   [self.delegate didSelectItemAtIndex:self.prevIndex forMenuAtPoint:point];
     #   self.prevIndex = -1;
   # }

    self.hide_menu
	end

	def hide_menu
		if menu_attributes.is_showing
	    self.layer.backgroundColor = UIColor.clearColor.CGColor
	    menu_attributes.is_showing = false
	    menu_attributes.is_paning = false
	    #menu_at_point.animateMenu = false
	    self.setNeedsDisplay
	    self.removeFromSuperview
	  end
	end

end