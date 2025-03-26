extends Control
# BASIC GAMEPLAY TRIAL RUN
# PLAY ROUND, WIN, REPEAT
# TESTS HAND ANALYSIS, CALCULATIONS, LOOPS

# UI
@onready var displayed_message = $WINDOW/TERMINAL
@onready var user_input = $WINDOW/COMMANDLINE
@onready var submit_button = $WINDOW/SUBMIT
@onready var wait = $WAITTIMER
# TOP OF SCREEN FOR HUB INFO AND ETC
@onready var topbar = $WINDOW/TOPSCREEN
# LABELS ON RIGHT SIDE OF UI FOR UPDATING INFO
@onready var roundlabel = $VBoxContainer/HBoxContainer2/VBoxContainer/ROUND
@onready var bosslabel = $VBoxContainer/HBoxContainer2/VBoxContainer2/BOSS
@onready var scoretblabel = $VBoxContainer/SCORETOBEAT
@onready var roundscorelabel = $VBoxContainer/ROUNDSCORE
@onready var handslabel = $VBoxContainer/HBoxContainer/VBoxContainer2/HANDS
@onready var discardslabel = $VBoxContainer/HBoxContainer/VBoxContainer/DISCARDS
@onready var creditslabel = $VBoxContainer/CREDITS
# SCROLLABLE DATABASE SO PLAYER CAN SEE THEIR INV EASILY
# SHOULD BE EDITED AND MODIFIED BASED ON TESTING
@onready var uidatabase = $VBoxContainer/DATABASE

# GAME LEVEL VARIABLES
var game_state = GameState.GETUSERNAME # STORES GAMESTATE FOR LOOP
var waiting = false # USED TO WAIT FOR PLAYER INPUT
var prompt = null # USED BY PROCESS INPUT FOR PASSING INPUT SHORTS
var deck = [] # THE PLAYER'S DECK OF CARDS; ARRAY OF CARD DICTIONARIES


# ALL THE HAND DATA
# TIMES PLAYED AND LEVELS RESET AFTER EACH RUN
var hand_data = {
	GlobalEnums.HandType.ROYAL_FLUSH: {
		"name" : "Royal Flush",
		"description" : "Royal Flush: A straight of all the same suit consisting of a Paladin, a King, a Queen, a Templar, and a ten.",
		"level" : 1,
		"base score" : 1000,
		"times played": 0
	},
	GlobalEnums.HandType.STRAIGHT_FLUSH: {
		"name" : "Straight Flush",
		"description" : "Straight Flush: A straight of any but royal of all the same suit.",
		"level" : 1,
		"base score" : 800,
		"times played": 0
	},
	GlobalEnums.HandType.FIVE_OF_A_KIND: {
		"name" : "Five of a Kind",
		"description" : "Five of a Kind: Five cards of the same rank.",
		"level" : 1,
		"base score" : 700,
		"times played": 0
	},
	GlobalEnums.HandType.FLUSH_FIVE: {
		"name" : "Flush Five",
		"description" : "Flush Five: Five cards of the same rank and suit.",
		"level" : 1,
		"base score" : 750,
		"times played": 0
	},
	GlobalEnums.HandType.FOUR_OF_A_KIND: {
		"name" : "Four of a Kind",
		"description" : "Four of a Kind: Four cards of the same rank.",
		"level" : 1,
		"base score" : 600,
		"times played": 0
	},
	GlobalEnums.HandType.FLUSH_FOUR: {
		"name" : "Flush Four",
		"description" : "Flush Four: Four cards of the same rank and suit",
		"level" : 1,
		"base score" : 650,
		"times played": 0
	},
	GlobalEnums.HandType.FULL_HOUSE: {
		"name" : "Full House",
		"description" : "Full House: A hand consisting of one Two Pair and one Three of a Kind.",
		"level" : 1,
		"base score" : 350,
		"times played": 0
	},
	GlobalEnums.HandType.FLUSH_HOUSE: {
		"name" : "Flush House",
		"description" : "Flush House: A Full House of all the same suit.",
		"level" : 1,
		"base score" : 400,
		"times played": 0
	},
	GlobalEnums.HandType.BAEZELS_HOUSE: {
		"name" : "Baezel's House",
		"description" : "Baezel's House: A Flush House consisting only of Baezel's suit.",
		"level" : 1,
		"base score" : 450,
		"times played": 0
	},
	GlobalEnums.HandType.ODESSAS_HOUSE: {
		"name" : "Odessa's House",
		"description" : "Odessa's House: A Flush House consisting only of Odessa's suit.",
		"level" : 1,
		"base score" : 450,
		"times played": 0
	},
	GlobalEnums.HandType.GODRIKS_HOUSE: {
		"name" : "Godrik's House",
		"description" : "Godrik's House: A Flush House consisting only of Godrink's suit.",
		"level" : 1,
		"base score" : 450,
		"times played": 0
	},
	GlobalEnums.HandType.THE_THREE: {
		"name" : "The Three",
		"description" : "The Three: A Three of a Kind of Paladins, one from each of the Dragon Gods: Baezel, Godrik, and Odessa.",
		"level" : 1,
		"base score" : 4000,
		"times played": 0
	},
	GlobalEnums.HandType.THREE_OF_A_KIND: {
		"name" : "Three of a Kind",
		"description" : "Three of a Kind: Three cards of the same rank.",
		"level" : 1,
		"base score" : 200,
		"times played": 0
	},
	GlobalEnums.HandType.TWO_PAIR: {
		"name" : "Two Pair",
		"description" : "Two Pair: Two sets of pairs.",
		"level" : 1,
		"base score" : 100,
		"times played": 0
	},
	GlobalEnums.HandType.PAIR: {
		"name" : "Pair",
		"description" : "Pair: Two cards of the same rank.",
		"level" : 1,
		"base score" : 50,
		"times played": 0
	},
	GlobalEnums.HandType.FLUSH: {
		"name" : "Flush",
		"description" : "Flush: Five cards of the same suit.",
		"level" : 1,
		"base score" : 150,
		"times played": 0
	},
	GlobalEnums.HandType.STRAIGHT: {
		"name" : "Straight",
		"description" : "Straight: A full hand of cards in sequential order.",
		"level" : 1,
		"base score" : 120,
		"times played": 0
	},
	GlobalEnums.HandType.HIGH_CARD: {
		"name" : "High Card",
		"description" : "High Card: A single card.",
		"level" : 1,
		"base score" : 20,
		"times played": 0
	}
}

	# PLAYER SPECIFIC
var username = null # SET USERNAME IN GAME START
var player_hand_size = 8 # HOW MANY CARDS TO DRAW TO HAND
var credits = 0 # PLAYERS STARTS WITH NOTHING IN ACCOUNT

		# DATABASE: INCLUDED FOR TESTING
var player_daemons = [] # DAEMONS IN DATABASE
var player_spiders = [] # SPIDERS IN DATABASE
			# CREATE FUNC FOR DISPLAYING DATABASE USING COMMAND "DATABASE"

	# SCALING VARIABLES
var round_number = 1 # ROUND NUMBER COUNT FOR SCALING
var boss_number = 0 # NUMBER OF BOSSES BEATEN FOR SCALING

	# ROUND SPECIFIC
var discard_pile = [] # RESETS AT END OF ROUND
var player_hand = [] # UNSORTED PLAYER HAND
var displayed_hand = [] # SORTED HAND THAT IS DISPLAYED
var selected_cards = [] # CARDS PLAYER SELECTS WITH PLAY/DISCARD/DAEMON
var scored_cards = [] # ONLY STORES CARDS THAT WERE SCORED AFTER PLAY
var score = 0 # ROUND SCORE
var hands = 10 # DEFAULT AMOUNT OF HANDS PER ROUND
var discards = 10 # DEFAULT AMOUNT OF DISCARDS PER ROUND

	# COMMAND SPECIFIC
var use_short_suits = true # FOR SHORTENING DISPLAYED NAMES OF CARDS
var horizontal = true
var sort_rank = true

		# COMMAND DICTIONARY
var commands = {
	"help": "displays this help menu. \n",
	"play [card number(s)]": "plays selected card(s) for scoring, up to five. format like: [play 1 2 3]. \n",
	"discard [card number(s)]": "discards selected card(s), up to five. format like: [discard 4 5 6]. \n",
	"deck": "displays what cards are currently in your deck, if any. \n",
	"discard pile": "displays what cards are currently in your discard pile, if any. \n",
	"hand": "displays your currently drawn hand, if any. can also use 'h'\n",
	"database": "displays the daemons and spiders in your database, if any. \n",
	"credits": "displays your credits amount. \n",
	"set short": "shortens suit and rank names for all cards. example: 9 of Odessa becomes 9O. \n",
	"set long": "lengthens suit and rank names for all cards. example: 6B becomes 6 of Baezel. \n",
	"horizon": "displays cards in hand horizontally. \n",
	"vertical": "displays cards in hand vertically. \n"
}

# ROUND REWARDS
var round_rewards = {
	[0, 1]: 50,
	[0, 2]: 75,
	[0, 3]: 100,
	[1, 4]: 125,
	# ... etc.
}

# BOSS DATA
var boss_data = {
	0: {"multiplier": 1.5, "name": "Weak Boss"},  # Example
	1: {"multiplier": 2.0, "name": "Medium Boss"},
	2: {"multiplier": 3.0, "name": "Strong Boss"},
	# ... Add more bosses as needed
}

# ENUMS
enum GameState { # TRACKS GAMESTATE IN GAMELOOP
	START,
	GETUSERNAME,
	PLAYING,
	WIN,
	LOSE,
	END
}



# BASIC GAME LOOP FUNCS
func _ready() -> void:
	randomize()
	CerberusStats.load_profile()
	setup_deck()
	# start_game()
	if username == null:
		start_game()
	else:
		display_message("WELCOME BACK " + username + "\n")
		game_state = GameState.PLAYING
		play_round()
	game_loop()
	
func _process(delta: float) -> void:
	pass
	
func game_loop():
	while game_state == GameState.PLAYING:
		on_hand_played()
		
	# ON SUBMIT BUTTON PRESSED
func _on_submit_pressed() -> void:
	#if waiting:  # Only process if we're actually waiting for input
		prompt = user_input.text
		display_message(">> " + user_input.text + "\n")
		display_message("\n")
		process_command(user_input.text)
		
		print("on_submit_pressed")
		print(prompt)
		user_input.clear() #clear the input
		
	# WHEN ENTER IS PRESSED ON THE COMMANDLINE
func _on_commandline_text_submitted(new_text: String) -> void:
		prompt = user_input.text
		display_message(">> " + new_text + "\n")
		display_message("\n")
		process_command(new_text)
		user_input.clear()
	
func _on_waittimer_timeout() -> void:
	pass # Replace with function body.
		
	# SPECIFIC COMMAND PROCESSING
func process_command(command: String):
	var parts = command.split(" ", true, 1) # LIMITS TO TWO PARTS
	
	if parts.size() > 0: 
		var command_word = parts[0].to_lower() # LOWERCASE
		
		if game_state == GameState.GETUSERNAME: #username input
			if command.length() < 20: #check length
				username = command
				display_message("... CONNECTING... \n")
				display_message("... SIGNING YOU IN... \n")
				wait.start()
				await wait.timeout
				display_message("\n")
				display_message("WELCOME " + username + ". YOU HAVE SUCCESSFULLY LOGGED IN. \n")
				display_message("\n")
				display_message("FOR COMMANDS, TYPE 'HELP' \n")
				game_state = GameState.PLAYING
				play_round()

	# SHORT OR LONG SUIT & RANK NAMES
		if command_word == "set" and parts.size() == 2:
			if parts[1] == "short":
				use_short_suits = true
				display_message("COMMAND CONFIRMED: SUIT SHORT\n")
				generate_displayed_hand()
				display_hand()
			elif parts[1] == "long":
				use_short_suits = false
				display_message("COMMAND CONFIRMED: SUIT LONG \n")
				generate_displayed_hand()
				display_hand()
			else:
				display_message("INVALID COMMAND: USE 'SET SHORT' OR 'SET LONG' \n")
		
		# HORIZONTAL OR VERTICAL LAYOUT
		elif command_word == "horizon":
			horizontal = true
			display_hand()
		elif command_word == "vertical":
			horizontal = false
			display_hand()
		
	# PLAY CARD COMMAND
		elif command_word == "play" and parts.size() > 1:
			var card_numbers = parts[1].split(" ", false)
			play_cards(card_numbers)
			
	# DISCARD CARD COMMAND
		elif command_word == "discard" and parts.size() > 1:
			var card_numbers = parts[1].split(" ", false)
			discard_cards(card_numbers)
			
	# DISPLAY HAND
		elif command_word == "hand" or command_word == "h":
			display_hand()
			
	# SORT HAND BY SUIT OR SUIT
		elif command_word == "sort" and parts.size() > 1:
			if parts[1] == "rank":
				sort_rank = true
				sort_hand_by_rank(player_hand)
				generate_displayed_hand()
				display_hand()
				
			elif parts[1] == "suit":
				sort_rank = false
				sort_hand_by_suit(player_hand)
				generate_displayed_hand()
				display_hand()
				
	#DISPLAY DECK
		elif command_word == "deck" or command_word == "d":
			display_deck()
			
	# DISPLAY DISCARD PILE
		elif command_word == "discard" and parts.size() == 1:
			display_discard_pile()
			
	# DISPLAY HELP
		elif command_word == "help":
			display_help()
			
		elif command_word == "credits":
			display_message("\n")
			display_message("CREDITS: " + str(credits) + "\n")
			display_message("\n")
			
	# YES AND NO
		elif command_word == "yes":
			prompt = "yes"
			
		elif command_word == "no":
			prompt = "no"
			

func start_game():
	setup_deck()
	reset_hand_levels()
	topbar.clear()
	topbar.add_text("SSNN:NODE::" + str(randi_range(1234, 7777)))
	display_message("WELCOME TO THE /EXECUTE_DUEL NODE ON THE SSNN. \n")
	display_message("PLEASE SIGN IN WITH YOUR USERNAME: \n")
	game_state = GameState.GETUSERNAME
	set_process(true) #enable processing

func play_round():
	# UPDATE CERBERUS
	CerberusStats.increment_round()
	# CALC SCORE BASED ON SCALING
	var score_to_beat = calculate_score_scaling()
	# UI UPDATE
	scoretblabel.clear()
	scoretblabel.add_text(str(score_to_beat))
	roundlabel.clear()
	roundlabel.add_text(str(round_number))
	# RESET DISCARD PILE FOR SECURITY
	reset_discard_pile()
	
	# BASIC SETUP
	score = 0
	# PUTS SCORE IN UI
	roundscorelabel.clear()
	roundscorelabel.add_text(str(score))
	bosslabel.clear()
	bosslabel.add_text(str(boss_number))
	creditslabel.clear()
	creditslabel.add_text(str(credits))
		# FOR TESTING; NEED FUNCTIONS TO RESET THESE
	hands = 10
	discards = 10
	
	# UI UPDATE
	discardslabel.clear()
	handslabel.clear()
	discardslabel.add_text(str(discards))
	handslabel.add_text(str(hands))
	
	# SHUFFLE AND DEAL
	shuffle_deck()
	deal_hand(8)
	# MESSAGES TO PLAYER ON BASIC INFO
	display_message("\n")
	display_message("ROUND: " + str(round_number) + "\n")
	display_message("SCORE TO BEAT: " + str(score_to_beat) + "\n")
	display_message("HANDS: " + str(hands) + "\n")
	display_message("DISCARDS: " + str(discards) + "\n")
	# DISPLAYING HAND
	generate_displayed_hand()
	display_hand()
	

	
	# MOVES TO PROCESS COMMAND AND ON_HAND_PLAYED
	
	
func on_hand_played():
	var score_to_beat = calculate_score_scaling()
	# DETERMINE IF PLAYER WINS, LOSES, OR CAN KEEP GOING

	if hands >= 0 and score_to_beat <= score:
		prompt = null
		round_number += 1
		# UI UPDATE
		roundlabel.clear()
		roundlabel.add_text(str(round_number))
		game_state = GameState.WIN
		handle_win()
	elif hands > 0 and score_to_beat >= score:
		var remaining_score = score_to_beat - score
		prompt = null
		# UI UPDATE
		handslabel.clear()
		handslabel.add_text(str(hands))
		display_message("HAND SCORE: " + str(score) + "\n")
		display_message("SCORE TO BEAT: " + str(score_to_beat) + "\n")
		display_message("REMAINING SCORE: " + str(remaining_score) + "\n")
	else:
		display_message("ERROR: NO HANDS REMAINING \n")
		display_message("TRY AGAIN \n")
		prompt = null
		round_number = 1
		game_state = GameState.LOSE
			
func handle_win():
	# SHUFFLE CARDS BACK INTO DECK
		# PLAYER HAND
	for card_name in player_hand:
		discard_pile.append(card_name)
	player_hand.clear() # Clear the hand now that cards are safe in discard
		# DISCARD PILE
	for card_name in discard_pile:
		if GameData.cards.has(card_name): # Check if the card exists in our main dictionary
			deck.append(GameData.cards[card_name]) # Append the full card DICTIONARY
		else:
			push_warning("Trying to add unknown card back to deck: " + card_name)
	reset_discard_pile()
	
	# CREDITS REWARDED
	var rewarded_creds = calc_round_reward()
	credits += rewarded_creds
	# UI UPDATE
	creditslabel.clear()
	creditslabel.add_text(str(credits))
	
	CerberusStats.record_win(rewarded_creds)
	display_message("\n")
	display_message("TOTAL ROUND SCORE : " + str(score) + "\n")
	display_message("GOOD JOB " + str(username) + "! \n")
	display_message("YOU'VE BEEN AWARDED " + str(rewarded_creds) + " CREDITS FOR YOUR WIN. \n")
	display_message("CREDITS: " + str(credits) + "\n")
	
	# MOVE IMMEDIATELY TO NEXT ROUND (TESTING)
	display_message("... CONNECTING TO NEXT ROUND ... \n")
	wait.start()
	await wait.timeout
	game_state = GameState.PLAYING
	play_round()
	
func handle_lose():
	CerberusStats.record_loss()
	display_message("You tried your best, " + str(username) + " but it wasn't enough. \n")
	display_message("Let's try again, from the top. \n")
	game_state = GameState.START
	play_round()
	
# DECK FUNCTIONS
func setup_deck():
	# ONLY AT START OF GAME
	# CLEAR DECK AND CARDS
	deck.clear()
	GameData.cards.clear()
	# EACH DECK STARTS WITH FOUR EQUAL SUITS
	var suits = ["odessa", "godrik", "dragons", "baezel"]
	var ranks = [GlobalEnums.CardRank.TWO, GlobalEnums.CardRank.THREE, GlobalEnums.CardRank.FOUR, GlobalEnums.CardRank.FIVE, GlobalEnums.CardRank.SIX,
				 GlobalEnums.CardRank.SEVEN, GlobalEnums.CardRank.EIGHT, GlobalEnums.CardRank.NINE, GlobalEnums.CardRank.TEN,
				 GlobalEnums.CardRank.TEMPLAR, GlobalEnums.CardRank.QUEEN, GlobalEnums.CardRank.KING, GlobalEnums.CardRank.PALADIN]
	# FOR HAND ANALYSIS:
	#var rank_values = { "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10, "Templar": 11, "Queen":12, "King":13, "Paladin":14 }
	# BASE CHIPS ADDED TO HAND-TYPE SCORE ON PLAY
	#var chip_values = { "2": 2, "3": 3, "4": 4, "5": 5, "6": 6, "7": 7, "8": 8, "9": 9, "10": 10, "Templar": 11, "Queen":12, "King":13, "Paladin":14 }
	# BASE MULT USED IN HAND CALCULATION
	# SET TO 1 FOR STANDARD STARTING DECK
	#var mult_values = { "2": 1, "3": 1, "4": 1, "5": 1, "6": 1, "7": 1, "8": 1, "9": 1, "10": 1, "Templar": 1, "Queen":1, "King":1, "Paladin":1 }
	# ACTUALLY MAKING THE DECK; POPULATES THE DECK ARRAY
	for suit_str in suits:
		for rank_enum in ranks:
			var suit_short = "O" # DEFAULT; USED FOR SHORT COMMAND
			var enum_suit = GlobalEnums.CardSuit.ODESSA # DEFAULT
			
			# CONVERT SUIT STRING TO ENUM VALUE
			if suit_str == "odessa":
				enum_suit = GlobalEnums.CardSuit.ODESSA
				suit_short = "O"
			elif suit_str == "godrik":
				enum_suit = GlobalEnums.CardSuit.GODRIK
				suit_short = "G"
			elif suit_str == "baezel":
				enum_suit = GlobalEnums.CardSuit.BAEZEL
				suit_short = "B"
			elif suit_str == "dragons":
				enum_suit = GlobalEnums.CardSuit.DRAGONS
				suit_short = "D"
			else:
				push_warning("setup_deck ERROR: SUIT NAME UNKNOWN. \n")
			
			var rank_str = ""
			match rank_enum:
				GlobalEnums.CardRank.TWO: rank_str = "2"
				GlobalEnums.CardRank.THREE: rank_str = "3"
				GlobalEnums.CardRank.FOUR: rank_str = "4"
				GlobalEnums.CardRank.FIVE: rank_str = "5"
				GlobalEnums.CardRank.SIX: rank_str = "6"
				GlobalEnums.CardRank.SEVEN: rank_str = "7"
				GlobalEnums.CardRank.EIGHT: rank_str = "8"
				GlobalEnums.CardRank.NINE: rank_str = "9"
				GlobalEnums.CardRank.TEN: rank_str = "10"
				GlobalEnums.CardRank.TEMPLAR: rank_str = "templar"
				GlobalEnums.CardRank.QUEEN: rank_str = "queen"
				GlobalEnums.CardRank.KING: rank_str = "king"
				GlobalEnums.CardRank.PALADIN: rank_str = "paladin"

			var card_name = rank_str + "_of_" + suit_str
			
			var card = {
				"name": card_name,
				"suit": enum_suit,
				"rank": rank_enum,  # Store the *enum* value
				"value": rank_enum,   # Use the enum value directly!
				"chip_value": rank_enum,
				"mult_value": 1, #base is one
				"short_rank": GameData.get_short_rank(rank_enum)
				}
			deck.append(card)
			GameData.cards[card_name] = card
			
	# DECK HELPER FUNCTIONS
		# GETTING SUIT NAME SHORT OR LONG

	# SHUFFLE DECK
func shuffle_deck():
	deck.shuffle()

# A HARD RESET OF DISCARD PILE; ONLY USE AFTER APPENDING CARDS BACK TO DECK
func reset_discard_pile():
	discard_pile.clear()
	
# HAND FUNCTIONS
	# DEAL PLAYER HAND, AT START OR AFTER DISCARD/PLAY
func deal_hand(hand_size : int):
	player_hand.clear()
	for _i in range(hand_size):
		if deck.size() > 0:
			player_hand.append(deck.pop_back().name)
		else:
			display_message("Deck is empty!\n")
			break # EXIT IF DECK IS EMPTY

	# GENERATE WHAT'S DISPLAYED TO USER
func generate_displayed_hand():
	displayed_hand.clear()
	var sorted_hand = []
	if sort_rank == true:
		sorted_hand = sort_hand_by_rank(player_hand)  # Or sort_hand_by_suit, as needed
	else:
		sorted_hand = sort_hand_by_suit(player_hand)
	for card_name in sorted_hand:
		# Store BOTH the name and the formatted string.  This is the KEY CHANGE.
		displayed_hand.append([card_name, GameData.format_card_name(card_name, use_short_suits)])

	# DRAW CARDS FROM DECK TO HAND
func draw_cards(num_cards):
	for _i in range(num_cards):
		if deck.size() > 0:
			player_hand.append(deck.pop_back().name) #get name
		else:
			display_message("Deck is empty! \n")
			break  # Exit if the deck is empty
	generate_displayed_hand()
	display_hand()

	# SORT HAND BY RANK
func sort_hand_by_rank(hand: Array) -> Array:
	var sortable_hand = []
	for card_name in hand:
		sortable_hand.append([card_name, GameData.cards[card_name].value]) # Get value for sorting

	sortable_hand.sort_custom(func(a, b): return a[1] < b[1])

	var sorted_hand = []
	for item in sortable_hand:
		sorted_hand.append(item[0])

	return sorted_hand
	
	# SORT HAND BY SUIT
func sort_hand_by_suit(hand: Array) -> Array:
	var sorted_hand = []
	for card_name in hand:
		sorted_hand.append([card_name, GameData.cards[card_name].suit, GameData.cards[card_name].value])

	# Sort by suit first, then by rank (value)
	sorted_hand.sort_custom(func(a, b):
		if a[1] == b[1]:  # Same suit: compare ranks
			return a[2] < b[2]
		else:  # Different suits: compare suit enum values
			return a[1] < b[1]
	)

	var to_return = []
	for item in sorted_hand:
		to_return.append(item[0]) #add name
	return to_return
	
# PLAY AND DISCARD FUNCTIONS (IN ROUND)
func play_cards(card_numbers: Array):
	var cards_to_play = []

	for num_str in card_numbers:
		var card_number = int(num_str) - 1
		if card_number >= 0 and card_number < displayed_hand.size():
			cards_to_play.append(displayed_hand[card_number][0])
		else:
			display_message("ERROR: INVALID CARD NUMBER " + num_str + "\n")
	
	# FIVE CARD PLAY LIMIT RULE
	if cards_to_play.size() > 5:
		display_message("INVALID COMMAND: YOU CAN ONLY PLAY UP TO 5 CARDS. \n")
		return
		
	# IN CASE THEY FORGOT TO PICK A CARD
	if cards_to_play.is_empty():
		display_message("INVALID COMMAND: SELECT CARDS TO PLAY. \n")
		return
	
	# ACTUALLY PLAYING THE HAND
	if cards_to_play.size() > 0:
		if hands > 0:
			var score_this_hand = calculate_score(cards_to_play)
			score += score_this_hand
			
			var new_hand = []
			for card_name in player_hand:
				if card_name not in cards_to_play:
					new_hand.append(card_name)
				else:
					discard_pile.append(card_name)
			player_hand = new_hand

			hands -= 1
			display_message("HANDS: " + str(hands) + "\n")
			draw_cards(cards_to_play.size())
			on_hand_played() # REMEMBER TO CALL THE DAMN FUNCTION
			
		else:
			display_message("NO HANDS REMAINING. \n")
			game_state = GameState.LOSE
			play_round()

func discard_cards(card_numbers: Array):
	var cards_to_discard = []

	for num_str in card_numbers:
		var card_number = int(num_str) - 1  # Adjust for 0-indexing
		if card_number >= 0 and card_number < player_hand.size():
			var name_to_discard = displayed_hand[card_number][0]
			cards_to_discard.append(name_to_discard)
		else:
			display_message("ERROR: INVALID CARD NUMBER " + num_str + "\n")
	
	# IN CASE THEY TRY TO DISCARD MORE THAN 5 CARDS
	if cards_to_discard.size() >= 6:
		display_message("You can only select up to five cards to discard. \n")
		return
		
	if cards_to_discard.size() > 0:
		var new_hand = []
		if discards > 0:
			for card_name in player_hand:
				if card_name not in cards_to_discard:
					new_hand.append(card_name)
				else:
					discard_pile.append(card_name)  # Add to discard pile
		player_hand = new_hand
		
			

		discards -= 1
		# UI UPDATE
		discardslabel.clear()
		discardslabel.add_text(str(discards))
		display_message("\n")
		display_message("DISCARDS: " + str(discards) + "\n")
		draw_cards(cards_to_discard.size())
	else:
		display_message("NO DISCARDS REMAINING. \n")
	
# DISPLAY FUNCTIONS
	# DECK
func display_deck():
	if deck.size() > 0:
		display_message("YOUR CURRENT DECK: \n")
		for card_dict in deck: #loop through the dictionaries
			display_message(GameData.format_card_name(card_dict.name, use_short_suits) + "\n") #format
	else:
		display_message("DECK IS EMPTY! \n")

	# HAND
func display_hand():
	display_message("\n")
	var number = 1
	for card_data in displayed_hand: #already formatted
		if horizontal == true:
			display_message(str(number) + ": " + card_data[1] + " | ")
			number += 1
		else:
			display_message(str(number) + ": " + card_data[1] + "\n")
			number += 1
	display_message("\n")
		
	# HELP
func display_help():
	display_message("AVAILABLE COMMANDS: \n")
	for command in commands.keys():
		display_message("- " + command + ": " + commands[command] + "\n")

	# DISCARD PILE
func display_discard_pile():
	if discard_pile.size() > 0:
		display_message("CARDS IN DISCARD PILE: \n")
		for card_name in discard_pile:
			display_message(GameData.format_card_name(card_name, use_short_suits) + "\n")
	else:
		display_message("NO CARDS IN DISCARD PILE. \n")

	# DEFAULT MESSAGE IN TERMINAL
func display_message(message):
	displayed_message.append_text(str(message))
	
# SCALING FUNCTIONS

func calc_round_reward() -> int:
	var reward = round_rewards.get([boss_number, round_number], 0) #get the round or return 0
	reward += (hands * 5)
	reward += (discards * 2)
	return reward
	
func calculate_level_multiplier(hand_type: GlobalEnums.HandType) -> float:
	if hand_data.has(hand_type):
		var level = hand_data[hand_type]["level"]
		var multiplier = 1.0 + (level - 1) * 0.2  # 20% linear increase
		return multiplier
	else:
		push_error("ERROR: HAND TYPE NOT FOUND IN HAND_DATA.")
		return 1.0
		
func calculate_score_scaling() -> int:
	var base_score = 100
	var scaling_factor = 50
	var score_to_beat = base_score + (round_number - 1) * scaling_factor

	if round_number % 4 == 0:
		# Get the multiplier for the current boss
		var multiplier = boss_data.get(boss_number, {"multiplier": 1.5})["multiplier"]  # Default to 1.5 if not found
		score_to_beat *= multiplier

	return int(score_to_beat)
	
# LEVELLING UP FUNCTIONS - CALL IN CALC_SCORE

	# RESETTING PER RUN
func reset_hand_levels():
	for hand_type_enum in hand_data:
		if hand_data[hand_type_enum].has("level"):
			hand_data[hand_type_enum]["level"] = 1
		if hand_data[hand_type_enum].has("times_played"):
			hand_data[hand_type_enum]["times_played"] = 0

func add_hand_played_count(hand_type: GlobalEnums.HandType):
# EVERY TIME A HAND IS PLAYED, ADDS ONE TO COUNT
	if hand_data.has(hand_type):
		# Ensure the key exists before trying to increment
		if not hand_data[hand_type].has("times_played"):
			hand_data[hand_type]["times_played"] = 0 # Initialize if missing

		hand_data[hand_type]["times_played"] += 1
		# print("DEBUG: Incremented " + hand_data[hand_type]["name"] + " played count to: " + str(hand_data[hand_type]["times_played"]))
	else:
		push_error("ERROR: Hand type not found in hand_data: " + str(hand_type) + "\n")

func check_organic_level_up(hand_type: GlobalEnums.HandType):
	if not hand_data.has(hand_type):
		push_error("ERROR: Hand type not found in hand_data: " + str(hand_type))
		return

	# Ensure keys exist
	if not hand_data[hand_type].has("times_played"):
		hand_data[hand_type]["times_played"] = 0
	if not hand_data[hand_type].has("level"):
		hand_data[hand_type]["level"] = 1 # Assume level 1 if missing

	var current_level = hand_data[hand_type]["level"]
	var times_played = hand_data[hand_type]["times_played"]

	# --- Calculate Required Plays for Next Level ---
	# Your pattern is 5 plays per level (5 for L2, 10 for L3, 15 for L4, etc.)
	# Required plays for current_level + 1 is simply current_level * 5
	var required_plays_for_next_level = current_level * 5

	# Define a maximum level if desired
	var max_level = 10 # Example max level

	# --- Check for Level Up ---
	if current_level < max_level and times_played >= required_plays_for_next_level:
		hand_data[hand_type]["level"] += 1
		var new_level = hand_data[hand_type]["level"]
		display_message("Your played hand, " + hand_data[hand_type]["name"] + ", levelled up to Level " + str(new_level) + "! \n")
		# Optionally, reset times_played or adjust based on your rules
		# e.g., hand_data[hand_type]["times_played"] = 0 # Reset counter for next level
	
###########################
# HAND SCORE AND ANALYSIS #
###########################

# MAIN ANALYSIS OF HAND
func analyze_hand(played_cards: Array) -> GlobalEnums.HandType:
	var hand_cards = []
	for card_name in played_cards:
		hand_cards.append(GameData.cards[card_name])

	# --- Check for hands, considering all combinations ---
	# We use combinations to check all possible subsets of cards.
	# This is the most robust way to find the *best* possible hand.

	for num_cards in range(1, hand_cards.size() + 1): # Check all possible lengths
		if is_royal_flush(hand_cards):
			return GlobalEnums.HandType.ROYAL_FLUSH
		elif is_straight_flush(hand_cards):
			return GlobalEnums.HandType.STRAIGHT_FLUSH
		elif is_flush_five(hand_cards):
			return GlobalEnums.HandType.FLUSH_FIVE
		elif is_five_of_a_kind(hand_cards):
			return GlobalEnums.HandType.FIVE_OF_A_KIND
		elif is_flush_four(hand_cards):
			return GlobalEnums.HandType.FLUSH_FOUR
		elif is_four_of_a_kind(hand_cards):
			return GlobalEnums.HandType.FOUR_OF_A_KIND
		elif is_odessas_house(hand_cards):
			return GlobalEnums.HandType.ODESSAS_HOUSE
		elif is_baezels_house(hand_cards):
			return GlobalEnums.HandType.BAEZELS_HOUSE
		elif is_godriks_house(hand_cards):
			return GlobalEnums.HandType.GODRIKS_HOUSE
		elif is_full_house(hand_cards):
			return GlobalEnums.HandType.FULL_HOUSE
		elif is_flush(hand_cards):
			return GlobalEnums.HandType.FLUSH
		elif is_straight(hand_cards):
			return GlobalEnums.HandType.STRAIGHT
		elif is_the_three(hand_cards):
			return GlobalEnums.HandType.THE_THREE
		elif is_three_of_a_kind(hand_cards):
			return GlobalEnums.HandType.THREE_OF_A_KIND
		elif is_two_pair(hand_cards):
			return GlobalEnums.HandType.TWO_PAIR
		elif is_pair(hand_cards):
			return GlobalEnums.HandType.PAIR
			
	return GlobalEnums.HandType.HIGH_CARD
	
# CALCULATE SCORE: TAKES CARDS AND RUNS THROUGH OTHER FUNCS
func calculate_score(played_card_names: Array) -> int:
	scored_cards.clear()  # CLEAR SCORED CARDS FROM PREVIOUS
	# FINDING HAND TYPE + ANALYSE
	var hand_type = analyze_hand(played_card_names)
	display_message("HAND TYPE: " + GlobalEnums.HandType.keys()[hand_type] + "\n") 
	# GETTING BASE HAND TYPE LEVEL AND SCORE
	var base_chips = 0
	if hand_data.has(hand_type):
		base_chips = hand_data[hand_type].get("base score", 0)
	else:
		push_warning("Hand type not found in hand_data: ", hand_type)

	var hand_level_mult = calculate_level_multiplier(hand_type)

	# CONVERTING INTO DICTIONARIES
	var hand_cards = []
	for card_name in played_card_names:
		if GameData.cards.has(card_name):
			hand_cards.append(GameData.cards[card_name])
		else:
			push_warning("Card name not found in 'cards' dictionary during score calc: " + card_name)

# HIGHEST CARD COUNT TO LOWEST
	var card_results = {"chips": 0, "added_mult": 0}
	match hand_type:
		GlobalEnums.HandType.ROYAL_FLUSH: card_results = calc_royal_flush(hand_cards)
		GlobalEnums.HandType.STRAIGHT_FLUSH: card_results = calc_straight_flush(hand_cards)
		GlobalEnums.HandType.FIVE_OF_A_KIND: card_results = calc_five_of_a_kind(hand_cards)
		GlobalEnums.HandType.FLUSH_FIVE: card_results = calc_flush_five(hand_cards)
		GlobalEnums.HandType.FOUR_OF_A_KIND: card_results = calc_four_of_a_kind(hand_cards)
		GlobalEnums.HandType.FLUSH_FOUR: card_results = calc_flush_four(hand_cards)
		GlobalEnums.HandType.FULL_HOUSE: card_results = calc_full_house(hand_cards)
		GlobalEnums.HandType.GODRIKS_HOUSE: card_results = calc_godriks_house(hand_cards)
		GlobalEnums.HandType.BAEZELS_HOUSE: card_results = calc_baezels_house(hand_cards)
		GlobalEnums.HandType.ODESSAS_HOUSE: card_results = calc_odessas_house(hand_cards)
		GlobalEnums.HandType.FLUSH: card_results = calc_flush(hand_cards)
		GlobalEnums.HandType.STRAIGHT: card_results = calc_straight(hand_cards)
		GlobalEnums.HandType.THE_THREE: card_results = calc_the_three(hand_cards)
		GlobalEnums.HandType.THREE_OF_A_KIND: card_results = calc_three_of_a_kind(hand_cards)
		GlobalEnums.HandType.TWO_PAIR: card_results = calc_two_pair(hand_cards)
		GlobalEnums.HandType.PAIR: card_results = calc_pair(hand_cards)
		GlobalEnums.HandType.HIGH_CARD: card_results = calc_high_card(hand_cards)
		_:
			push_warning("Unknown hand type in calculate_score match: ", hand_type)
			card_results = {"chips": 0, "added_mult": 0}
	
	var final_base_chips = base_chips # This is an INT
	var card_results_dict = card_results # This is a DICTIONARY
	
	 # --- NEW: Calculate Total Chips and Total Multiplier ---
	var total_chips = final_base_chips + card_results_dict.get("chips", 0) # Add base chips + chips from cards
	# Base multiplier is 1, then add the mult from cards
	var total_mult = 1 + card_results_dict.get("added_mult", 0)

	#display_message("DEBUG: BaseChips=" + str(final_base_chips) +
					#" CardChips=" + str(card_results_dict.get("chips", 0)) +
					#" CardAddedMult=" + str(card_results_dict.get("added_mult", 0)))
	#display_message("DEBUG: TotalChips=" + str(total_chips) +
					#" TotalMult=" + str(total_mult) +
					#" LevelMult=" + str(hand_level_mult))

	# --- Final Score Calculation ---
	# Apply the Balatro formula: TotalChips * TotalMult * LevelMult
	var final_score = total_chips * total_mult * hand_level_mult

	#display_message("DEBUG: Final Score Calculation: " + str(total_chips) + " * " +str(total_mult) + " * " + str(hand_level_mult) + " = " + str(final_score))

	# --- Increment Played Count and Check for Level Up ---
	add_hand_played_count(hand_type)
	check_organic_level_up(hand_type)

	return int(final_score)
	
# --- Flush-Related Functions ---

func is_flush(fcards: Array) -> bool:
	if fcards.size() < 5:
		return false
	var first_suit = fcards[0].suit
	for card in fcards:
		if card.suit != first_suit:
			return false
	return true

func calc_flush(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name) #append the name
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}


func is_flush_five(fcards: Array) -> bool:
	if fcards.size() != 5:  # Must be exactly 5 cards
		return false
	if not is_five_of_a_kind(fcards):
		return false
	return is_flush(fcards) # It is a five of a kind AND a flush

func calc_flush_five(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}


func is_flush_four(fcards):
	if fcards.size() < 4: #at least four
		return false
	if not is_four_of_a_kind(fcards): #check for 4 of a kind
		return false

	var rank_counts = {}
	for card in fcards:
		if rank_counts.has(card.rank):
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1

	var quad_rank = null
	for rank in rank_counts.keys():
		if rank_counts[rank] == 4:
			quad_rank = rank
			break

	var four_cards= []
	for card in fcards:
		if card.rank == quad_rank:
			four_cards.append(card)

	var first_suit = four_cards[0].suit
	for card in four_cards:
		if card.suit != first_suit:
			return false
	return true

func calc_flush_four(fcards: Array) -> Dictionary:
	var rank_counts = {} #count
	for card in fcards:
		if rank_counts.has(card.rank):
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1

	var quad_rank = null 
	for rank in rank_counts.keys():
		if rank_counts[rank] == 4:
			quad_rank = rank
			break

	var quad_cards = [] 
	for card in fcards:
		if card.rank == quad_rank:
			quad_cards.append(card)

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in quad_cards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}

	

	# STRAIGHT-RELATED FUNCTIONS
func is_straight(fcards: Array) -> bool:
	if fcards.size() != 5:
		return false
	var ranks = []
	for card in fcards:
		ranks.append(card.value)  # Use the numerical 'value' for rank
	ranks.sort()
	for i in range(ranks.size() - 1):
		if ranks[i + 1] != ranks[i] + 1:
			return false
	return true

func calc_straight(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}


func is_straight_flush(fcards: Array) -> bool:
	return is_straight(fcards) and is_flush(fcards)

func calc_straight_flush(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}


func is_royal_flush(fcards: Array) -> bool:
	if not is_straight_flush(fcards):
		return false
	# Check if the highest card is a Paladin (Ace)
	var ranks = []
	for card in fcards:
		ranks.append(card.value)
	ranks.sort()
	return ranks[4] == GlobalEnums.CardRank.PALADIN # CHECK TO BE SURE HIGHEST IS PALADIN

func calc_royal_flush(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}

	
	# KIND RELATED HANDS
		# HELPER FUNCTION
func count_ranks(fcards: Array) -> Dictionary:
	var rank_counts = {}
	for card in fcards:
		if rank_counts.has(card.rank):
			rank_counts[card.rank] += 1
		else:
			rank_counts[card.rank] = 1
	return rank_counts

func is_pair(fcards: Array) -> bool:
	if fcards.size() < 2: #at least 2
		return false
	var rank_counts = count_ranks(fcards)
	for count in rank_counts.values():
		if count == 2:
			return true
	return false

func calc_pair(fcards: Array) -> Dictionary:
	var rank_counts = count_ranks(fcards)
	var pair_rank = null
	for rank in rank_counts.keys():
		if rank_counts[rank] == 2:
			pair_rank = rank
			break

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		if card.rank == pair_rank:
			scored_cards.append(card.name)
			chips_from_cards += card.chip_value
			added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}

	
func is_two_pair(fcards: Array) -> bool:
	if fcards.size() < 4: #at least 4
		return false
	var rank_counts = count_ranks(fcards)
	var pair_count = 0
	for count in rank_counts.values():
		if count == 2:
			pair_count += 1
	return pair_count == 2

func calc_two_pair(fcards: Array) -> Dictionary:
	var rank_counts = count_ranks(fcards)
	var pair_ranks = []
	for rank in rank_counts.keys():
		if rank_counts[rank] == 2:
			pair_ranks.append(rank)

	if pair_ranks.size() != 2: #make sure
		return {"chips": 0, "added_mult": 0}

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	
	for card in fcards:
		if card.rank == pair_ranks[0] or card.rank == pair_ranks[1]:
			scored_cards.append(card.name)
			chips_from_cards += card.chip_value
			added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}

func is_three_of_a_kind(fcards: Array) -> bool:
	var rank_counts = count_ranks(fcards)
	for count in rank_counts.values():
		if count == 3:
			return true
	return false

func calc_three_of_a_kind(fcards: Array) -> Dictionary:
	var rank_counts = count_ranks(fcards)
	var trio_rank = null
	for rank in rank_counts.keys():
		if rank_counts[rank] == 3:
			trio_rank = rank
			break

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	
	for card in fcards:
		if card.rank == trio_rank:
			scored_cards.append(card.name)
			chips_from_cards += card.chip_value
			added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
			
func is_four_of_a_kind(fcards: Array) -> bool:
	var rank_counts = count_ranks(fcards)
	for count in rank_counts.values():
		if count == 4:
			return true
	return false

func is_five_of_a_kind(fcards: Array) -> bool:
	var rank_counts = count_ranks(fcards)
	for count in rank_counts.values():
		if count == 5:
			return true
	return false

func calc_the_three(fcards: Array) -> Dictionary:

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	
func is_the_three(fcards: Array) -> bool:
	if fcards.size() < 3:
		return false
	if not is_three_of_a_kind(fcards):
		return false

	var paladin_count = 0
	var suits = []
	for card in fcards:
		if card.rank == GlobalEnums.CardRank.PALADIN:
			paladin_count += 1
			suits.append(card.suit)
	if paladin_count != 3:
		return false

	suits.sort()  # Ensure consistent order for comparison
	return suits == [GlobalEnums.CardSuit.BAEZEL, GlobalEnums.CardSuit.GODRIK, GlobalEnums.CardSuit.ODESSA]

func calc_four_of_a_kind(fcards: Array) -> Dictionary:
	var rank_counts = count_ranks(fcards)
	var quad_rank = null
	for rank in rank_counts.keys():
		if rank_counts[rank] == 4:
			quad_rank = rank
			break


	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		if card.rank == quad_rank:
			scored_cards.append(card.name)
			chips_from_cards += card.chip_value
			added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	

func calc_five_of_a_kind(fcards: Array) -> Dictionary:
	var rank_counts = count_ranks(fcards)
	var five_rank = null
	for rank in rank_counts.keys():
		if rank_counts[rank] == 5:
			five_rank = rank
			break;

	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		if card.rank == five_rank:
			scored_cards.append(card.name)
			chips_from_cards += card.chip_value
			added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	
	
func is_full_house(fcards: Array) -> bool:
	if fcards.size() != 5:
		return false
	var rank_counts = count_ranks(fcards)
	var has_three = false
	var has_two = false
	for count in rank_counts.values():
		if count == 3:
			has_three = true
		elif count == 2:
			has_two = true
	return has_three and has_two
	
func calc_full_house(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	
	
func is_flush_house(fcards: Array) -> bool:
	return fcards.size() == 5 and is_full_house(fcards) and is_flush(fcards)

func is_godriks_house(fcards: Array) -> bool:
	return is_flush_house(fcards) and fcards[0].suit == GlobalEnums.CardSuit.GODRIK

func is_baezels_house(fcards: Array) -> bool:
	return is_flush_house(fcards) and fcards[0].suit == GlobalEnums.CardSuit.BAEZEL

func is_odessas_house(fcards: Array) -> bool:
	return is_flush_house(fcards) and fcards[0].suit == GlobalEnums.CardSuit.ODESSA
	
func calc_godriks_house(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	

func calc_baezels_house(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	

func calc_odessas_house(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	for card in fcards:
		scored_cards.append(card.name)
		chips_from_cards += card.chip_value
		added_mult_from_cards += card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	
	
func calc_high_card(fcards: Array) -> Dictionary:
	var chips_from_cards = 0
	var added_mult_from_cards = 0
	if fcards.size() > 0:
		var sorted_cards = sort_hand_by_rank([fcards[0].name]) #sort for highest
		var highest_card_name = sorted_cards[sorted_cards.size() -1] #get last
		var highest_card = fcards[0]
		for card in fcards: #find highest in played cards.
			if card.name == highest_card_name:
				highest_card = card
		scored_cards.append(highest_card.name)
		chips_from_cards += highest_card.chip_value
		added_mult_from_cards += highest_card.mult_value
	return {"chips": chips_from_cards, "added_mult": added_mult_from_cards}
	
