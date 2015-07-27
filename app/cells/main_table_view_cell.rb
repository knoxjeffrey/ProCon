class MainTableViewCell < UITableViewCell
  
  Gesture = Struct.new(:original_center, :delete_on_drag_release, :open_on_drag_release)
  
  LABEL_LEFT_MARGIN = 10.0
  UI_CUES_MARGIN = 30.0
  UI_CUES_WIDTH = 50.0
  UI_CUES_WIDTH2 =  UIScreen.mainScreen.bounds.size.width/6
  
  attr_reader :decision
  attr_accessor :gesture, :table_view_cell_delegate
  
  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
    super
    render_text_field.delegate = self
    self.addSubview(delete_label)
    self.addSubview(open_label)
    self.addSubview(render_text_field)
    
    # remove the default blue highlight for selected cells
    self.selectionStyle = UITableViewCellSelectionStyleNone
    
    # make the Gesture instance variables available throughout this class to determine
    # the state of the gesture
    @gesture = Gesture.new(CGPoint, false, false)
    
    # new layer to create a color gradient for each cell. Light at top to dark at bottom
    self.layer.insertSublayer(gradient_layer, atIndex: 0)
    
    addGestureRecognizer(pan_gesture)
    
  end
  
  # position each subview
  def layoutSubviews
    super
    
    #ensure the gradient layers occupies the full bounds
    gradient_layer.frame = self.bounds
    
    render_text_field.frame = CGRectMake(LABEL_LEFT_MARGIN, 0,
                                    self.bounds.size.width - LABEL_LEFT_MARGIN,self.bounds.size.height)

    open_label.frame = CGRectMake(-self.bounds.size.width,
                                  0, self.bounds.size.width, self.bounds.size.height) 

    delete_label.frame = CGRectMake(self.bounds.size.width,
                                   0, self.bounds.size.width, self.bounds.size.height)
  end
  
  def decision=(decision)
    @decision = decision
    
    #we must update all the visual state associated with the model item
    render_text_field.text = decision.title
  end
  
  # create a text field that renders the decision title text
  def render_text_field
    @render_text_field ||= UITextView.alloc.initWithFrame(CGRectNull).tap do |render_text_field|
      render_text_field.textColor = UIColor.whiteColor
      render_text_field.backgroundColor = UIColor.clearColor
      render_text_field.font = UIFont.fontWithName("HelveticaNeue", size: 16.0)
      render_text_field.returnKeyType = UIReturnKeyDone
    end
  end

  def open_label
    @open_label ||= self.create_cue_label.tap do |open_label|
      edit_style = NSMutableParagraphStyle.new
      edit_style.tailIndent = -10
      text_attributes = { NSParagraphStyleAttributeName => edit_style 
      }
      open_label.attributedText = NSAttributedString.alloc.initWithString("Open", attributes: text_attributes)

      open_label.textAlignment = NSTextAlignmentRight
      open_label.font = UIFont.fontWithName("HelveticaNeue", size: 16.0)
      open_label.backgroundColor = UIColor.blueColor
    end
  end
  
  def delete_label
    @delete_label ||= self.create_cue_label.tap do |delete_label|
      edit_style = NSMutableParagraphStyle.new
      edit_style.firstLineHeadIndent = 10
      text_attributes = { NSParagraphStyleAttributeName => edit_style 
      }
      delete_label.attributedText = NSAttributedString.alloc.initWithString("Delete", attributes: text_attributes)

      delete_label.textAlignment = NSTextAlignmentLeft
      delete_label.font = UIFont.fontWithName("HelveticaNeue", size: 16.0)
      delete_label.backgroundColor = UIColor.redColor
    end
  end
  
  # utility method for creating the contextual cues for tick and cross
  def create_cue_label 
    @create_cue_label = UILabel.alloc.initWithFrame(CGRectNull).tap do |label|
      label.textColor = UIColor.whiteColor
      label.font = UIFont.boldSystemFontOfSize(32.0)
      label.backgroundColor = UIColor.clearColor
    end
  end
  
  # add a layer that overlays the cell adding a subtle gradient effect
  def gradient_layer  
    @gradient_layer ||= CAGradientLayer.layer.tap do |gradient_layer|
      gradient_layer.colors = colors
      gradient_layer.locations = [0.0, 0.01, 0.95, 1.0]
    end
  end
  
  # creates a 4 step gradient for gradient_layer 
  def colors
    color1 = UIColor.colorWithWhite(1.0, alpha: 0.2).CGColor
    color2 = UIColor.colorWithWhite(1.0, alpha: 0.1).CGColor
    color3 = UIColor.clearColor().CGColor
    color4 = UIColor.colorWithWhite(0.0, alpha: 0.1).CGColor
    
    [color1, color2, color3, color4]
  end
  
  # looks for dragging actions on screen and calls handle_pan
  def pan_gesture
    pan_gesture ||= UIPanGestureRecognizer.alloc.initWithTarget(self, action: "handle_pan:").tap do |pan_gesture|
      pan_gesture.delegate = self
    end
  end

  # handles the pan gesture during the begin, changed and ended states
  def handle_pan(pan_gesture)
    state_began(pan_gesture)
    state_changed(pan_gesture)
    state_ended(pan_gesture)
  end
  
  # if the gesture has just started, record the current centre location
  def state_began(pan_gesture)
    if pan_gesture.state == UIGestureRecognizerStateBegan
      gesture.original_center = self.center
    end
  end
  
  def state_changed(pan_gesture)
    if pan_gesture.state == UIGestureRecognizerStateChanged
      # translate the center
      translation = pan_gesture.translationInView(self)
      self.center = CGPointMake(gesture.original_center.x + translation.x, gesture.original_center.y)

      initial_swipe_cue(open_label)
      initial_swipe_cue(delete_label)

      final_swipe_cue(open_label)
      final_swipe_cue(delete_label)

      complete_right_swipe_cue(open_label)
      complete_left_swipe_cue(delete_label)

      #has the item has been dragged far enough to initiate a delete or complete?
      gesture.delete_on_drag_release = self.frame.origin.x < -self.frame.size.width / 2
      gesture.open_on_drag_release = self.frame.origin.x  > self.frame.size.width / 2
      
      # fade the contextual cues
      cue_alpha = ((self.frame.origin.x) / (self.frame.size.width / 3)).abs
      delete_label.alpha = cue_alpha
      open_label.alpha = cue_alpha
 
      # indicate when the decision titles have been pulled far enough to invoke the given action
      #open_label.backgroundColor = gesture.open_on_drag_release ? UIColor.greenColor : UIColor.blueColor
      #delete_label.backgroundColor = gesture.delete_on_drag_release ? UIColor.redColor : UIColor.whiteColor
    end
  end

  def initial_swipe_cue(label)
    # swiping right
    if self.frame.origin.x >= UI_CUES_WIDTH2 && self.frame.origin.x < UI_CUES_WIDTH2 * 2
      frameRect = label.frame
      frameRect.origin.x = -self.frame.origin.x - self.bounds.size.width + UI_CUES_WIDTH2
      label.frame = frameRect
    # swiping left
    elsif self.frame.origin.x <= -UI_CUES_WIDTH2 && self.frame.origin.x > -(UI_CUES_WIDTH2 * 2)
      frameRect = delete_label.frame
      frameRect.origin.x = -self.frame.origin.x + self.bounds.size.width - UI_CUES_WIDTH2
      delete_label.frame = frameRect
    end
  end

  def final_swipe_cue(label)
    # swiping right
    if self.frame.origin.x >= UI_CUES_WIDTH2 * 2 && self.frame.origin.x < UI_CUES_WIDTH2 * 3
      frameRect = label.frame
      frameRect.origin.x = self.frame.origin.x - self.bounds.size.width - (UI_CUES_WIDTH2*3)
      label.frame = frameRect
    # swiping left
    elsif self.frame.origin.x <= -UI_CUES_WIDTH2 * 2 && self.frame.origin.x > -(UI_CUES_WIDTH2 * 3)
      frameRect = delete_label.frame
      frameRect.origin.x = self.frame.origin.x + self.bounds.size.width + UI_CUES_WIDTH2*3
      delete_label.frame = frameRect
    end
  end

  def complete_right_swipe_cue(label)
    if self.frame.origin.x >= UI_CUES_WIDTH2 * 3
      frameRect = label.frame
      frameRect.origin.x = self.frame.origin.x - label.frame.size.width - self.frame.origin.x
      label.frame = frameRect
    end
  end

  def complete_left_swipe_cue(label)
    if self.frame.origin.x <= -UI_CUES_WIDTH2 * 3
      frameRect = label.frame
      frameRect.origin.x = self.frame.origin.x + label.frame.size.width - self.frame.origin.x
      label.frame = frameRect
    end
  end

  def state_ended(pan_gesture)
    if pan_gesture.state == UIGestureRecognizerStateEnded
      # the frame this cell would have had before being dragged
      original_frame = CGRectMake(0, self.frame.origin.y, self.bounds.size.width, self.bounds.size.height)
      
      # notify the delegate that this item should be deleted when true
      if gesture.delete_on_drag_release
        table_view_cell_delegate.decision_deleted(decision)
      # render the strikethrough and show completed layer. Snap the cell back to starting point with animation
      elsif gesture.open_on_drag_release
        table_view_cell_delegate.open_decision(decision)
      else 
        # if the item is not being deleted, snap back to the original location
        UIView.animateWithDuration(0.2, 
          delay: 0.0, 
          options: UIViewAnimationOptionCurveEaseOut,
          animations: proc { self.frame = original_frame },
          completion: proc { |view| table_view_cell_delegate.table_view.reloadData if self.frame = original_frame }
        )
      end
    end
  end
  
  # delgate method of a gesture recognizer - UIPanGestureRecognizer in this case
  # asks the delegate if a gesture recognizer should begin interpreting touches.
  def gestureRecognizerShouldBegin(gesture_recognizer)
    if gesture_recognizer.class == UIPanGestureRecognizer
      translation = gesture_recognizer.translationInView(self.superview)
      return true if translation.x.abs > translation.y.abs
      false
    end
  end
  
  #############################
  # UITextFieldDelegate methods
  #############################
 
  def textView(text_view, shouldChangeTextInRange: range, replacementText: text)
    if text.isEqualToString("\n")
        text_view.resignFirstResponder
        false
    else
        true
    end
  end
 
  def textViewShouldBeginEditing(text_field)
    true
  end
  
  def textViewDidBeginEditing(text_field) 
    table_view_cell_delegate.cellDidBeginEditing(self) if table_view_cell_delegate != nil
  end
  
  def textViewDidEndEditing(text_field)
    decision.title = text_field.text
    decision.created_at == nil ? decision.created_at = Time.now : decision.updated_at = Time.now
    cdq.save
    table_view_cell_delegate.cellDidEndEditing(self) if table_view_cell_delegate != nil
  end
  
end