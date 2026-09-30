extends Control

var selected_character := "KAYA"
var selected_map := "KARA KIYI"
var character_button: Button
var map_button: Button
var login_button: Button
var character_popup: PopupMenu
var map_popup: PopupMenu

const CHARACTERS := ["KAYA", "S.A.Z", "AKREP"]
const MAPS := ["KARA KIYI"]

func _ready():
	# CI runs headless, so exercise the real gameplay scene too. Android keeps the lobby.
	if DisplayServer.get_name() == "headless":
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
		return
	_build_lobby()

func _build_lobby():
	var bg=ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color=Color(.035,.04,.035,1.0)
	add_child(bg)

	var title=Label.new()
	title.text="KARA KIYI"
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.position=Vector2(0,42)
	title.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",46)
	add_child(title)

	var sub=Label.new()
	sub.text="LOBI"
	sub.set_anchors_preset(Control.PRESET_TOP_WIDE)
	sub.position=Vector2(0,100)
	sub.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size",20)
	add_child(sub)

	var panel=VBoxContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position=Vector2(-210,-115)
	panel.size=Vector2(420,260)
	panel.add_theme_constant_override("separation",18)
	add_child(panel)

	character_button=Button.new()
	character_button.text="KARAKTER NESNESI: "+selected_character
	character_button.custom_minimum_size=Vector2(420,62)
	character_button.add_theme_font_size_override("font_size",19)
	character_button.pressed.connect(_open_character_menu)
	panel.add_child(character_button)

	map_button=Button.new()
	map_button.text="HARITA SEC: "+selected_map
	map_button.custom_minimum_size=Vector2(420,62)
	map_button.add_theme_font_size_override("font_size",19)
	map_button.pressed.connect(_open_map_menu)
	panel.add_child(map_button)

	login_button=Button.new()
	login_button.text="GIRIS YAP"
	login_button.custom_minimum_size=Vector2(420,68)
	login_button.add_theme_font_size_override("font_size",22)
	login_button.pressed.connect(_enter_game)
	panel.add_child(login_button)

	character_popup=PopupMenu.new()
	for i in CHARACTERS.size():
		character_popup.add_item(CHARACTERS[i],i)
	character_popup.id_pressed.connect(_character_selected)
	add_child(character_popup)

	map_popup=PopupMenu.new()
	for i in MAPS.size():
		map_popup.add_item(MAPS[i],i)
	map_popup.id_pressed.connect(_map_selected)
	add_child(map_popup)

func _open_character_menu():
	var pos:=character_button.get_screen_position()
	character_popup.position=Vector2i(int(pos.x),int(pos.y+character_button.size.y))
	character_popup.size=Vector2i(int(character_button.size.x),0)
	character_popup.popup()

func _open_map_menu():
	var pos:=map_button.get_screen_position()
	map_popup.position=Vector2i(int(pos.x),int(pos.y+map_button.size.y))
	map_popup.size=Vector2i(int(map_button.size.x),0)
	map_popup.popup()

func _character_selected(id:int):
	if id>=0 and id<CHARACTERS.size():
		selected_character=CHARACTERS[id]
		character_button.text="KARAKTER NESNESI: "+selected_character

func _map_selected(id:int):
	if id>=0 and id<MAPS.size():
		selected_map=MAPS[id]
		map_button.text="HARITA SEC: "+selected_map

func _enter_game():
	var cfg=ConfigFile.new()
	cfg.set_value("player","character",selected_character)
	cfg.set_value("game","map",selected_map)
	cfg.save("user://player.cfg")
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		_enter_game()
