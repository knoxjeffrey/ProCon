class LongPressMenuView < UIView

	MenuAttributes = Struct.new(:menu_items, :item_locations, :item_bg_color, :item_bg_highlighted_color, :prev_index, :long_press_location, :is_showing, :is_paning, :current_location, :arc_angle, :radius, :angle_between_items)

	#LocationInfo = Struct.new(:position, :angle)
	LocationInfo = Struct.new(:position)

	MAIN_ITEM_SIZE = 44
	MENU_ITEM_SIZE = 40
	BORDER_WIDTH  = 5

	ANIMATION_DURATION = 0.2
	ANIMATION_DELAY = ANIMATION_DURATION / 5


	attr_accessor :handle_long_press, :menu_attributes, :delegate, :location_info
	attr_reader :data_source

	def initWithFrame(frame)
		super.tap do
	  	# Initialization code
	    self.userInteractionEnabled = true
	    self.backgroundColor = UIColor.clearColor

	    display_link = CADisplayLink.displayLinkWithTarget(self, selector: "highlight_menu_item_for_point")
	    display_link.addToRunLoop(NSRunLoop.mainRunLoop, forMode: NSDefaultRunLoopMode)

	    @menu_attributes = MenuAttributes.new([], [], UIColor.grayColor.CGColor, UIColor.redColor.CGColor, -1, CGPoint, false, false, CGPoint, Math::PI / 2, 90, 0)
	  end
	end

	def touchesBegan(touches, withEvent: event)
    menu_at_point = CGPointZero

    if touches.count == 1

    	touch = touches.anyObject
      touch_point = touch.locationInView(self)

      menu_item_index = self.index_of_closest_match_at_point(touch_point)

      if menu_attributes.prev_index > -1
      	menu_at_point = menu_attributes.menu_items[menu_item_index].position
      end

      if menu_attributes.prev_index >= 0 && menu_attributes.prev_index != menu_attributes.prev_index
      	self.reset_previous_selection
      end

      menu_attributes.prev_index = menu_item_index
    end

    self.dismissWithSelectedIndexForMenuAtPoint(menu_at_point)
  end

	def index_of_closest_match_at_point(point)
		menu_attributes.menu_items.each_with_index do |menu_item, index|
			if CGRectContainsPoint(menu_item.frame, point)
      	puts "Touched Layer at index: #{index}"
      	return index
      end
		end

		return -1
	end
	
	def reset_previous_selection
	  if menu_attributes.prev_index >= 0
	    layer = menu_attributes.menu_items[menu_attributes.prev_index]
	    item_location = menu_attributes.item_locations[menu_attributes.prev_index]
	    layer.position = item_location.position
	    layer.backgroundColor = menu_attributes.item_bg_color
	    layer.transform = CATransform3DIdentity
	    menu_attributes.prev_index = -1
	  end
	end

	def highlight_menu_item_for_point
		if menu_attributes.is_showing && menu_attributes.is_paning
        
      close_to_index = -1

      menu_attributes.menu_items.each_with_index do |menu_item, index|
        item_location = menu_attributes.item_locations[index]

        if menu_attributes.current_location.x >= item_location.position.x - MAIN_ITEM_SIZE / 2 && 
        	menu_attributes.current_location.x <= item_location.position.x + MAIN_ITEM_SIZE / 2
	          close_to_index = index
	          break
        end
      end

      if close_to_index >= 0 && close_to_index < menu_attributes.menu_items.count
      	item_location = menu_attributes.item_locations[close_to_index]

      	layer = menu_attributes.menu_items[close_to_index]
        layer.backgroundColor = menu_attributes.item_bg_highlighted_color

        scale_factor = 1.3
        scale_transform =  CATransform3DScale(CATransform3DIdentity, scale_factor, scale_factor, 1.0)

        y_trans = Math.sin(item_location.position.y)
                
	      translate = CATransform3DTranslate(scale_transform, 0, 10 * scale_factor * y_trans, 0)
	      layer.transform = translate
	      
	      if menu_attributes.prev_index >= 0 && menu_attributes.prev_index != close_to_index
	      	self.reset_previous_selection
	      end
	      
	      menu_attributes.prev_index = close_to_index

	    else
      	self.reset_previous_selection
      end

    end

	end

	def data_source=(data_source)
		@data_source = data_source
		self.reload_data
	end

	def reload_data
    menu_attributes.menu_items.clear
    menu_attributes.item_locations.clear
    
    if self.data_source != nil
    	count = self.data_source.number_of_menu_items
    	i = 0

    	while i < count
    		image = self.data_source.image_for_item_at_index(i)
        layer = self.layer_with_image(image)
        self.layer.addSublayer(layer)
        menu_attributes.menu_items.push(layer)
        i += 1
    	end

    end
	end

	def layer_with_image(image)
		layer = CALayer.layer
    layer.bounds = CGRectMake(0, 0, MENU_ITEM_SIZE, MENU_ITEM_SIZE)
    layer.cornerRadius = MENU_ITEM_SIZE / 2
    layer.borderColor = UIColor.whiteColor.CGColor
    layer.borderWidth = BORDER_WIDTH
    layer.shadowColor = UIColor.blackColor.CGColor
    layer.shadowOffset = CGSizeMake(0, -1)
    layer.backgroundColor = menu_attributes.item_bg_color
    
    image_layer = CALayer.layer
    image_layer.contents = image
    image_layer.bounds = CGRectMake(0, 0, MENU_ITEM_SIZE * 2 / 3, MENU_ITEM_SIZE * 2 / 3)
    image_layer.position = CGPointMake(MENU_ITEM_SIZE / 2, MENU_ITEM_SIZE / 2)
    layer.addSublayer(image_layer)
    
    return layer
	end

	def handle_long_press(gesture_recognizer)
		if gesture_recognizer.state == UIGestureRecognizerStateBegan
      
      UIApplication.sharedApplication.keyWindow.addSubview(self)
      menu_attributes.long_press_location = gesture_recognizer.locationInView(self)
      
      self.layer.backgroundColor = UIColor.colorWithWhite(0.1, alpha: 0.8).CGColor
      menu_attributes.is_showing = true
      self.animate_menu
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

	def animate_menu
		self.layout_menu_items if menu_attributes.is_showing

		index = 0
		while index < menu_attributes.menu_items.count
      layer = menu_attributes.menu_items[index]
      layer.opacity = 0
      from_position = menu_attributes.long_press_location
      
      location = menu_attributes.item_locations[index]
      to_position = location.position

      delay_in_seconds = index * ANIMATION_DELAY
      
      position_animation = CABasicAnimation.animationWithKeyPath("location_info.position")

      position_animation.fromValue = NSValue.valueWithCGPoint(menu_attributes.is_showing ? from_position : to_position)
      position_animation.toValue = NSValue.valueWithCGPoint(menu_attributes.is_showing ? to_position : from_position)
      position_animation.timingFunction = CAMediaTimingFunction.objc_send('functionWithControlPoints::::', '@@:ffff', 0.45, 1.2, 0.75, 1.0)
      position_animation.duration = ANIMATION_DURATION
      position_animation.beginTime = layer.convertTime(CACurrentMediaTime(), fromLayer: nil) + delay_in_seconds
      position_animation.setValue(NSNumber.numberWithUnsignedInteger(index), forKey: menu_attributes.is_showing ? "show" : "dismiss")
      position_animation.delegate = self
      
      layer.addAnimation(position_animation, forKey: "rise_animation")

      index += 1
    end
	end

	def animationDidStart(anim)
    if anim.valueForKey("show")
    	index = anim.valueForKey("show").unsignedIntegerValue
      layer = menu_attributes.menu_items[index]
        
      location = menu_attributes.item_locations[index]
      to_alpha = 1.0
        
      layer.position = location.position
      layer.opacity = to_alpha
    end
  end


	def layout_menu_items
		menu_attributes.item_locations.clear
=begin    
    item_size = CGSizeMake(MENU_ITEM_SIZE, MENU_ITEM_SIZE)
    item_radius = Math.sqrt((item_size.width ** 2) + (item_size.height ** 2)) / 2
    menu_attributes.arc_angle = ((item_radius * menu_attributes.menu_items.count) / menu_attributes.radius) * 1.5
    
    count = menu_attributes.menu_items.count
		is_full_circle = menu_attributes.arc_angle == Math::PI * 2
		divisor = is_full_circle ? count : count - 1

    menu_attributes.angle_between_items = menu_attributes.arc_angle / divisor
    
    i = 0
    while i < menu_attributes.menu_items.count
    	location = self.location_for_item_at_index(i)
      menu_attributes.item_locations.push(location)
        
      layer = menu_attributes.menu_items[i]
      layer.transform = CATransform3DIdentity
     
      # Rotate menu items based on orientation
      if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice.orientation))
          angle = UIDevice.currentDevice.orientation == UIDeviceOrientationLandscapeLeft ? Math::PI / 2 : -Math::PI / 2
          layer.transform = CATransform3DRotate(CATransform3DIdentity, angle, 0, 0, 1)
      end

      i += 1
    end
=end
		
		i = 0
    while i < menu_attributes.menu_items.count
	    used_screen_width = CGRectGetWidth(self.window.screen.bounds)
	    menu_spacing = (used_screen_width / 4) * (i + (i + 1))
	    item_center = CGPointMake(menu_spacing, 75)
	    
	    location_info = LocationInfo.new(item_center)
	    
	    menu_attributes.item_locations.addObject(location_info)
	    
	    layer = menu_attributes.menu_items[i]
	    layer.transform = CATransform3DIdentity

	    i += 1
    end
	end

=begin
	def location_for_item_at_index(index)
		item_angle = self.item_angle_at_index(index)
	
		item_center = CGPointMake(menu_attributes.long_press_location.x + Math.cos(item_angle) * menu_attributes.radius,
									 menu_attributes.long_press_location.y + Math.sin(item_angle) * menu_attributes.radius)
		
		@location_info = LocationInfo.new(item_center, item_angle)
	end


	def item_angle_at_index(index)
		bearing_radians = angle_between_starting_and_ending_point(menu_attributes.long_press_location, self.center) 
    
    angle =  bearing_radians - menu_attributes.arc_angle / 2
    
		item_angle = angle + (index * menu_attributes.angle_between_items)
    
    if item_angle > 2 * Math::PI
    	item_angle -= 2 * Math::PI
    elsif item_angle < 0
        item_angle += 2 * Math::PI
    end

    item_angle
	end


	def angle_between_starting_and_ending_point(starting_point, ending_point)
		origin_point = CGPointMake(ending_point.x - starting_point.x, ending_point.y - starting_point.y)
    bearing_radians = Math.atan2(origin_point.y, origin_point.x)
    
    bearing_radians = (bearing_radians > 0.0 ? bearing_radians : (Math::PI / 2 + bearing_radians))

    bearing_radians
	end
=end

	def dismiss_with_selected_index_for_menu_at_point(point)
		puts self.delegate
		puts self.delegate.respondsToSelector("did_select_item_at_index_with_point::") 
		puts menu_attributes.prev_index >= 0

		#if self.delegate && self.delegate.respondsToSelector("did_select_item_at_index_with_point") && menu_attributes.prev_index >= 0
			puts "i'm in"
			self.delegate.did_select_item_at_index_with_point(menu_attributes.prev_index, point)
			menu_attributes.prev_index = -1
   	#end

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

class NSObject
  def objc_send(selector, ctypes, *args)
    invocation = NSInvocation.invocationWithMethodSignature(NSMethodSignature.signatureWithObjCTypes(ctypes))
    invocation.target = self
    invocation.selector = selector
    ctypes.split(':').last.split(//).each_with_index do |type, index|
      arg = args[index]
      pointer = Pointer.new(type)
      pointer[0] = arg
      invocation.setArgument(pointer, atIndex:index+2)
    end

    invocation.invoke
    pointer = Pointer.new(ctypes[0,1])
    invocation.getReturnValue(pointer)
    pointer[0]
  end
end