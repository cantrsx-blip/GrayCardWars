extends Control

var selected_character := "KAYA"
var cards: Dictionary = {}
var title_label: Label
var role_label: Label
var start_button: Button

func _ready():
	_build_intro()
	_select_character("KAYA")

func _build_intro():
	var bg=ColorRect.new(); bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); bg.color=Color(.055,.06,.055,1.0); add_child(bg)
	var glow=ColorRect.new(); glow.set_anchors_preset(Control.PRESET_CENTER); glow.position=Vector2(-420,-250); glow.size=Vector2(840,500); glow.color=Color(.13,.12,.09,.75); add_child(glow)
	title_label=Label.new(); title_label.text="KARA KIYI"; title_label.set_anchors_preset(Control.PRESET_TOP_WIDE); title_label.position=Vector2(0,55); title_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; title_label.add_theme_font_size_override("font_size",52); add_child(title_label)
	var sub=Label.new(); sub.text="KARAKTERİNİ SEÇ"; sub.set_anchors_preset(Control.PRESET_TOP_WIDE); sub.position=Vector2(0,125); sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; sub.add_theme_font_size_override("font_size",20); add_child(sub)
	var row=HBoxContainer.new(); row.set_anchors_preset(Control.PRESET_CENTER); row.position=Vector2(-390,-110); row.size=Vector2(780,240); row.add_theme_constant_override("separation",24); add_child(row)
	for data in [["KAYA","İSTİHKAM"],["S.A.Z","KOMUTA"],["AKREP","ÖNCÜ"]]:
		var b=Button.new(); b.text=data[0]+"\n\n"+data[1]; b.custom_minimum_size=Vector2(244,220); b.add_theme_font_size_override("font_size",25); b.pressed.connect(_select_character.bind(data[0])); row.add_child(b); cards[data[0]]=b
	role_label=Label.new(); role_label.set_anchors_preset(Control.PRESET_CENTER); role_label.position=Vector2(-300,155); role_label.size=Vector2(600,36); role_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; role_label.add_theme_font_size_override("font_size",20); add_child(role_label)
	start_button=Button.new(); start_button.text="GÖREVE BAŞLA"; start_button.set_anchors_preset(Control.PRESET_CENTER); start_button.position=Vector2(-145,210); start_button.size=Vector2(290,64); start_button.add_theme_font_size_override("font_size",22); start_button.pressed.connect(_start_game); add_child(start_button)

func _select_character(name:String):
	selected_character=name
	role_label.text="SEÇİLEN: "+name
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
