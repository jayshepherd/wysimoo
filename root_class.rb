class RootClass
  
  attr_accessor :name, :owner, :location, :contents, :programmer, :admin, :r, :w, :key, :aliases, :description

  def initialize
    self.name = ''
    self.owner = Nothing
    self.location = Nothing
    self.contents = []
    self.programmer = false
    self.admin = false
    self.r = true
    self.w = true
    self.description = ''
    self.key = Proc.new {}
  end

  def desc_msg
    if self.r
      self.description.empty? ? 'You see nothing special.' : self.description
    else
      raise E_PERM
    end
  end

  def description=(desc)
    if self.w
      self.description = desc.to_s
    else
      raise E_PERM
    end
  end

  def look_self
    if self.r
      @player.tell(self.description)
    else
      raise E_PERM
    end
  end

  def moveto(location)
    move(self, location)
  end

  def tell(*args)
    # This method is just here so that it can be called, but it does nothing.
    # If you want an object to do something, you can program the 'tell' method
    # directly onto the object.
  end

  def exam
    if self.r
      @player.tell_lines("#{self.name} (#{self.object_id}) is owned by #{self.owner == Nothing ? 'no one' : self.owner.name} (#{self.owner == Nothing ? 'Nothing' : self.owner.name})", "Aliases: #{StringUtils.english_list(self.aliases)}.", self.description.empty? ? '(No description set.)' : self.description)
    else
      raise E_PERM
    end
  end

  def title()
    if self.r
      self.name
    else
      raise E_PERM
    end
  end

  def eject(victim)
    move(victim, Nothing)
  end

end