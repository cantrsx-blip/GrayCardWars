extends Control

var selected_character := "KAYA"
var cards: Dictionary = {}
var title_label: Label
var role_label: Label
var start_button: Button

func _ready():
	# CI runs headless, so exercise the real gameplay scene too. Android keeps the selector.
	if DisplayServer.get_name() == "headless":
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
		return
	_build_intro()
	_select_character("KAYA")

func _build_intro():
	var bg=ColorRect.new(); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); bg.color=Color(.035,.04,.035,1.0); add_child(bg)
	title_label=Label.new(); title_label.text="KARA KIYI"; title_label.set_anchors_preset(Control.PRESET_TOP_WIDE); title_label.position=Vector2(0,28); title_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title_label.add_theme_font_size_override("font_size",46); add_child(title_label)
	var sub=Label.new(); sub.text="KARAKTERİNİ SEÇ"; sub.set_anchors_preset(Control.PRESET_TOP_WIDE); sub.position=Vector2(0,86); sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; sub.add_theme_font_size_override("font_size",18); add_child(sub)
	var row=HBoxContainer.new(); row.set_anchors_preset(Control.PRESET_CENTER); row.position=Vector2(-405,-175); row.size=Vector2(810,330); row.add_theme_constant_override("separation",18); add_child(row)
	var data=[["KAYA","KESKİN NİŞANCI","res://KAYA.jpg"],["S.A.Z","KAMUFLAJ USTASI","res://SAZ.jpg"],["AKREP","OTOMATİK SİLAH UZMANI","res://AKREP.jpg"]]
	for item in data:
		var card=VBoxContainer.new(); card.custom_minimum_size=Vector2(258,330); row.add_child(card)
		var portrait=TextureButton.new()
		var portrait_path:String=item[2]
		if ResourceLoader.exists(portrait_path):
			var portrait_texture=ResourceLoader.load(portrait_path)
			if portrait_texture is Texture2D:
				portrait.texture_normal=portrait_texture
		portrait.ignore_texture_size=true
		portrait.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_COVERED
		portrait.custom_minimum_size=Vector2(258,258)
		portrait.pressed.connect(_select_character.bind(item[0]))
		card.add_child(portrait)
		var b=Button.new(); b.text=item[0]+"\n"+item[1]; b.custom_minimum_size=Vector2(258,66); b.add_theme_font_size_override("font_size",18); b.pressed.connect(_select_character.bind(item[0])); card.add_child(b); cards[item[0]]=b
	role_label=Label.new(); role_label.set_anchors_preset(Control.PRESET_CENTER); role_label.position=Vector2(-430,176); role_label.size=Vector2(860,52); role_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; role_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; role_label.add_theme_font_size_override("font_size",17); add_child(role_label)
	start_button=Button.new(); start_button.text="GÖREVE BAŞLA"; start_button.set_anchors_preset(Control.PRESET_CENTER); start_button.position=Vector2(-145,238); start_button.size=Vector2(290,58); start_button.add_theme_font_size_override("font_size",21); start_button.pressed.connect(_start_game); add_child(start_button)

func _select_character(name:String):
	selected_character=name
	var descriptions={"KAYA":"Usta keskin nişancı. Uzak mesafede olağanüstü isabet.","S.A.Z":"Her türlü iklime dayanıklı kamuflaj ustası. Dostun değilse gözün açık olsun.","AKREP":"Çok hızlı ve çevik. Otomatik silahlarda uzman; emri anında uygular."}
	role_label.text=name+"  •  "+descriptions.get(name,"")
	for key in cards:
		var b:Button=cards[key]
		b.modulate=Color(1.0,.82,.35,1.0) if key==name else Color(.72,.72,.72,.82)

func _start_game():
	var cfg=ConfigFile.new()
	cfg.set_value("player","character",selected_character)
	cfg.save("user://player.cfg")
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		_start_game()
