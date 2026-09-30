extends Control

var correct_answer := 0
var score := 0
var streak := 0
var lives := 3
var difficulty := 1

var fail_sounds = [
	preload("res://sounds/bone-crack.mp3"),
	preload("res://sounds/eagle.mp3"),
	preload("res://sounds/gunshottttt.mp3")
]

var fail_texts = [
	"BRUH 💀",
	"OOF ✋😭",
	"Nooo 😭",
	"F in the chat 📉",
	"Big oof energy"
]

func _ready():
	randomize()
	$VBoxContainer/RestartButton.hide()
	$MemeOverlay.hide()
	update_lives_display()
	update_streak_display()
	new_question()

func new_question():
	var max_range = 10 + (difficulty * 3)
	var a = randi() % max_range + 1
	var b = randi() % max_range + 1
	var ops = ["+", "-"]
	var op = ops[randi() % ops.size()]

	if op == "-" and a < b:
		var temp = a
		a = b
		b = temp

	correct_answer = a + b if op == "+" else a - b

	$VBoxContainer/QuestionLabel.text = str(a) + " " + op + " " + str(b) + " = ?"
	$VBoxContainer/MascotLabel.text = "🦔"

	generate_answer_buttons()

func generate_answer_buttons():
	for child in $VBoxContainer/AnswerButtons.get_children():
		child.queue_free()

	var answers = [correct_answer]
	while answers.size() < 3:
		var wrong = correct_answer + (randi() % 7 - 3)
		if wrong != correct_answer and wrong >= 0 and not answers.has(wrong):
			answers.append(wrong)
	answers.shuffle()

	for ans in answers:
		var btn = Button.new()
		btn.text = str(ans)
		btn.custom_minimum_size = Vector2(100, 60)
		btn.add_theme_font_size_override("font_size", 32)
		btn.pressed.connect(_on_answer_pressed.bind(ans, btn))
		$VBoxContainer/AnswerButtons.add_child(btn)

func _on_answer_pressed(chosen: int, btn: Button):
	bounce_button(btn)
	set_buttons_enabled(false)

	if chosen == correct_answer:
		score += 1
		streak += 1
		if streak > 0 and streak % 5 == 0:
			difficulty += 1
			$VBoxContainer/MascotLabel.text = "🎉"
		else:
			$VBoxContainer/MascotLabel.text = "😄"
		$VBoxContainer/ScoreLabel.text = "Score: " + str(score)
		flash_color(Color(0.4, 0.9, 0.4))
		update_streak_display()
		set_buttons_enabled(true)
		new_question()
	else:
		streak = 0
		lives -= 1
		update_lives_display()
		update_streak_display()
		await show_meme_screen()

		if lives <= 0:
			game_over()
		else:
			set_buttons_enabled(true)
			new_question()

func show_meme_screen():
	var random_text = fail_texts[randi() % fail_texts.size()]
	$MemeOverlay/MemeLabel.text = random_text
	$FailSoundPlayer.stream = fail_sounds[randi() % fail_sounds.size()]
	$FailSoundPlayer.play()
	$MemeOverlay.show()

	await get_tree().create_timer(1.5).timeout

	$MemeOverlay.hide()

func set_buttons_enabled(enabled: bool):
	for child in $VBoxContainer/AnswerButtons.get_children():
		child.disabled = not enabled

func update_lives_display():
	var hearts = ""
	for i in range(lives):
		hearts += "❤️"
	$VBoxContainer/LivesLabel.text = hearts

func update_streak_display():
	$VBoxContainer/StreakLabel.text = "Streak: " + str(streak)

func flash_color(color: Color):
	var bg = $ColorRect
	var tween = create_tween()
	tween.tween_property(bg, "color", color, 0.1)
	tween.tween_property(bg, "color", Color(0.42, 0.87, 0.75), 0.3)

func bounce_button(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.08)

func game_over():
	$VBoxContainer/QuestionLabel.text = "Game Over! Final Score: " + str(score)
	$VBoxContainer/MascotLabel.text = "🏆"
	for child in $VBoxContainer/AnswerButtons.get_children():
		child.queue_free()
	$VBoxContainer/RestartButton.show()

func _on_restart_button_pressed():
	score = 0
	streak = 0
	lives = 3
	difficulty = 1
	$VBoxContainer/RestartButton.hide()
	update_lives_display()
	update_streak_display()
	$VBoxContainer/ScoreLabel.text = "Score: 0"
	new_question()
