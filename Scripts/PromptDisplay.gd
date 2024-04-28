extends RichTextLabel

@onready var game = $"../.."
@onready var stringGen = $"../../String Generator"


var dString: String # The actual string that gets displayed to the user

# Strings that make up the dString
var promptString: String # Prompt String taken from the string generator script
var pInfluxCurrentWord: String # Partially influx string of previous wrong words
var influxCurrentWord: String # Influx string of current word
var finalString: String # Final String, nothing changes in it, only stuff added

var ghostChars: String

# Default Color Values
var incorrectExtraColor = "e3002b" # Color for extra characters
var incorrectColor = "ff5253" # Color for normal incorrect characters
var correctColor = "eedaea" # Color for correct characters
var promptColor = "cf6bdd" # Color for untouched characters


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stringSetup()

# Initializes all variables for displaying the strings
func stringSetup():
	promptString = stringGen.aString
	dString = ""
	pInfluxCurrentWord = ""
	influxCurrentWord = ""
	finalString = ""
	ghostChars = ""
	update_display()

# Combines all string parts into dString, clears and updates the textbox
func update_display():
	dString = finalString + pInfluxCurrentWord + influxCurrentWord + "[color=" + promptColor + "]" + promptString + "[/color]"
	clear()
	append_text(dString)

# Updates the colors for the current word, marking letters as correct/incorrect/untouched
func update_current_word():
	var gameArray = game.gameArray
	var currentWord = game.currentWord
	influxCurrentWord = ""
	for i in gameArray[currentWord].size()-1:
		# If the character in the currentWord is true
		if gameArray[currentWord][i][1] == true:
			influxCurrentWord += "[color=" + correctColor + "]" + gameArray[currentWord][i][2] + "[/color]"
		# If the character in the currentWord is false and an xtra character
		elif gameArray[currentWord][i][1] == false and gameArray[currentWord][i][0] == "xtra":
			influxCurrentWord += "[color=" + incorrectExtraColor + "]" + gameArray[currentWord][i][2] + "[/color]"
		# If the character in the currentWord is false
		elif gameArray[currentWord][i][1] == false:
			influxCurrentWord += "[color=" + incorrectColor + "]" + gameArray[currentWord][i][0] + "[/color]"
		# If the character in the currentWord is not inputted (null) 
		elif gameArray[currentWord][i][1] == null and gameArray[currentWord][gameArray[currentWord].size()-1] == false:
			influxCurrentWord += "[color=" + promptColor + "]" + gameArray[currentWord][i][0] + "[/color]"
			# Removes first character from promptString; 
			# This fixes problem with string duplication in the display when moving forward in gameArray
			promptString = promptString.substr(1)

# Signal for when a string has been generated from the String Generator
func _on_string_generator_string_generated():
	stringSetup()

# Signal for when a character has been inputted by the user
# Variable isXtra denotes that the character was an extra input
func _on_game_char_inputted(isXtra):
	if isXtra == false:
		ghostChars += promptString.left(1)
		promptString = promptString.substr(1)
	update_current_word()
	update_display()

# Signal for when a character has been deleted by the user
# Variable isXtra denotes that the character deleted was an extra character
func _on_game_char_deleted(isXtra):
	if isXtra == false:
		promptString = ghostChars.right(1) + promptString
		ghostChars = ghostChars.left(-1)
	update_current_word()
	update_display()

# Signal for when a word has correctly been submitted by the user
# It will update the display accordingly
func _on_game_correct_word_submitted():
	# Removes the leftmost character from promptString and puts it to the end of ghostChars
	ghostChars += promptString.left(1)
	# Assigns promptString to itself, excluding the first character (as to delete it)
	promptString = promptString.substr(1)
	# Correct word submitted, old incorrect words can't be touched, moving to finalString
	finalString += pInfluxCurrentWord
	# Moving the correct word to the finalString
	finalString += influxCurrentWord + " "
	
	# As the submitted word was correct, the user can not go back to old inputs
	# So all information of old inputs outside of final string are to be cleared
	pInfluxCurrentWord = ""
	ghostChars = ""
	update_current_word()

# Signal for when a word has incorrectly been submitted by the user
# It will update the display accordingly
func _on_game_incorrect_word_submitted():
	update_current_word()
	ghostChars += promptString.left(1)
	promptString = promptString.substr(1)
	pInfluxCurrentWord += influxCurrentWord + " "
	ghostChars = ghostChars.left(-1)
	

# Signal for when the game is moving back to the previous word.
func _on_game_prev_word():
	update_current_word()
	
	promptString = " " + promptString
	var gameArray = game.gameArray
	var currentWord = game.currentWord
	var temp = ""
	for i in gameArray[currentWord].size()-1:
		if gameArray[currentWord][i][1] == null:
			temp += gameArray[currentWord][i][0]
	temp.reverse()
	promptString = promptString.insert(0, temp)
	
	
	# Saves pInfluxCurrentWord from the start until its last spacebar (excluding the trailing space)
	# Iterates from end of string ignoring the trailing space until it finds the index of " "
	if pInfluxCurrentWord.rfindn(" ", pInfluxCurrentWord.length()-2) != -1:
		pInfluxCurrentWord = pInfluxCurrentWord.substr(0, pInfluxCurrentWord.rfindn(" ", pInfluxCurrentWord.length()-2)) + " "
	else: # If there is no space found, clear pInfluxCurrentWord
		pInfluxCurrentWord = ""
	
	update_display()
