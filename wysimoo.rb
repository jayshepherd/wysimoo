require 'socket'

def system(*args)
  @player.tell 'Please don\'t do that.'
end

require 'kernel_appendage(s)'
require 'error_classes'
require 'negative_number_classes'
require 'contstants'
require 'functions'
require '/utilities/command_utils'
require '/utilities/string_utils'
require '/classes/root_class'
require '/classes/thing'
require '/classes/room'
PlayerStart = create(Room, Admin)
PlayerStart.description = 'This is the default home for players.'
PlayerStart.name = 'Player Start'
require '/classes/player'