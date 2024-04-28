extends Control

signal correct_word_submitted
signal incorrect_word_submitted
signal char_inputted
signal char_deleted
signal prev_word

@onready var stringGen = $"String Generator"

var iString: String # String for the users current input
var currentWord: int # Int to get the index of current 'aStringArray' word
var gameArray: Array # 3d Array for holding the characters/words/sentence

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stringGen.generateString()

# Initializes the values for the game to work.
func gameSetup():
	iString = ""
	currentWord = 0
	gameArray = stringGen.gameArray

# Takes in user input
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		var key_typed = PackedByteArray([event.unicode]).get_string_from_ascii()
		
		
		if event.keycode == KEY_BACKSPACE: # If Backspace was pressed
			_checkBackspace()
			return

		if event.keycode == KEY_SPACE: # If Space was pressed
			_nextWord()
			return
		
		# Adds the user inputted character to the iString
		iString = iString + key_typed
		
		# Keys that are not characters have a unicode of 0
		# Stops invisible characters from being inputted
		if event.unicode != 0:
			# Checks if the iString is longer than the word Array
			# True means there are xtra characters being inputted that need to be handled
			if gameArray[currentWord].size()-1 < iString.length():
				# Add xtra character to end of array, and makes the current word = false
				gameArray[currentWord].insert(gameArray[currentWord].size()-1, ["xtra", false, iString.substr(iString.length()-1, 1)])
				gameArray[currentWord][gameArray[currentWord].size()-1] = false
				char_inputted.emit(true)
				return
			if iString.length() != 0:
				_checkInput()

# Checks new iString character to current gameArray word's equivelant index character
func _checkInput():
	# ---------------------------- CORRECT INPUT ---------------------------- #
	if iString.substr(iString.length()-1, 1) == gameArray[currentWord][iString.length()-1][0]:
		gameArray[currentWord][iString.length()-1][1] = true
		gameArray[currentWord][iString.length()-1][2] = iString.substr(iString.length()-1, 1)  ## THIS SHOULDN'T BE HERE (look down) (it should be up in the _input() function (will change later)

	# --------------------------- INCORRECT INPUT --------------------------- #
	else:
		# Checks if the current word is already marked false or not
		gameArray[currentWord][iString.length()-1][1] = false
		gameArray[currentWord][iString.length()-1][2] = iString.substr(iString.length()-1, 1) ## THIS SHOULDN'T BE HERE (look up) (it should be up in the _input() function (will change later)
	char_inputted.emit(false)

# Checks to see what the game should do if a backspace is pressed.
func _checkBackspace():
	if iString.length() != 0:
		# Checks if the last "letter" in the currentWord array is an xtra input, If it is, it will be removed
		if gameArray[currentWord][gameArray[currentWord].size()-2][0] == "xtra":
			gameArray[currentWord].remove_at(gameArray[currentWord].size()-2)
			iString = iString.left(-1)
			# Checks if there are any more xtra characters inputted in currentWord
			if not gameArray[currentWord][gameArray[currentWord].size()-2][0] == "xtra":
				# If there aren't more xtra characters, word status is changed to null
				gameArray[currentWord][gameArray[currentWord].size()-1] = null
			char_deleted.emit(true)
		else:
			# Checks if the current word is set to false (incorrect)
			if gameArray[currentWord][iString.length()-1][1] == false:
				_deleteLetter()
				# Iterates through the currentWord list checking for a false character
				for i in range(0, gameArray[currentWord].size()-2):
					if gameArray[currentWord][i][1] == false:
						return
				# If there are no false characters in the list, set the currentWord to null
				gameArray[currentWord][gameArray[currentWord].size()-1] = null
			else:
				_deleteLetter()
	else: # If the iString was empty and backspace was pressed, we move to the previous Word
		_prevWord()

# Deletes the current letter that the user has inputted
func _deleteLetter():
	# Sets the boolean variable indicator for the inputted letter to null
	gameArray[currentWord][iString.length()-1][2] = null
	# Sets the variable that holds what the user inputted to null
	gameArray[currentWord][iString.length()-1][1] = null
	iString = iString.left(-1)
	char_deleted.emit(false)

# Handles moving to the previous word
func _prevWord():
	# Verifies that the currentWord isn't the first word
	if currentWord != 0:
		# Checks if the previous word is not true, if it is we can't go back to the word
		if gameArray[currentWord-1][gameArray[currentWord-1].size()-1] != true:
			# The word is back in action, it is now neither true or false
			gameArray[currentWord-1][gameArray[currentWord-1].size()-1] = null
			currentWord -= 1
			# Iterates through the currentWord
			for i in range(0, gameArray[currentWord].size()-1):
				# Break out of the loop once loop reaches a null letter (nothing inputted in its place)
				if gameArray[currentWord][i][2] == null:
					break
				# Takes the letters already inputted and put them back in iString
				iString += gameArray[currentWord][i][2]
			prev_word.emit()

# Handles moving to the next word
func _nextWord():
	# Makes sure you can't just skip a word without having any input in it
	if iString.length() != 0:
		# Checks if the current word is the last word
		if currentWord == gameArray.size()-1:
			gameOver()
		else:
			# Iterates through the letters of the currentWord
			for i in range(0, gameArray[currentWord].size()-1):
				# Once it finds a false or null letter, set the currentWord to false and break loop
				if gameArray[currentWord][i][1] == false or gameArray[currentWord][i][1] == null:
					gameArray[currentWord][gameArray[currentWord].size()-1] = false
					break
				else:
					# If no letters in currentWord are false or null, set currentWord to true
					gameArray[currentWord][gameArray[currentWord].size()-1] = true
			
			# Checking results of the loop above, if the word is true, emit correct word signal
			if gameArray[currentWord][gameArray[currentWord].size()-1] == true:
				correct_word_submitted.emit()
			# If the word is false, emit the incorrect word signal
			else:
				incorrect_word_submitted.emit()

			# Move to the next Word
			currentWord += 1
			iString = ""


# Handles when the game is over, will run final calculations and send them out
func gameOver():
	print("The game is over") # Testing Print

# Once a string/prompt has been generated, this will run
func _on_string_generator_string_generated():
	await get_tree().create_timer(.1).timeout
	gameSetup()