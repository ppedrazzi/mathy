### To Do's

--1.0 
--Fix missed questions formatting of answer.
- Fixed missed questions formatting for more than one column.
- remove "missed questions" and formate PERFECT SCORE
- No repeat questions
- format "quit game"

--1.5
-Make responsive.
-Comment and clean code (variable names, dry, methods minimize, etc).
-Review method and variable names.

--2.0
- Add Social Sharing
- Add Google Ads

###

if Meteor.isClient
	missedList = []
	Session.setDefault("inGame", false)
	Session.setDefault("isOver", false)
	Session.setDefault("count", 0)
	Session.setDefault("answer", 0)
	Session.setDefault("correct", 0)
	Session.setDefault("missed", "You got everything right!")
	Session.setDefault("operation", "multiplication")
	Session.setDefault("base", 6)
	Session.setDefault("upto", 12)
	Session.setDefault("questions", 10)	
	Session.setDefault("currentGameTime", 0)
	
	countUp = () ->
		a = Session.get("currentGameTime")
		b = a + 1
		Session.set("currentGameTime", b)
		
	timer = Meteor.setInterval(countUp, 1000)
	
	Template.boxy.helpers
		inGame: () ->
			Session.get("inGame")
		
		isOver: () ->
			Session.get("isOver")
	
	Template.question.helpers
		a: () ->
			Session.get("a")
		
		b: () ->
			Session.get("b")
		
		count: () ->
			Session.get("count") + 1
		
		timer: () ->
			seconds = Session.get("currentGameTime")
			date = new Date(seconds * 1000)
			mm = date.getMinutes()
			ss = date.getSeconds()
			#These lines ensure you have two-digits
			if mm < 10 then mm = "0"+mm
			if ss < 10 then ss = "0"+ss
			# This formats your string to MM:SS
			t = mm+":"+ss
			t

		symbol: () ->
			operation = Session.get("operation")
			switch operation
				when "multiplication" then "x   "
				when "division" then "/   "
				when "addition" then "+   "
				when "subtraction" then "-   "
				
		total: () ->
			Session.get("questions")
			
	Template.results.helpers
		percentage: () ->
			a = Session.get("correct")
			b = Session.get("count")
			percentage = (a/b) * 100
			Math.round(percentage * 10) / 10

		correctQuestions: () ->
			Session.get("correct")

		timePerQuestion: () ->
			# no good due to string in results.time.  fix or change to something else.
			value = Session.get("totalTime")/Session.get("count")
			Math.round(value * 10) / 10
			
		time: () ->
			Session.set("endTime", (new Date()))
			d2 = Session.get("endTime")
			d1 = Session.get("startTime")
			seconds = (Math.round((d2.getTime() - d1.getTime())))/1000
			# multiply by 1000 because Date() requires miliseconds
			date = new Date(seconds * 1000)
			mm = date.getMinutes()
			ss = date.getSeconds()
			#These lines ensure you have two-digits
			if mm < 10 then mm = "0"+mm
			if ss < 10 then ss = "0"+ss
			# This formats your string to MM:SS
			t = mm+":"+ss
			Session.set("totalTime", t)
			Session.get("totalTime")
		
	Template.missed.helpers
		missed: () ->
			Session.get("missed")
		
		perfectScore: () ->
			if Session.get("missed") is "You got everything right!" then true else false


	Template.board.helpers
		additionClass: () ->
			if Session.get("operation") is "addition"
				"operator-selection-box-selected"
			else
				"operator-selection-box"

		multiplicationClass: () ->
			if Session.get("operation") is "multiplication"
				"operator-selection-box-selected"
			else
				"operator-selection-box"

		subtractionClass: () ->
			if Session.get("operation") is "subtraction"
				"operator-selection-box-selected"
			else
				"operator-selection-box"

		additionOperatorId: () ->
			if Session.get("operation") is "addition"
				"addition-active"
			else
				"addition"

		multiplicationOperatorId: () ->
			if Session.get("operation") is "multiplication"
				"multiplication-active"
			else
				"multiplication"

		subtractionOperatorId: () ->
			if Session.get("operation") is "subtraction"
				"subtraction-active"
			else
				"subtraction"
			
		base: () ->
			Session.get("base")
	
		upto: () ->
			Session.get("upto")
		
		tenClass: () ->
			if Session.get("questions") is 10
				"quiz-selection-box-selected"
			else
				"quiz-selection-box"
		
		twentyfiveClass: () ->
			if Session.get("questions") is 25
				"quiz-selection-box-selected"
			else
				"quiz-selection-box"
			
		fiftyClass: () ->
			if Session.get("questions") is 50
				"quiz-selection-box-selected"
			else
				"quiz-selection-box"		

		hundredClass: () ->
			if Session.get("questions") is 100
				"quiz-selection-box-selected"
			else
				"quiz-selection-box"
			
		tenLabel: () ->
			if Session.get("questions") is 10
				"quiz-label-selected"
			else
				"quiz-label"
			
		twentyLabel: () ->
			if Session.get("questions") is 25
				"quiz-label-selected"
			else
				"quiz-label"
			
		fiftyLabel: () ->
			if Session.get("questions") is 50
				"quiz-label-selected"
			else
				"quiz-label"
			
		hundredLabel: () ->
			if Session.get("questions") is 100
				"quiz-label-selected"
			else
				"quiz-label"

	Template.results.events
		'click #design-new-game-button': () ->
			Meteor.call("newReset")
			
		'click #play-again-button': () ->
			Meteor.call("againReset")
			Meteor.call("newQuestion")
			Session.set("startTime", (new Date()))
			Session.set("currentGameTime", 0)
			
	Template.question.rendered = () ->
		inputField = this.find('input')
		inputField.focus()			

	Template.question.events
		'keypress input': (e,t) ->
			if (e.keyCode is 13)
				input = t.find("input")
				Meteor.call("scoreIt", input.value)
				Session.set("count", (Session.get("count") + 1))
				if Session.get("count") is (Session.get("questions"))
					Session.set("isOver", true)
				else
					input.value = ""
					Meteor.call("newQuestion")
					
		'click #in-game-menu': () ->
			Meteor.call("newReset")

	Template.board.events
		'click #addition': () ->
			Session.set("operation", "addition")
			
		'click #multiplication': () ->
			Session.set("operation", "multiplication")
			
		'click #subtraction': () ->
			Session.set("operation", "subtraction")
	
		'click #start-game-button': () ->
			range = Session.get("upto")
			Session.set("range", [1..range])
			Meteor.call("newQuestion")
			Session.set("inGame", true)
			Session.set("startTime", (new Date()))
			Session.set("currentGameTime", 0)

		'click #base-up': () ->
			a = Session.get("base")
			if a < 99
				b = a + 1
				Session.set("base", b)
		
		'click #base-down': () ->
			a = Session.get("base")
			if a > 1
				b = a - 1
				Session.set("base", b)
		
		'click #upto-up': () ->
			a = Session.get("upto")
			if a < 99
				b = a + 1
				Session.set("upto", b)
		
		'click #upto-down': () ->
			a = Session.get("upto")
			if a > 1
				b = a - 1
				Session.set("upto", b)
				
		'click #ten': () ->
			Session.set("questions", 10)
			
		'click #twenty-five': () ->
			Session.set("questions", 25)
			
		'click #fifty': () ->
			Session.set("questions", 50)
			
		'click #one-hundred': () ->
			Session.set("questions", 100)

		
	Meteor.methods
		newQuestion: () ->
			list = Session.get("range")
			operation = Session.get("operation")
			a = Random.choice(list)
			while a is Session.get("a")
				a = Random.choice(list)
			b = Session.get("base")
			if a >= b
				Session.set("a", a)
				Session.set("b", b)
			else
				Session.set("a", b)
				Session.set("b", a)
			switch operation
				when "multiplication" then Session.set("answer", (Session.get("a") * Session.get("b")))
				when "division" then Session.set("answer", (Session.get("a") / Session.get("b")))
				when "addition" then Session.set("answer", (Session.get("a") + Session.get("b")))
				when "subtraction" then Session.set("answer", (Session.get("a") - Session.get("b")))
			
		scoreIt: (input) ->
			symbol = Meteor.call("getSymbol", Session.get("operation"))
			asked = "#{Session.get("a")} #{symbol} #{Session.get("b")} = #{Session.get("answer")} (#{input})"
			if parseInt(input) is Session.get("answer")
				Session.set("correct", (Session.get("correct")+1))
			else
				missedList.push(asked)
				Session.set("missed", missedList)
				
		newReset: () ->
			missedList = []
			Session.set("isOver", false)
			Session.set("inGame", false)
			Session.set("isOver", false)
			Session.set("count", 0)
			Session.set("answer", 0)
			Session.set("correct", 0)
			Session.set("missed", "You got everything right!")
			
		againReset: () ->
			missedList = []
			Session.set("isOver", false)
			Session.set("count", 0)
			Session.set("answer", 0)
			Session.set("correct", 0)
			Session.set("missed", "You got everything right!")
			
		getSymbol: (operation) ->
			switch operation
				when "multiplication" then "x"
				when "division" then "/"
				when "addition" then "+"
				when "subtraction" then "-"