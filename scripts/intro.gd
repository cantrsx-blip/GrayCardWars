extends Control

var selected_character := "KAYA"
var selected_map := "KARA KIYI"
var character_button: Button
var map_button: Button
var login_button: Button
var character_popup: PopupMenu
var map_popup: PopupMenu
var cheat_mode := false
var gj_balance := 0
var gj_label: Label
var cheat_button: Button
var store_panel: Panel
var lobby_inventory_panel: Panel

const CHARACTERS := ["KAYA", "S.A.Z", "AKREP"]
const MAPS := ["KARA KIYI"]

func _ready():
	# CI runs headless, so exercise the real gameplay scene too. Android keeps the lobby.
	if DisplayServer.get_name() == "headless":
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
		return
	_build_lobby()

func _build_lobby():
	var bg=TextureRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.texture=load("res://lobiarkaplan.jpg")
	bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
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

	gj_label=Label.new()
	gj_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	gj_label.position=Vector2(-360,28)
	gj_label.size=Vector2(150,42)
	gj_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	gj_label.add_theme_font_size_override("font_size",22)
	add_child(gj_label)

	cheat_button=Button.new()
	cheat_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	cheat_button.position=Vector2(-195,24)
	cheat_button.size=Vector2(175,44)
	cheat_button.pressed.connect(_toggle_cheat)
	add_child(cheat_button)

	var store_button=Button.new()
	store_button.text="MAĞAZA"
	store_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	store_button.position=Vector2(-195,78)
	store_button.size=Vector2(175,48)
	store_button.add_theme_font_size_override("font_size",18)
	store_button.pressed.connect(_toggle_store)
	add_child(store_button)

	var inventory_button=Button.new()
	inventory_button.text="ENVANTER"
	inventory_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	inventory_button.position=Vector2(-195,136)
	inventory_button.size=Vector2(175,48)
	inventory_button.add_theme_font_size_override("font_size",18)
	inventory_button.pressed.connect(_toggle_lobby_inventory)
	add_child(inventory_button)
	_update_lobby_currency()

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

func _toggle_cheat():
	cheat_mode=!cheat_mode
	gj_balance=9999 if cheat_mode else 0
	_update_lobby_currency()

func _update_lobby_currency():
	if gj_label: gj_label.text=str(gj_balance)+" GJ"
	if cheat_button: cheat_button.text="HILE ACIK" if cheat_mode else "HILE KAPALI"

func _toggle_lobby_inventory():
	if lobby_inventory_panel==null:
		_build_lobby_inventory()
	lobby_inventory_panel.visible=not lobby_inventory_panel.visible

func _build_lobby_inventory():
	lobby_inventory_panel=Panel.new()
	lobby_inventory_panel.set_anchors_preset(Control.PRESET_CENTER)
	lobby_inventory_panel.position=Vector2(-390,-290)
	lobby_inventory_panel.size=Vector2(780,580)
	add_child(lobby_inventory_panel)
	var title=Label.new()
	title.text="ENVANTER"
	title.position=Vector2(20,12)
	title.size=Vector2(620,38)
	title.add_theme_font_size_override("font_size",26)
	lobby_inventory_panel.add_child(title)
	var close=Button.new()
	close.text="✕"
	close.position=Vector2(712,10)
	close.size=Vector2(50,38)
	close.pressed.connect(_toggle_lobby_inventory)
	lobby_inventory_panel.add_child(close)
	var info=Label.new()
	info.text="OYUNCU ENVANTERI"
	info.position=Vector2(20,80)
	info.size=Vector2(740,50)
	info.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	info.add_theme_font_size_override("font_size",22)
	lobby_inventory_panel.add_child(info)
	lobby_inventory_panel.visible=true

func _toggle_store():
	if store_panel==null:
		_build_store()
	store_panel.visible=not store_panel.visible

func _build_store():
	store_panel=Panel.new()
	store_panel.set_anchors_preset(Control.PRESET_CENTER)
	store_panel.position=Vector2(-390,-290)
	store_panel.size=Vector2(780,580)
	add_child(store_panel)
	var title=Label.new()
	title.text="MAĞAZA"
	title.position=Vector2(20,12)
	title.size=Vector2(620,38)
	title.add_theme_font_size_override("font_size",26)
	store_panel.add_child(title)
	var balance=Label.new()
	balance.text=str(gj_balance)+" GJ"
	balance.position=Vector2(535,15)
	balance.size=Vector2(150,34)
	balance.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	balance.add_theme_font_size_override("font_size",19)
	store_panel.add_child(balance)
	var close=Button.new()
	close.text="✕"
	close.position=Vector2(712,10)
	close.size=Vector2(50,38)
	close.pressed.connect(_toggle_store)
	store_panel.add_child(close)
	var categories=["TÜMÜ","SİLAH","ZIRH","KARTLAR"]
	for i in categories.size():
		var b=Button.new()
		b.text=categories[i]
		b.position=Vector2(20+i*185,68)
		b.size=Vector2(170,48)
		b.add_theme_font_size_override("font_size",18)
		store_panel.add_child(b)
	var note=Label.new()
	note.text="GJ MAĞAZASI"
	note.position=Vector2(20,145)
	note.size=Vector2(740,50)
	note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	note.add_theme_font_size_override("font_size",22)
	store_panel.add_child(note)
	store_panel.visible=true

func _enter_game():
	var cfg=ConfigFile.new()
	cfg.set_value("player","character",selected_character)
	cfg.set_value("game","map",selected_map)
	cfg.set_value("game","cheat",cheat_mode)
	cfg.set_value("currency","gj",gj_balance)
	cfg.save("user://player.cfg")
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		_enter_game()
