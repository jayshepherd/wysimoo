class Player < RootClass

  attr_accessor :current_message, :messages, :last_connect_time,  :gender, :ps, :po, :pp, :pr, :pq, :psc, :poc, :ppc, :prc, :pqc, :home, :password, :paranoid, :responsible, :lines, :object_gaglist, :mail_notify, :mail_options, :mail_forward, :edit_options
  attr_reader :connected_seconds, :idle_seconds

  def initialize
    Players << self
    super()
    @connected_seconds = 0
    @idle_seconds = 0
    self.current_message = 0
    self.messages = []
    self.last_connect_time = nil
    self.gender = 'either'
    self.ps = 'he/she'
    self.po = 'him/her'
    self.pp = 'his/her'
    self.pr = 'himself/herself'
    self.pq = 'his/hers'
    self.psc = 'He/She'
    self.poc = 'Him/Her'
    self.ppc = 'His/Her'
    self.prc = 'Himself/Herself'
    self.pqc = 'His/Hers'
    self.home = PlayerStart
    self.password = ''
    self.paranoid = 0
    self.responsible = []
    self.lines = HighInt
    self.object_gaglist = []
    self.mail_notify = ''
    self.mail_options = []
    self.mail_forward = ''
  end
  
  def page_absent_msg(player)
    "#{player.name} is not currently logged in."
  end

  def page_origin_msg(player)
    "You sense that #{player.name} is looking for you in #{player.location.title}."
  end
  
  def page_echo_msg
    "Your message has been sent."
  end
  
  def whereis_location_msg
    "#{self.name} is in #{self.location.title}"
  end
  
  def who_location_msg
    "#{self.location}"
  end
  
  def get
    @player.tell('You can\'t do that.')
  end
  
  def take
    get
  end
  
  def inventory
    if self.contents.empty?
      self.tell('You are empty-handed.')
    else
      self.tell('Carrying:')
      self.contents.each do |object|
        self.tell('  ', object.title)
      end
    end
  end
  
  def i
    inventory
  end
  
  def whisper(*args)
    args[2].tell(self.name, ' whispers "', args[0], '" to you.')
  end

  def wh(*args)
    whisper(*args)
  end

  def look_self()
    @player.tell(self.name)
    @player.tell(self.description, "\n\n")
    if self.in(conncted_players)
      if self.idle_seconds < 30
        @player.tell("#{self.psc} is awake and looks alert.")
      else
        @player.tell("#{self.psc} is awake, but has been staring off into space for #{StringUtils.from_seconds(@idle_seconds)}.")
      end
    else
      @player.tell("#{self.psc} is sleeping.")
    end
    @player.tell("Carrying:")
    self.contents.each { |object| @player.tell('  ', object.title) }
  end
  
  def tell(*args)
    c.puts args.to_s unless self.gaglist.member?(self)
  end

  def tell_lines(*lines)
    unless self.gaglist.member?(@this)
      lines.each do |line|
        c.print "#{line}\n"
      end
    end
  end

  def start_connection()
    
    Thread.new do
      loop do
        CommandUtils.suspend(1)
        @connected_seconds += 1
      end
    end
      
    Thread.new do
      loop do
        CommandUtils.suspend(1)
        @idle_seconds += 1
      end
    end
      
    puts "Log -> #{self.name} logs in."
    
  end

  def connected_seconds
    @connected_seconds
  end

end