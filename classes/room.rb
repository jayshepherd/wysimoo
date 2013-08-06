# NOTE: Some of these methods may not work the way that they are described in the decriptions.

# The Room class quick guide:
#
#   properties: (all are readable and writable)
#     residents  => [self.owner]
#     free_entry => true
#     entrances  => []
#     exits      => []
#     dark       => false
#     ctype      => 3
#
#   methods:
#     ejection_msg()                 => message sent to a player that has just ejected another player
#     victim_ejection_msg()          => message sent to an ejected player
#     oejection_msg()                => message sent to other players in the room when a player is ejected
#     confunc()                      => method to call when a player logs in inside of the room
#     disfunc()                      => method to call when a player logs out inside of the room
#     match(string)                  => matches a string to an object in its contents (the StringUtils.match method that is used in the Room.match method may not work correctly)
#     say(*args)                     => a player command that is used to say things to others in the room.
#     emote(*args)                   => used for emoting (calls the emote1 method to announce it to others in the room)
#     emote1(*args)                  => see `emote'
#     announce(*args)                => annouces the result of the concatenation of the arguments to everything in the room except for the player
#     announce_all_but(list, *args)  => does the same thing as announce, except you can specify who does not gets the message
#     huh(string)                    => calls huh2(string)
#     huh2(string)                   => a method for last resort look-ups to try to find out what the player means
#     look_self()                    => tells the player what the room looks like
#     recycle()                      => a methods to be called just before recycling; moves players to their homes, move anything other than a player to its owner, makes its exits' sources Nothing, and makes its entrances destinations Nothing
#     match_exit(string)             => matches a string to an exit using StringUtils.match()
#     add_exit(exit, index=nil)      => adds an exit to the room; the index argument is optional, but without it, this method appends the exit to the rooms list of exits
#     _exits()                       => a player command used to list the exits of a room; only the owner, a resident, or an admin should be able use this successfully
#     tell_contents()                => used to tell the contents of the room to the player
#     tell_exits()                   => used to list out the room's obvious exits
#     add_entrance(entrance)         => adds an entrance to the room
#     _entrances()                   => see `_exits'; this does pretty much the same thing except with entrances to the room
#     go(*exits)                     => a player command used to move through multiple exits in succession
#     look(*args)                    => this is not finished yet; it is supposed to call the look_self method on objects that are specified by the player; if no objects are specified, it calls the look_self method on the room
#     announce_all(*args)            => tells the result of the concatenation of all of the arguments to EVERYTHING in the room
#     enterfunc(obj)                 => calls the look_self method the room if obj is a player; this method is to be called when an object enters the room
#     exitfunc(obj)                  => this method is to be called when an object exits the room; though it does nothing, it could programmed to do some interesting things based on what object exits the room
#     remove_exit(exit)              => sets exit's source to Nothing and removes it from the room's list of exits
#     remove_entrance(entrance)      => sets entrance's destination to Nothing and removes it from the room's list of entrances
#     _eject(dude)                   => moves dude to his home if he is a non-admin player; it moves a non-player object to Nothing; it also tells some messages

class Room

  attr_accessor :residents, :free_entry, :entrances, :exits, :dark, :ctype

  def initialize
    super()
    self.residents = [self.owner]
    self.free_entry = true
    self.entrances = []
    self.exits = []
    self.dark = false
    self.ctype = 3
  end

  def victim_ejection_msg
    "%n expels you from #{self.name}."
  end

  def oejection_msg(dude)
    "%n expels #{dude.name} from #{self.name}."
  end

  def ejection_msg(dude)
    "You expel #{dude.name} from #{self.name}"
  end

  def confunc()
    self.look_self
    self.announce(@player.name, ' has connected.')
    true
  end

  def disfunc()
    self.announce(@player.name, ' has disconnected.')
    Thread.new do
      suspend(900)
      @player.moveto(@player.home)
    end
    true
  end

  def match(str)
    StringUtils.match(str, *self.contents)
  end

  def say(*args)
    self.contents.each do |dude|
      if dude == @player
        dude.tell('You say "', StringUtils.custom_delim_list(' ', *args), '"')
      else
        dude.tell(@player.name, ' says "', args.join(' '), '"')
      end
    end
  end

  def emote(*args)
    @player.tell(@player.name, ' ', args.join(' '))
    self.emote1(*args)
  end

  def emote1(*args)
    self.announce(@player.name, ' ', args.join(' '))
  end

  def announce(*args)
    args.each { |arg| arg = arg.to_s }
    setremove(self.contents, @player).each do |dude|
      dude.tell args.join('')
    end
  end

  def announce_all_but(list, *args)
    self.contents.each { |dude| dude.tell(*args) unless dude.in(list) }
  end

  def huh(string)
    huh2(string)
  end

  def huh2(string)
    if (string =~ /_.+_msg\s.+\sis\s.+/) == 0
      args = StringUtils.explode(string, ' ')
      obj = self.match(args[1])
      prop = args[0][1..(args[0].length-1)]
      if (obj.owner == @player or @player.admin)
        if object.respond_to?(eval(":#{prop}="))
          eval("obj.#{prop} = #{args[3]}")
          @player.tell("You set the #{prop} property of #{obj.title}")
        else
          @player.tell("#{obj.title} does not seem to have a writable #{prop} property.")
        end
      else
        @player.tell('You are not allowed to do that.')
      end
    end
    if (exit = self.match_exit(string))
      exit.invoke
    end
  end

  def look_self
    @player.tell(self.name)
    @player.tell(StringUtils.space(self.name.length, '-'))
    @player.tell()
    self.tell_contents()
    self.tell_exits()
  end

  def recycle
    self.contents.each do |dude|
      if is_player(dude)
        dude.moveto dude.home
      else
        dude.moveto dude.owner
      end
    end
    self.exits.each { |exit| exit.source = Nothing }
    self.entrances.each { |entrance| entrance.dest = Nothing }
  end

  def match_exit(string)
    StringUtils.match(string, *self.exits)
  end

  def add_exit(exit, index=nil)
    if index == nil
      self.exits = listappend(self.exits, exit)
    else
      self.exits = listinsert(self.exits, exit, index-1)
    end
    exit.source = self
    true
  end

  def _exits()
    if @player == self.owner or @player.in(self.residents) or @player.admin
      @player.tell('Exits:')
      self.exits.each do |exit|
        @player.tell("#{exit.name} (Aliases: #{StringUtils.english_list(exit.aliases)}) takes you to #{exit.dest.title}.")
      end
    end
  end

  def tell_contents
    if self.ctype == 0
      
      @player.tell('Contents:')
      setremove(self.contents, @player).each { |o| @player.tell('  ', o.title) }

    elsif self.ctype == 1
      
      setremove(self.contents, @player).each do |o|
        self.contents.each do |o|
          if is_player(o)
            @player.tell(o.title, ' is here.')
          else
            @player.tell('You see ', o.title, ' here.')
          end
        end
      end

    elsif self.ctype == 2
      
      titles = []
      setremove(self.contents, @player).each { |o| titles << o.title }
      @player.tell('You see ', StringUtils.english_list(titles), ' here.')

    elsif self.ctype == 3
      
      setremove(self.contents, @player).each do |o|
        players = []
        things = []
        player_titles = []
        thing_titles = []
        if is_player(x)
          players << x
          player_titles << x.title
        else
          things << x
          thing_titles << x.title
        end
      end
      if thing_titles.length > 0
        @player.tell('You see ', StringUtils.english_list(thing_titles), ' here.')
      end
      if player_titles.length > 0
        @player.tell(StringUtils.english_list(player_titles), (player_titles.length > 1 ? ' are' : ' is'), 'here')
      end

    end
  end

  def tell_exits()
    sets = []
    self.exits.each do |exit|
      if exit.obvious?
        sets << [exit.name, exit.aliases[0]]
      end
    end
    string = 'Obvious Exits: '
    sets.each { |set| string << "#{set[0]} [#{set[1]}], " }
    @player.tell(string)
  end

  def add_entrance(entrance)
    self.entrances.push(entrance)
    entrance.dest = self
  end

  def _entrances
    if @player == self.owner or @player.in(self.residents) or @player.admin
      @player.tell('Entrances:')
      self.entrances.each { |entrance| @player.tell "#{entrance.name} (Aliases: #{StringUtils.english_list(entrance.aliases)}) should take you here from #{entrance.source.title}." }
    end
  end
 
  def go(*exits)
    # See README for the acknowledgement for this code:
    exits.each do |dir|
      exit = self.match_exit(dir)
      if exit.in([Nothing, AMBIGUOUS_MATCH, FAILED_MATCH])
        @player.tell('Go where?')
      else
        exit.invoke
      end
    end
  end

  # This is not finished yet.
  def look(*args)
    if args.empty?
      self.look_self
    end
  end

  def announce_all(*args)
    self.contents.each { |dude| dude.tell(args.join) }
  end

  def enterfunc(obj)
    self.look_self() if is_player(obj)
  end

  def exitfunc(obj)
  end

  def remove_exit(exit)
    exit.source = Nothing
    setremove!(self.exits, exit)
  end

  def remove_entrance(entrance)
    entrance.dest = Nothing
    setremove!(self.entrances, entrance)
  end

  def _eject(dude)
    if is_player(dude)
      if dude.admin
        player.tell 'You can\'t _eject an admin.'
      else
        dude.moveto dude.home
      end
    else
      dude.moveto Nothing
    end
    self.announce_all_but([@player, dude], StringUtils.pronoun_sub(self.oejection_msg(dude)))
    @player.tell StringUtils.pronoun_sub(self.ejection_msg(dude))
    dude.tell StringUtils.pronoun_sub(self.victim_ejection_msg)
  end

end