module Kernel
  def in(ary)
    index = 0
    ary.each do |e|
      if self == e 
        break 
      else 
        index += 1
      end
    end
    if index == ary.length
      return 0
    else
      return index
    end
  end
end

$connections = []
$players = []
$tasks = []
$next_task_id = '000001'
NUM = 0
STR = 1
LIST = 2
OBJ = 3
ERR = 4
RGXP = 5
HASH = 6
RANGE = 7
BOOL = 8
NULL = 9

class Nothing < NilClass
end

class AMBIG_MATCH < NilClass
end

class FAIL_MATCH < NilClass
end

$nothing = Nothing
$ambiguous_match = AMBIG_MATCH
$failed_match = FAIL_MATCH
$high_int = 2 ** 100000

class E_INVARG < StandardError
  def self.message
    'E_INVARG'
  end
end

class E_DIV < StandardError
  def self.message
    'E_DIV'
  end
end

class E_TYPE < StandardError
  def self.message
    'E_TYPE'
  end
end

class E_RANGE < StandardError
  def self.message
    'E_RANGE'
  end
end

class E_METHNF < StandardError
  def self.message
    'E_METHNF'
  end
end

class E_PERM < StandardError
  def self.message
    'E_PERM'
  end
end

module Functions
  
  def abs(number)
    if number < 0
      return number - number - number
    else
      return number
    end
  end

  def add_to_tasks(time, name)
    $tasks << [name, ctime(), time, $next_task_id]
    $next_task_id.succ!
  end

  def all_verbs(obj, options = {:sort => true})
    if options[:sort]
      obj.methods.sort
    else
      obj.methods
    end
  end

  def boot_player(connection)
    connection.tell '*** Disconnect ***'
    msg = "#{connection.name}#{connection.quit_msg}"
    c.close
    broadcast msg
  end

  def broadcast(msg)
    @connections.each { |player| player.tell(msg) }
  end

  def connected_players; @connections; end

  def connected_seconds(player)
    if is_player(player)
      return player.connected_seconds
    else
      raise E_INVARG
    end
  end

  def ctime(time = nil)
    if time == nil
      Time.now.to_s
    else
      (Time.at(time) + 21600).to_s
    end 
  end

  def fork(seconds, name)
    task_id = $next_task_id
    add_to_tasks(seconds, name.to_s)
    return Thread.new do
      sleep(seconds)
      yield
      remove_from_tasks(task_id)
    end
  end

  def idle_seconds(player)
    if is_player(player)
      return player.idle_seconds;
    else
      raise E_INVARG
    end
  end

  def is_player(object)
    if object.is_a? Player
     return true
   else
      return false
   end
  end

  def length(obj)
    if 'length'.in(obj.methods) == 0
      raise E_INVARG
    else
      return obj.length
    end
  end

  def listappend(list, value, index = nil)
    if index == nil
      return list + [value]
    else
      return list[0..index] + [value] + list[index+1..list.length-1]
    end
  end

  def listdelete(list, index)
    return list[0..index-1] + list[index+1..list.length]
  end

  def listinsert(list, value, index = nil)
    if index == nil
      return [value] + list
    else
      return list[0..index-1] + [value] + list[index..list.length-1]
    end
  end 
   
  def listset(list, value, index)
    if index > list.length-1
      raise E_RANGE
    else
      return list[0..index-1] + [value] + list[index+1..list.length-1]
    end
  end

  def max(*args)
    list = []
    args.each do |a|
      if a.is_a? Numeric
        list << a
      end
      return list.max
    end
  end

  def methods(o)
    begin
      return o.methods
    rescue NoMethodError
      raise E_METHNF
    end
  end

  def min(*args)
    list = []
    args.each do |a|
      if a.is_a? Numeric
        list << a
      end
      return list.min
    end
  end

  def move(object, location)
    if location != object.location and object.w
      object.location.contents = (setremove(location.contents, object))
      object.location = location
    elsif !object.w
      raise E_PERM
    end
  end

  def notify(player, msg)
    player.tell(msg)
  end

  def parent(obj)
    if obj.class == Class
      return obj.superclass
    else
      return obj.class
    end
  end

  def players
    $players
  end

  def random(num = $high_int)
    ((1..num).to_a)[rand(num)]
  end

  def remove_from_tasks(id)
    index = 0
    find = false
    $tasks.each do |e|
      if e[e.length-1] == id
        $tasks = listdelete($tasks, index)
        find = true
        break
      else
        index += 1
      end
    end
    if find == false
      raise E_INVARG
    end
  end


  def setadd(list, e)
    if list.member?(e)
      return list
    else
      return listappend(list, e)
    end
  end

  def setremove(list, e)
    return_list = []
    index = 0
    list.each do |element|
      if element == e
        return_list.concat(ary[index+1..(ary.length-1)])
        break
      else
        return_list << element
        index += 1
      end
    end
    return return_ary
  end

  def sqrt(x)
    return Math.sqrt(x)
  rescue Errno::EDOM
    raise E_INVARG
  end

  def str_split(str)
    str.split(/\s/)
  end

  def strsub(str, what_to_replace, replacement_for_each)
    str = str.to_s
    what_to_replace = what_to_replace.to_s
    replacement_for_each = replacement_for_each.to_s
    str.gsub(/#{Regexp.escape(what_to_replace.to_s)}/) { replacement_for_each }
  end

  def suspend(secs)
    sleep(secs)
    return nil
  end

  def task_list
    $tasks
  end

  def time
    t = Time.mktime(1970, 1, 1, 0, 0, 0)
    return (Time.now - t).to_i
  end

  def toint(*args)
    number = 0
    args.each { |e| number += e.to_i }
    return number
  end

  def tolist(*args); return [*args]; end

  def toliteral(o); return o.inspect.to_s; end

  def tonum(val)
    if val.is_a? String
      ary = val.split(//)
      return_val = ''
      ary.each do |l|
        if /\d/.match(l)
          return_val += l
        end
      end
      return_val = return_val.to_i
      return return_val
    elsif val.is_a? Numeric
      return val
    else
      raise E_TYPE
    end
  end

  def tostr(*args)
    main_str = ''
    args.each { |e| main_str += e.to_s }
    return main_str
  end

  def typeof(value)
    if value.is_a? Numeric
      NUM
    elsif value.is_a? String
      STR
    elsif value.is_a? Array
      LIST
    elsif value.is_a? StandardError
      ERR
    elsif value.is_a? Regexp
      RGXP
    elsif value.is_a? Hash
      HASH
    elsif value.is_a? Range
      RANGE
    elsif value == true or value == false
      BOOL
    elsif value == nil
      NIL
    elsif value.is_a? Object
      OBJ
    end
  end

  def verbs(obj, options = {:sort => true})
    if options[:sort]
      return obj.singleton_methods.sort
    else 
      return obj.singleton_methods
    end
  end

end


class RootClass
  
  @this = self
  attr_accessor :name, :owner, :location, :contents, :programmer, :admin, :r, :w, :key, :aliases, :description

  def initialize
    @this.name = ''
    @this.owner = $nothing
    @this.location = Nothing
    @this.contents = []
    @this.programmer = false
    @this.admin = false
    @this.r = true
    @this.w = true
    @this.description = ''
  end

  def desc_msg
    if @this.r
      @this.description.empty? ? 'You see nothing special.' : @this.description
    else
      raise E_PERM
    end
  end

  def description=(desc)
    if @this.w
      self.description = desc.to_s
    else
      raise E_PERM
    end
  end

  def look_self
    if @this.r
      @player.tell(@this.description)
    else
      raise E_PERM
    end
  end

  def moveto(location)
    move(@this, location)
  end

  def tell(*args)
    # This method is just here so that it can be called, but it does nothing.
    # If you want an object to do something, you can program the 'tell' method
    # directly onto the object.
  end

  def exam
    if @this.r
      @player.tell_lines("#{@this.name} (#{@this.object_id}) is owned by #{@this.owner == $nothing ? 'no one' : @this.owner.name} (#{@this.owner == $nothing ? '$nothing' : @this.owner.name})", "Aliases: #{StringUtils.english_list(@this.aliases)}.", @this.description.empty? ? '(No description set.)' : @this.description)
    else
      raise E_PERM
    end
  end

  def title()
    if @this.r
      @this.name
    else
      raise E_PERM
    end
  end

  def eject(victim)
    move(victim, $nothing)
  end

end

class Room
  @this = self
  attr_accessor :victim_ejection_msg, :ejection_msg, :oejection_msg, :residents, :free_entry, :entrances, :exits, :dark, :ctype

  def initialize
    super()
    @this.victim_ejection_msg = '%n expels you from %t.'
    @this.ejection_msg = 'You expel %n from %t.'
    @this.oejection_msg = '%n ejects %d from %t.'
    @this.residents = [@this.owner]
    @this.free_entry = true
    @this.entrances = []
    @this.exits = []
    @this.dark = false
    @this.ctype = 3
  end

  def confunc()
    @this.look_self()
    @this.announce(@player.name, ' has connected.')
  end

  def disfunc()
    @this.announce(@player.name, ' has disconnected.')
    Thread.new do
      suspend(900)
      @player.moveto(@player.home)
    end
  end

  def say(*args)
    @this.contents.each do |dude|
      if dude == @player
        dude.tell('You say "', StringUtils.custom_delim_list(' ', *args), '"')
      else
        dude.tell(@player.name, ' says "' StringUtils.custom_delim_list(' ', *args), '"')
      end
    end
  end

  def emote(msg)
    @player.tell(@player.name, ' ', msg)
    @this.emote1(msg)
  end

  def emote1(msg)
    @this.announce(@player.name, ' ', msg)
  end

  def announce(msg)
    setremove(@this.contents, @player).each do |dude|
      dude.tell msg
    end
  end

  def announce_all_but(list, *args)
    @this.contents.each do |dude|
      dude.tell(*args) unless dude.in(list)
    end
  end

  def huh()
  end

  def match_exit(exit)
    return StringUtils.match(exit, *@this.exits)
  end

  def add_exit(exit, index=nil)
    if index == nil
      @this.exits = listappend(@this.exits, exit)
    else
      @this.exits = listinsert(@this.exits, exit, index-1)
    end
  end

  def tell_contents
    if @this.ctype == 0
      @player.tell('Contents:')
      setremove(@this.contents, @player).each do |o|
        @player.tell(o.name)
      end
    elsif @this.ctype == 1
      setremove(@this.contents, @player).each do |o|
        @this.contents.each do |o|
          if o.is_a? Player
            @player.tell(o.name, ' is here.')
          else
            @player.tell('You see ', o.name, ' here.')
          end
        end
      end
    elsif @this.ctype == 2
      names = []
      setremove(@this.contents, @player).each do |o|
        names << o.name
      end
      @player.tell('You see ', StringUtils.english_list(names), ' here.')
    elsif @this.ctype == 3
      setremove(@this.contents, @player).each do |o|
        players = []
        things = []
        player_titles = []
        thing_titles = []
        if x.is_a? Player
          players << x
          player_titles << x.title
        else
          things << x
          thing_titles << x.title
        end
      end
      @player.tell('You see ', StringUtils.english_list(thing_titles), ' here.')
      @player.tell(pl)
    end
  end

end

class Player < RootClass

  attr_accessor :quit_msg, :password, :gaglist
  attr_reader :connected_seconds, :idle_seconds

  def initialize
    $players << self
    self.name = ''
    @location = nil
    @contents = []
    @connected_seconds = 0
    @idle_seconds = 0
    self.quit_msg = ' has disconnected.'
    self.password = ''
    self.gaglist = []
  end

  def tell(*args)
    unless self.gaglist.member?(@this)
      c.puts tostr(args)
    end
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

module CommandUtils
    
  def self.read
    Thread.new { c.gets.chomp.downcase }
  end

  def self.suspend(secs)
    suspend(secs)
  end
  
end

module StringUtils

  def english_list(*args)
    return args[0..length(args)-2].join(', ') + 'and ' + args[length(args)-1]
  end

  def custom_delim_list(delimiter, *args)
    return args.join(delimiter.to_s)
  end

  def comma_delim_list(*args)
    return args.join(', ')
  end

  def self.match(string, *object_list)
    
    string.downcase!
    match = $failed_match
    string_sets = []
    find = false
    index = 0
    
    object_list.each do |object|
      set = [object.name]
      object.aliases.each do |a|
        set.concat(a.downcase)  
      end
      string_sets << set
    end

    string_sets.each do
      set = string_sets[index]
      if set.member?(string.downcase)
        if find
          match = $ambiguous_match
        else
          find = true
          match = object_list[index]
        end
      end
      index += 1
    end

    if match == $failed_match
      index = 0
      string_sets.each do
        string_sets[index].each do |s|
          if s.start_with?(string)
        end
      end
    end
    
    if match == $failed_match
      if string == 'me'
        match = @player
      elsif match == 'here'
        match = @player.location
      end
    end

    return match
  end

end


include Functions

def parse(str)
  verb = str_split(str)[0]
  dobj = str_split(str)[1]
  prep = str_split(str)[2]
  iobj = str_split(str)[3]
  $SAFE = 4
  # Eval. . . ?
end

$root_class = RootClass
















require "yaml"
def checkpoint


$connections = []
$players = []
$tasks = []
$next_task_id = '000001'
NUM = 0
STR = 1
LIST = 2
OBJ = 3
ERR = 4
RGXP = 5
HASH = 6
RANGE = 7
BOOL = 8
NULL = 9

class Nothing < NilClass
end

class AMBIG_MATCH < NilClass
end

class FAIL_MATCH < NilClass
end

$nothing = Nothing
$ambiguous_match = AMBIG_MATCH
$failed_match = FAIL_MATCH
$high_int = 2 ** 100000

class E_INVARG < StandardError
  def self.message
    'E_INVARG'
  end
end

class E_DIV < StandardError
  def self.message
    'E_DIV'
  end
end

class E_TYPE < StandardError
  def self.message
    'E_TYPE'
  end
end

class E_RANGE < StandardError
  def self.message
    'E_RANGE'
  end
end

class E_METHNF < StandardError
  def self.message
    'E_METHNF'
  end
end

class E_PERM < StandardError
  def self.message
    'E_PERM'
  end
end

module Functions
  
  def abs(number)
    if number < 0
      return number - number - number
    else
      return number
    end
  end

  def add_to_tasks(time, name)
    $tasks << [name, ctime(), time, $next_task_id]
    $next_task_id.succ!
  end

  def all_verbs(obj, options = {:sort => true})
    if options[:sort]
      obj.methods.sort
    else
      obj.methods
    end
  end

  def boot_player(connection)
    connection.tell '*** Disconnect ***'
    msg = "#{connection.name}#{connection.quit_msg}"
    c.close
    broadcast msg
  end

  def broadcast(msg)
    @connections.each { |player| player.tell(msg) }
  end

  def connected_players; @connections; end

  def connected_seconds(player)
    if is_player(player)
      return player.connected_seconds
    else
      raise E_INVARG
    end
  end

  def ctime(time = nil)
    if time == nil
      Time.now.to_s
    else
      (Time.at(time) + 21600).to_s
    end 
  end

  def fork(seconds, name)
    task_id = $next_task_id
    add_to_tasks(seconds, name.to_s)
    return Thread.new do
      sleep(seconds)
      yield
      remove_from_tasks(task_id)
    end
  end

  def idle_seconds(player)
    if is_player(player)
      return player.idle_seconds;
    else
      raise E_INVARG
    end
  end

  def is_player(object)
    if object.is_a? Player
     return true
   else
      return false
   end
  end

  def length(obj)
    if 'length'.in(obj.methods) == 0
      raise E_INVARG
    else
      return obj.length
    end
  end

  def listappend(list, value, index = nil)
    if index == nil
      return list + [value]
    else
      return list[0..index] + [value] + list[index+1..list.length-1]
    end
  end

  def listdelete(list, index)
    return list[0..index-1] + list[index+1..list.length]
  end

  def listinsert(list, value, index = nil)
    if index == nil
      return [value] + list
    else
      return list[0..index-1] + [value] + list[index..list.length-1]
    end
  end 
   
  def listset(list, value, index)
    if index > list.length-1
      raise E_RANGE
    else
      return list[0..index-1] + [value] + list[index+1..list.length-1]
    end
  end

  def max(*args)
    list = []
    args.each do |a|
      if a.is_a? Numeric
        list << a
      end
      return list.max
    end
  end

  def methods(o)
    begin
      return o.methods
    rescue NoMethodError
      raise E_METHNF
    end
  end

  def min(*args)
    list = []
    args.each do |a|
      if a.is_a? Numeric
        list << a
      end
      return list.min
    end
  end

  def move(object, location)
    if location != object.location and object.w
      object.location.contents = (setremove(location.contents, object))
      object.location = location
    elsif !object.w
      raise E_PERM
    end
  end

  def notify(player, msg)
    player.tell(msg)
  end

  def parent(obj)
    if obj.class == Class
      return obj.superclass
    else
      return obj.class
    end
  end

  def players
    $players
  end

  def random(num = $high_int)
    ((1..num).to_a)[rand(num)]
  end

  def remove_from_tasks(id)
    index = 0
    find = false
    $tasks.each do |e|
      if e[e.length-1] == id
        $tasks = listdelete($tasks, index)
        find = true
        break
      else
        index += 1
      end
    end
    if find == false
      raise E_INVARG
    end
  end


  def setadd(list, e)
    if list.member?(e)
      return list
    else
      return listappend(list, e)
    end
  end

  def setremove(list, e)
    return_list = []
    index = 0
    list.each do |element|
      if element == e
        return_list.concat(ary[index+1..(ary.length-1)])
        break
      else
        return_list << element
        index += 1
      end
    end
    return return_ary
  end

  def sqrt(x)
    return Math.sqrt(x)
  rescue Errno::EDOM
    raise E_INVARG
  end

  def str_split(str)
    str.split(/\s/)
  end

  def strsub(str, what_to_replace, replacement_for_each)
    str = str.to_s
    what_to_replace = what_to_replace.to_s
    replacement_for_each = replacement_for_each.to_s
    str.gsub(/#{Regexp.escape(what_to_replace.to_s)}/) { replacement_for_each }
  end

  def suspend(secs)
    sleep(secs)
    return nil
  end

  def task_list
    $tasks
  end

  def time
    t = Time.mktime(1970, 1, 1, 0, 0, 0)
    return (Time.now - t).to_i
  end

  def toint(*args)
    number = 0
    args.each { |e| number += e.to_i }
    return number
  end

  def tolist(*args); return [*args]; end

  def toliteral(o); return o.inspect.to_s; end

  def tonum(val)
    if val.is_a? String
      ary = val.split(//)
      return_val = ''
      ary.each do |l|
        if /\d/.match(l)
          return_val += l
        end
      end
      return_val = return_val.to_i
      return return_val
    elsif val.is_a? Numeric
      return val
    else
      raise E_TYPE
    end
  end

  def tostr(*args)
    main_str = ''
    args.each { |e| main_str += e.to_s }
    return main_str
  end

  def typeof(value)
    if value.is_a? Numeric
      NUM
    elsif value.is_a? String
      STR
    elsif value.is_a? Array
      LIST
    elsif value.is_a? StandardError
      ERR
    elsif value.is_a? Regexp
      RGXP
    elsif value.is_a? Hash
      HASH
    elsif value.is_a? Range
      RANGE
    elsif value == true or value == false
      BOOL
    elsif value == nil
      NIL
    elsif value.is_a? Object
      OBJ
    end
  end

  def verbs(obj, options = {:sort => true})
    if options[:sort]
      return obj.singleton_methods.sort
    else 
      return obj.singleton_methods
    end
  end

end


class RootClass
  
  @this = self
  attr_accessor :name, :owner, :location, :contents, :programmer, :admin, :r, :w, :key, :aliases, :description

  def initialize
    @this.name = ''
    @this.owner = $nothing
    @this.location = Nothing
    @this.contents = []
    @this.programmer = false
    @this.admin = false
    @this.r = true
    @this.w = true
    @this.description = ''
  end

  def desc_msg
    if @this.r
      @this.description.empty? ? 'You see nothing special.' : @this.description
    else
      raise E_PERM
    end
  end

  def description=(desc)
    if @this.w
      self.description = desc.to_s
    else
      raise E_PERM
    end
  end

  def look_self
    if @this.r
      @player.tell(@this.description)
    else
      raise E_PERM
    end
  end

  def moveto(location)
    move(@this, location)
  end

  def tell(*args)
    # This method is just here so that it can be called, but it does nothing.
    # If you want an object to do something, you can program the 'tell' method
    # directly onto the object.
  end

  def exam
    if @this.r
      @player.tell_lines("#{@this.name} (#{@this.object_id}) is owned by #{@this.owner == $nothing ? 'no one' : @this.owner.name} (#{@this.owner == $nothing ? '$nothing' : @this.owner.name})", "Aliases: #{StringUtils.english_list(@this.aliases)}.", @this.description.empty? ? '(No description set.)' : @this.description)
    else
      raise E_PERM
    end
  end

  def title()
    if @this.r
      @this.name
    else
      raise E_PERM
    end
  end

  def eject(victim)
    move(victim, $nothing)
  end

end

class Room
  @this = self
  attr_accessor :victim_ejection_msg, :ejection_msg, :oejection_msg, :residents, :free_entry, :entrances, :exits, :dark, :ctype

  def initialize
    super()
    @this.victim_ejection_msg = '%n expels you from %t.'
    @this.ejection_msg = 'You expel %n from %t.'
    @this.oejection_msg = '%n ejects %d from %t.'
    @this.residents = [@this.owner]
    @this.free_entry = true
    @this.entrances = []
    @this.exits = []
    @this.dark = false
    @this.ctype = 3
  end

  def confunc()
    @this.look_self()
    @this.announce(@player.name, ' has connected.')
  end

  def disfunc()
    @this.announce(@player.name, ' has disconnected.')
    Thread.new do
      suspend(900)
      @player.moveto(@player.home)
    end
  end

  def say(*args)
    @this.contents.each do |dude|
      if dude == @player
        dude.tell('You say "', StringUtils.custom_delim_list(' ', *args), '"')
      else
        dude.tell(@player.name, ' says "' StringUtils.custom_delim_list(' ', *args), '"')
      end
    end
  end

  def emote(msg)
    @player.tell(@player.name, ' ', msg)
    @this.emote1(msg)
  end

  def emote1(msg)
    @this.announce(@player.name, ' ', msg)
  end

  def announce(msg)
    setremove(@this.contents, @player).each do |dude|
      dude.tell msg
    end
  end

  def announce_all_but(list, *args)
    @this.contents.each do |dude|
      dude.tell(*args) unless dude.in(list)
    end
  end

  def huh()
  end

  def match_exit(exit)
    return StringUtils.match(exit, *@this.exits)
  end

  def add_exit(exit, index=nil)
    if index == nil
      @this.exits = listappend(@this.exits, exit)
    else
      @this.exits = listinsert(@this.exits, exit, index-1)
    end
  end

  def tell_contents
    if @this.ctype == 0
      @player.tell('Contents:')
      setremove(@this.contents, @player).each do |o|
        @player.tell(o.name)
      end
    elsif @this.ctype == 1
      setremove(@this.contents, @player).each do |o|
        @this.contents.each do |o|
          if o.is_a? Player
            @player.tell(o.name, ' is here.')
          else
            @player.tell('You see ', o.name, ' here.')
          end
        end
      end
    elsif @this.ctype == 2
      names = []
      setremove(@this.contents, @player).each do |o|
        names << o.name
      end
      @player.tell('You see ', StringUtils.english_list(names), ' here.')
    elsif @this.ctype == 3
      setremove(@this.contents, @player).each do |o|
        players = []
        things = []
        player_titles = []
        thing_titles = []
        if x.is_a? Player
          players << x
          player_titles << x.title
        else
          things << x
          thing_titles << x.title
        end
      end
      @player.tell('You see ', StringUtils.english_list(thing_titles), ' here.')
      @player.tell(pl)
    end
  end

end

class Player < RootClass

  attr_accessor :quit_msg, :password, :gaglist
  attr_reader :connected_seconds, :idle_seconds

  def initialize
    $players << self
    self.name = ''
    @location = nil
    @contents = []
    @connected_seconds = 0
    @idle_seconds = 0
    self.quit_msg = ' has disconnected.'
    self.password = ''
    self.gaglist = []
  end

  def tell(*args)
    unless self.gaglist.member?(@this)
      c.puts tostr(args)
    end
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

module CommandUtils
    
  def self.read
    Thread.new { c.gets.chomp.downcase }
  end

  def self.suspend(secs)
    suspend(secs)
  end
  
end

module StringUtils

  def english_list(*args)
    return args[0..length(args)-2].join(', ') + 'and ' + args[length(args)-1]
  end

  def custom_delim_list(delimiter, *args)
    return args.join(delimiter.to_s)
  end

  def comma_delim_list(*args)
    return args.join(', ')
  end

  def self.match(string, *object_list)
    
    string.downcase!
    match = $failed_match
    string_sets = []
    find = false
    index = 0
    
    object_list.each do |object|
      set = [object.name]
      object.aliases.each do |a|
        set.concat(a.downcase)  
      end
      string_sets << set
    end

    string_sets.each do
      set = string_sets[index]
      if set.member?(string.downcase)
        if find
          match = $ambiguous_match
        else
          find = true
          match = object_list[index]
        end
      end
      index += 1
    end

    if match == $failed_match
      index = 0
      string_sets.each do
        string_sets[index].each do |s|
          if s.start_with?(string)
        end
      end
    end
    
    if match == $failed_match
      if string == 'me'
        match = @player
      elsif match == 'here'
        match = @player.location
      end
    end

    return match
  end

end


include Functions

def parse(str)
  verb = str_split(str)[0]
  dobj = str_split(str)[1]
  prep = str_split(str)[2]
  iobj = str_split(str)[3]
  $SAFE = 4
  # Eval. . . ?
end

$root_class = RootClass


  test_obj = Object.new
  yaml_obj = 
  File.open('yaml.yaml', 'w') do |f|
    f.write(YAML::dump(Kernel))
    f.write(YAML::dump)
  end      
end

end