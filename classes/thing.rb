class Thing
  
  attr_accessor :otake_succeeded_msg, :otake_failed_msg, :take_succeeded_msg, :take_failed_msg, :odrop_succeeded_msg, :odrop_failed_msg, :drop_succeeded_msg, :drop_failed_msg

  def drop_failed_msg
    "You can't seem to drop #{self.name} here."
  end

  def drop_succeeded_msg
    "You drop #{self.name}."
  end

  def odrop_failed_msg
    ""
  end

  def odrop_succeeded_msg
    "#{@player.name} drops #{self.name}."
  end
  
  def take_failed_msg
    'You can\'t pick that up.'
  end
  
  def take_succeeded_msg
    "You take #{self.name}."
  end

  def otake_failed_msg
    ''
  end

  def otake_succeeded_msg
    "#{@player.name} picks up #{self.name}"
  end

  def get(obj)
    obj.moveto @player
    if obj.location == player
      
    else
      puts self.take_failed_msg
    end
  end

end