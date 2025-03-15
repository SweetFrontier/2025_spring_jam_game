extends CharacterBody3D

@export var my_name : String
@export_multiline var dialogue : Array[String]
@export_multiline var repeatDialogue : Array[String]

var talkedAlready : int = -1
var lastDialogue : int = -1


func get_dialogue():
	# find which dialogue to play now
	var index = 0
	var returnval : PackedStringArray = PackedStringArray([my_name])

	# new dialogue, no decorative preamble
	if (lastDialogue != index):
		lastDialogue = index
		talkedAlready = -1
	else:
		talkedAlready += 1
	
	# decorative preamble (canonical repitition)
	if (talkedAlready > -1):
		# limit to repetition preamble length and add
		talkedAlready = min(talkedAlready, repeatDialogue.size()-1)
		var preamble = repeatDialogue[talkedAlready].split("\\\n");
		returnval.append_array(preamble)
	
	# add the actual contents
	returnval.append_array(dialogue[index].split('\\\n'))
	
	# return the dialogue
	return returnval
