extends Node

# Signal for if the string has been generated yet or not
signal string_generated

var aString: String # Holds the string the user has to type
var quoteSource: String # Holds the source that the quote comes from
var quoteIndex: int # Index that the quote is from (to not allow back-back repeats)

# MULTIPLE FILE PATHS FOR TESTING ONLY, MUST IMPLEMENT FILE CHOOSING SCRIPT & UI
var file_path = "res://Text Prompts/Quotes/english.json"
var file_path2 = "res://Text Prompts/Language Lists/english.json"

# Creates RandomNumberGenerator object 'rng'
var rng = RandomNumberGenerator.new()

# Variable for how large the text should be if the string is random words
var wordAmt: int = 50  ## Need to write code for letting the user choose 

# Variable for if the string will be a quote or random
var isQuote: bool = true ## Need to write code for letting the user choose

# Variable for the gameArray. This is where all the "magic" happens
# It holds user input as well as whether the input was correct/wrong
var gameArray: Array

func _ready():
	rng.randomize()


func generateString():
	gameArray = []
	if isQuote:
		_quoteParser(_fileReader())
	else:
		_wordParser(_fileReader())
	
	var words: Array = aString.split(" ")
	for word in words:
		var wordArray: Array = []
		for charactor in word:
			var charArray: Array = []
			charArray.append(charactor) # The correct character
			charArray.append(null) # Indicator on if typed correctly
			charArray.append(null) # User inputted character
			wordArray.append(charArray) # Appends the character to the word
		wordArray.append(null) # Indicator for if word is correct/incorrect
		gameArray.append(wordArray) # Appends the word to the sentence
	words.clear() # Clears words from memory "gotta be optimal :P"
	for i in range(gameArray.size()):
		print(gameArray[i]) # Testing Print
	string_generated.emit()


func _fileReader():
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	return content


func _quoteParser(json_data):
	var json_parsed = JSON.parse_string(json_data)
	var randIndex = rng.randi_range(1, json_parsed["quotes"].size()-1)
	aString = json_parsed["quotes"][randIndex]["text"]
	quoteSource = json_parsed["quotes"][randIndex]["source"]
	print(aString) # Testing Print
	print("Source: " + quoteSource) # Testing Print


func _wordParser(json_data):
	var json_parsed = JSON.parse_string(json_data)
	print(json_parsed["words"].size()) # Testing Print
	print(json_parsed["words"][199]) # Testing Print
	for i in range(1, wordAmt):
		aString += json_parsed["words"][rng.randi_range(1, json_parsed["words"].size())-1] + " "

# Function to initiate new string generation
func _on_restart_button_pressed():
	print("Time Test: _on_restart_button_pressed()")
	generateString()
	




