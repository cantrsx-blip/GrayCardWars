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
var lobby_inventory: Dictionary = {}

const STORE_WEAPON_PATHS := [
	"res://Weapon1.png","res://Weapon2.png","res://Weapon3.png","res://Weapon4.png",
	"res://Weapon5.png","res://Weapon6.png.png","res://Weapon7.png.png","res://Weapon8.png"
]
const STORE_SLOT_BG := ["res://gumus.png","res://zehir.png","res://buz.jpg","res://gunes.png","res://lav.png"]

const CHARACTERS := ["KAYA", "S.A.Z", "AKREP"]
const MAPS := ["KARA KIYI"]

func _ready():
	# CI runs headless, so exercise the real gameplay scene too. Android keeps the lobby.
	if DisplayServer.get_name() == "headless":
		get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")
		return
	_load_lobby_inventory()
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

	var choose_character_button=Button.new()
	choose_character_button.text="KARAKTERİNİ SEÇ"
	choose_character_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	choose_character_button.position=Vector2(20,24)
	choose_character_button.size=Vector2(210,50)
	choose_character_button.add_theme_font_size_override("font_size",18)
	choose_character_button.pressed.connect(_open_character_menu_from_corner)
	add_child(choose_character_button)

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

func _open_character_menu_from_corner():
	character_popup.position=Vector2i(20,78)
	character_popup.size=Vector2i(210,0)
	character_popup.popup()

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

func _load_lobby_inventory():
	var cfg=ConfigFile.new()
	if cfg.load("user://player.cfg")==OK:
		var saved=cfg.get_value("inventory","crafted",{})
		if saved is Dictionary: lobby_inventory=saved

func _rarity_name(rarity:String) -> String:
	match rarity:
		"gray": return "Gri"
		"green": return "Yeşil"
		"blue": return "Mavi"
		"orange": return "Turuncu"
		"red": return "Kırmızı"
	return rarity

func _toggle_lobby_inventory():
	if lobby_inventory_panel==null:
		_build_lobby_inventory()
	var opening=not lobby_inventory_panel.visible
	lobby_inventory_panel.visible=opening
	if opening: _refresh_lobby_inventory()

func _build_lobby_inventory():
	lobby_inventory_panel=Panel.new()
	lobby_inventory_panel.set_anchors_preset(Control.PRESET_CENTER)
	lobby_inventory_panel.position=Vector2(-360,-290)
	lobby_inventory_panel.size=Vector2(720,580)
	add_child(lobby_inventory_panel)
	var title=Label.new()
	title.text="ENVANTER"
	title.position=Vector2(24,14)
	title.add_theme_font_size_override("font_size",26)
	lobby_inventory_panel.add_child(title)
	var close=Button.new()
	close.text="✕"
	close.position=Vector2(650,12)
	close.size=Vector2(48,42)
	close.pressed.connect(_toggle_lobby_inventory)
	lobby_inventory_panel.add_child(close)
	var scroll=ScrollContainer.new()
	scroll.name="InvScroll"
	scroll.position=Vector2(20,58)
	scroll.size=Vector2(680,500)
	lobby_inventory_panel.add_child(scroll)
	var grid=GridContainer.new()
	grid.name="Grid"
	grid.columns=5
	grid.custom_minimum_size=Vector2(650,0)
	grid.add_theme_constant_override("h_separation",2)
	grid.add_theme_constant_override("v_separation",6)
	scroll.add_child(grid)
	lobby_inventory_panel.visible=false

func _refresh_lobby_inventory():
	if lobby_inventory_panel==null: return
	var grid=lobby_inventory_panel.get_node("InvScroll/Grid")
	for child in grid.get_children(): child.queue_free()
	var shown:=0
	for key in lobby_inventory:
		var count=int(lobby_inventory[key])
		if count<=0: continue
		var parts=str(key).split("|")
		if parts.size()<2: continue
		var title="%s %s" % [_rarity_name(str(parts[1])),str(parts[0])]
		var stackable=str(parts[0]) in ["Ok","Tabanca Mermisi","Pompalı Mermisi","Tüfek Mermisi"]
		var remaining=count
		while remaining>0 and shown<25:
			var amount=mini(100,remaining) if stackable else 1
			var cell=VBoxContainer.new()
			cell.custom_minimum_size=Vector2(128,142)
			var image=TextureRect.new()
			image.custom_minimum_size=Vector2(128,104)
			image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			cell.add_child(image)
			var name=Button.new()
			name.custom_minimum_size=Vector2(128,34)
			name.text=title+"  "+str(amount)+"x"
			name.clip_text=true
			name.add_theme_font_size_override("font_size",10)
			cell.add_child(name)
			grid.add_child(cell)
			remaining-=amount
			shown+=1
		if shown>=25: break
	if shown==0:
		var empty=Label.new()
		empty.text="ENVANTER BOŞ"
		empty.custom_minimum_size=Vector2(650,60)
		empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		empty.add_theme_font_size_override("font_size",20)
		grid.add_child(empty)

func _store_png_texture(path:String) -> Texture2D:
	var loaded=ResourceLoader.load(path)
	if loaded is Texture2D: return loaded
	if FileAccess.file_exists(path):
		var bytes=FileAccess.get_file_as_bytes(path)
		if bytes.size()>0:
			var img=Image.new()
			var err=img.load_jpg_from_buffer(bytes) if path.to_lower().ends_with(".jpg") or path.to_lower().ends_with(".jpeg") else img.load_png_from_buffer(bytes)
			if err==OK: return ImageTexture.create_from_image(img)
	return null

func _toggle_store():
	if store_panel==null: _build_store()
	var opening=not store_panel.visible
	store_panel.visible=opening
	if opening: _show_store_category("TÜMÜ")

func _build_store():
	store_panel=Panel.new()
	store_panel.set_anchors_preset(Control.PRESET_CENTER)
	store_panel.position=Vector2(-390,-290)
	store_panel.size=Vector2(780,580)
	add_child(store_panel)
	var title=Label.new()
	title.text="MAĞAZA"
	title.position=Vector2(20,12)
	title.size=Vector2(500,38)
	title.add_theme_font_size_override("font_size",26)
	store_panel.add_child(title)
	var balance=Label.new()
	balance.name="GJBalance"
	balance.text=str(gj_balance)+" GJ"
	balance.position=Vector2(520,15)
	balance.size=Vector2(165,34)
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
		var btn=Button.new()
		btn.text=categories[i]
		btn.position=Vector2(20+i*185,68)
		btn.size=Vector2(170,48)
		btn.add_theme_font_size_override("font_size",18)
		btn.pressed.connect(_show_store_category.bind(categories[i]))
		store_panel.add_child(btn)
	_show_store_category("TÜMÜ")
	store_panel.visible=false

func _show_store_category(category:String):
	if store_panel==null: return
	var old=store_panel.get_node_or_null("CategoryItems")
	if old: old.queue_free()
	var scroll=ScrollContainer.new()
	scroll.name="CategoryItems"
	scroll.position=Vector2(20,130)
	scroll.size=Vector2(740,425)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	store_panel.add_child(scroll)
	var grid=GridContainer.new()
	grid.columns=5
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",8)
	scroll.add_child(grid)
	var weapons=[]
	for path in STORE_WEAPON_PATHS: weapons.append(_store_png_texture(path))
	var show_weapon=category=="TÜMÜ" or category=="SİLAH"
	var show_cards=category=="TÜMÜ" or category=="KARTLAR"
	for i in 40:
		var cell=Control.new()
		cell.custom_minimum_size=Vector2(136,104)
		var bg_tex=_store_png_texture(STORE_SLOT_BG[i % STORE_SLOT_BG.size()])
		if bg_tex!=null:
			var bg=TextureRect.new()
			bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			bg.texture=bg_tex
			bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
			bg.stretch_mode=TextureRect.STRETCH_SCALE
			bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
			cell.add_child(bg)
		else:
			var fallback=ColorRect.new()
			fallback.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			fallback.color=Color(.2,.2,.2,1)
			cell.add_child(fallback)
		if show_weapon:
			var row=int(i/5)
			var tex=weapons[row]
			if tex!=null:
				var overlay=TextureRect.new()
				overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
				overlay.texture=tex
				overlay.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
				overlay.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				cell.add_child(overlay)
		elif show_cards:
			var card=Label.new()
			card.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			card.text=["GRİ","YEŞİL","MAVİ","TURUNCU","KIRMIZI"][i%5]+" KART"
			card.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
			card.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
			card.add_theme_font_size_override("font_size",14)
			cell.add_child(card)
		grid.add_child(cell)

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
