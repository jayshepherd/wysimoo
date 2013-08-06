module StringUtils

  def english_list(*args)
    return args[0..length(args)-2].join(', ') + 'and ' + args[length(args)-1]
  end

  def custom_delim_list(delimiter, *args)
    return args.join(delimiter.to_s)
  end

  def comma_delim_list(*args)
    args.each { |arg| arg = arg.to_s }
    args.join(', ')
  end

  def explode(str, str_break = ' ')
    str.split(/#{Regexp.escape(str_break)}/)
  end

  def space(length, padding)
    string = ''
    length.times do
      string += padding
    end
    string
  end

  def pronoun_sub(string, dude)
    modified_string = string
    placeholders = ['%s', '%S', '%o', '%O', '%p', '%P', '%r', '%R', '%n', '%N']
    props = ['ps', 'psc', 'po', 'poc', 'pp', 'ppc', 'pr', 'prc', 'name', 'name[0].chr.upcase + @player.name[1..@player.name.length]']
    if is_player(dude)
      index = 0
      placeholders.each do |placeholder|
        modified_string = strsub(string, placeholder, eval("@player.#{props[index]}"))
        index += 1
      end
      modified_string
    else
      modified_string = strsub(string, '%n', dude.name)
      modified_string = strsub(string, '%N', dude.name[0].chr.upcase + dude.name[1..dude.name.length])
    end
  end

  def from_seconds(amount)
    raise E_INVARG if amount < 0
    if amount >= 0 and amount <= 57
      "#{amount} seconds"
    elsif amount >= 57 and amount <= 3420
      "about #{(amount/60).round} minute#{(amount/60).round == 1 ? '' : 's'}"
    elsif amount > 3420 and amount <= 86000
      "around #{(amount/60/60).round} hour#{(amount/60/60).round == 1 ? '' : 's'}"
    elsif amount >= 86000
      "about #{(amount/60/60/24).round} day#{(amount/60/60/24).round == 1 ? '' : 's'}"
    end
  end

  def match(string, *object_list)
    
    string.downcase!
    match = FailedMatch
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
          match = AmbiguousMatch
        else
          find = true
          match = object_list[index]
        end
      end
      index += 1
    end

    if match == FailedMatch
      index = 0
      string_sets.each do
        string_sets[index].each do |s|
          if s.start_with?(string)
        end
      end
    end
    
    if match == FailedMatch
      if string == 'me'
        match = @player
      elsif match == 'here'
        match = @player.location
      end
    end

    return match
  end

end