module Functions
  
  def abs(number)
    number = number.to_i
    # I could use `number.abs', but that's to easy.
    if number < 0
      number - number - number
    else
      number
    end
  end

  def add_to_tasks(time, name)
    Tasks << [name, ctime(), time, Next_task_id]
    Next_task_id.succ!
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
    Connections.each { |player| player.tell(msg) }
  end

  def connected_players
    Connections 
  end

  def connected_seconds(player)
    if is_player(player)
      player.connected_seconds
    else
      raise E_INVARG
    end
  end
  
  def create(_class, owner=nil)
    obj = _class.new
    if owner == nil and _class == Player
      obj.owner = obj
    elsif owner == nil
      obj.owner = @player
    end
    obj
  end

  def ctime(time = nil)
    if time == nil
      Time.now.to_s
    else
      (Time.at(time) + 21600).to_s
    end 
  end

  def fork(seconds, name)
    # By the way, this probably does not work yet.
    task_id = Next_task_id
    add_to_tasks(seconds, name.to_s)
    Thread.new do
      sleep(seconds)
      yield
      remove_from_tasks(task_id)
    end
  end

  def idle_seconds(player)
    if is_player(player)
      player.idle_seconds;
    else
      raise E_INVARG
    end
  end

  def is_player(object)
    if object.is_a? Player
      true
    else
      false
    end
  end
  
  # This function may be removed later.
  def length(obj)
    if 'length'.in(obj.methods) == 0
      raise E_INVARG
    else
      obj.length
    end
  end

  def listappend(list, value, index = nil)
    raise E_INVARG if typeof index == BOOL || typeof index == RGXP
    if index
      index = index.to_i
      list[0..index] + [value] + list[index+1..list.length-1]
    else
      list + [value]
    end
  end

  def listdelete(list, index)
    list[0..index-1] + list[index+1..list.length]
  end

  def listinsert(list, value, index = nil)
    if index
      list[0..index-1] + [value] + list[index..list.length-1] 
    else
      [value] + list
    end
  end 
   
  def listset(list, value, index)
    if index == 0 and list.length == 1
      return [value]
    elsif list.length > 1
      list[0..index-1] + [value] + list[index+1..list.length-1]
    else
      raise E_RANGE
    end
  end

  def max(*args)
    list = []
    args.each { |a| list << a if a.is_a? Numeric }
    list.max
  end

  def methods(o)
    o.methods
  rescue NoMethodError
    raise E_METHNF
  end

  def min(*args)
    list = []
    args.each { |a| list << a if a.is_a? Numeric }
    list.min
    end
  end

  def move(object, location)
    if location != object.location and object.w
      object.location.contents = (setremove(location.contents, object))
      object.location = location
    elsif object.w == false # This probably makes more sense than `elsif !object.w'.
      raise E_PERM
    end
  end

  def notify(player, msg)
    player.tell(msg)
  end

  def parent(obj)
    if obj.class == Class
      obj.superclass
    else
      obj.class
    end
  end

  def players
    Players
  end

  def random(num = HighInt)
    Array(1..num)[rand(num)]
  end

  def remove_from_tasks(id)
    index = 0
    find = false
    Tasks.each do |e|
      if e[e.length-1] == id
        Tasks = listdelete(Tasks, index)
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
      list
    else
      listappend(list, e)
    end
  end

  def setremove(list, e)
    list2 = []
    index = 0
    list.each do |element|
      if element == e
        list2.concat(ary[index+1..(ary.length-1)])
        break
      else
        list2 << element
        index += 1
      end
    end
    list2
  end

  def setremove!(list, e)
    list = setremove(list, e)
  end

  def setadd!(list, e)
    list = setadd(list, e)
  end

  def sqrt(x)
    Math.sqrt x
  rescue => error
    raise E_INVARG if error.class = Errno::EDOM or ArgumentError
  end

  def strsub(str, what_to_replace, replacement_for_each)
    # Just in case:
    str = str.to_s
    what_to_replace = what_to_replace.to_s 
    replacement_for_each = replacement_for_each.to_s

    str.gsub(/#{Regexp.escape(what_to_replace)}/) { replacement_for_each }
  end

  def suspend(secs)
    sleep(secs)
    nil
  end

  # This method may not end up being used much.
  def task_list
    Tasks
  end

  def time
    t = Time.mktime(1970, 1, 1, 0, 0, 0)
    (Time.now - t).to_i
  end

  def toint(*args)
    number = 0
    args.each { |e| number += e.to_i }
    number
  end

  def tolist(*args)
    [*args]
  end

  def toliteral(o)
    o.inspect
  end

  def tonum(value)
    if value.is_a? String
      ary = value.split(//)
      return_value = ''
      ary.each { |char| return_value += char if /\d/.match(char)
      return_value.to_i
    elsif value.is_a? Numeric
      value
    else
      raise E_TYPE
    end
  end

  def tostr(*args)
    args.to_s
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
      obj.singleton_methods.sort
    else 
      obj.singleton_methods
    end
  end

end

include Functions