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
var store_cards: Dictionary = {"gumus":0,"yesil":0,"buz":0,"gunes":0,"lav":0}
var lobby_hotbar: Array = ["","","","","","",""]
var store_preview: Panel
var preview_quantity := 1
var preview_kind := ""
var preview_row := 0
var preview_variant := ""
var preview_qty_label: Label
var preview_cost_label: Label
var preview_slider: HSlider
var store_category := "TÜMÜ"
var weapon_inspect_panel: Panel
var weapon_inspect_model: Node3D
var weapon_inspect_dragging := false
var weapon_inspect_last_pos := Vector2.ZERO
var weapon_inspect_spin := Vector2.ZERO
var weapon_inspect_zoom := 1.0

const STORE_WEAPON_VARIANTS := ["gumus","yesil","buz","gunes","lav"]
const STORE_VARIANT_NAMES := ["Gümüş","Zehir","Buz","Güneş","Lav"]
const STORE_WEAPON_NAMES := ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
const STORE_WEAPON_COSTS := [2,4,8,16,32,64,128,256]
const CARD_PRICE_GJ := 2
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
	_save_lobby_state()
	_update_lobby_currency()

func _update_lobby_currency():
	if gj_label: gj_label.text=str(gj_balance)+" GJ"
	if cheat_button: cheat_button.text="HILE ACIK" if cheat_mode else "HILE KAPALI"

func _load_lobby_inventory():
	var cfg=ConfigFile.new()
	if cfg.load("user://player.cfg")==OK:
		var saved=cfg.get_value("inventory","crafted",{})
		if saved is Dictionary: lobby_inventory=saved
		var cards=cfg.get_value("inventory","store_cards",{})
		if cards is Dictionary:
			for k in store_cards.keys(): store_cards[k]=int(cards.get(k,0))
		var saved_hotbar=cfg.get_value("inventory","hotbar",[])
		if saved_hotbar is Array:
			for i in range(mini(6,saved_hotbar.size())): lobby_hotbar[i]=str(saved_hotbar[i])
		cheat_mode=bool(cfg.get_value("game","cheat",false))
		gj_balance=int(cfg.get_value("currency","gj",9999 if cheat_mode else 0))

func _save_lobby_state():
	var cfg=ConfigFile.new()
	cfg.load("user://player.cfg")
	cfg.set_value("inventory","crafted",lobby_inventory)
	cfg.set_value("inventory","store_cards",store_cards)
	cfg.set_value("inventory","hotbar",lobby_hotbar)
	cfg.set_value("game","cheat",cheat_mode)
	cfg.set_value("currency","gj",gj_balance)
	cfg.set_value("inventory","crafted",lobby_inventory)
	cfg.set_value("inventory","store_cards",store_cards)
	cfg.set_value("inventory","hotbar",lobby_hotbar)
	cfg.save("user://player.cfg")

func _rarity_name(rarity:String) -> String:
	match rarity:
		"gray","gumus": return "Gümüş"
		"green","yesil": return "Zehir"
		"blue","buz": return "Buz"
		"orange","gunes": return "Güneş"
		"red","lav": return "Lav"
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
		var item_name=str(parts[0]); var rarity=str(parts[1])
		var title="%s %s" % [_rarity_name(rarity),item_name]
		var cell=VBoxContainer.new(); cell.custom_minimum_size=Vector2(128,148)
		var frame=Panel.new(); frame.custom_minimum_size=Vector2(128,104)
		if str(key) in lobby_hotbar:
			var st=StyleBoxFlat.new(); st.bg_color=Color(.08,.55,.16,.24); st.border_color=Color(.18,1.0,.32,.95); st.set_border_width_all(3); frame.add_theme_stylebox_override("panel",st)
		cell.add_child(frame)
		var image=TextureButton.new(); image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); image.ignore_texture_size=true; image.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		var row=STORE_WEAPON_NAMES.find(item_name)+1
		if row>0: image.texture_normal=_store_png_texture("res://weapon%d%s.png" % [row,rarity])
		image.pressed.connect(_equip_lobby_item.bind(str(key)))
		frame.add_child(image)
		var name=Button.new(); name.custom_minimum_size=Vector2(128,38); name.text=title+"  "+str(count)+"x"; name.clip_text=true; name.add_theme_font_size_override("font_size",_fit_store_name_font(name.text)); name.pressed.connect(_equip_lobby_item.bind(str(key))); cell.add_child(name)
		grid.add_child(cell); shown+=1
	if shown==0:
		var empty=Label.new(); empty.text="ENVANTER BOŞ"; empty.custom_minimum_size=Vector2(650,60); empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; empty.add_theme_font_size_override("font_size",20); grid.add_child(empty)

func _equip_lobby_item(key:String):
	var at=lobby_hotbar.find(key)
	if at>=0: lobby_hotbar[at]=""
	else:
		var target=lobby_hotbar.find("")
		if target<0: target=0
		lobby_hotbar[target]=key
	_save_lobby_state()
	_refresh_lobby_inventory()

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
	if opening: _show_store_category(store_category)

func _build_store():
	store_panel=Panel.new(); store_panel.set_anchors_preset(Control.PRESET_CENTER); store_panel.position=Vector2(-390,-290); store_panel.size=Vector2(780,580); add_child(store_panel)
	var title=Label.new(); title.text="MAĞAZA"; title.position=Vector2(20,12); title.size=Vector2(500,38); title.add_theme_font_size_override("font_size",26); store_panel.add_child(title)
	var balance=Label.new(); balance.name="GJBalance"; balance.position=Vector2(520,15); balance.size=Vector2(165,34); balance.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT; balance.add_theme_font_size_override("font_size",19); store_panel.add_child(balance)
	var close=Button.new(); close.text="✕"; close.position=Vector2(712,10); close.size=Vector2(50,38); close.pressed.connect(_toggle_store); store_panel.add_child(close)
	var categories=["TÜMÜ","SİLAH","ZIRH","KART AL"]
	for i in categories.size():
		var btn=Button.new(); btn.text=categories[i]; btn.position=Vector2(20+i*185,68); btn.size=Vector2(170,48); btn.add_theme_font_size_override("font_size",18); btn.name="Category_"+str(i); btn.pressed.connect(_show_store_category.bind(categories[i])); store_panel.add_child(btn)
	_show_store_category("TÜMÜ"); store_panel.visible=false

func _fit_store_name_font(t:String)->int:
	if t.length()>25: return 8
	if t.length()>20: return 9
	if t.length()>15: return 10
	return 12

func _show_store_category(category:String):
	if store_panel==null: return
	store_category=category
	var bal=store_panel.get_node_or_null("GJBalance")
	if bal: bal.text=str(gj_balance)+" GJ"
	var old=store_panel.get_node_or_null("CategoryItems")
	if old: old.free()
	var scroll=ScrollContainer.new()
	scroll.name="CategoryItems"
	scroll.position=Vector2(20,130)
	scroll.size=Vector2(740,425)
	scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	store_panel.add_child(scroll)
	var grid=GridContainer.new()
	grid.columns=5
	grid.custom_minimum_size=Vector2(720,0)
	grid.add_theme_constant_override("h_separation",8)
	grid.add_theme_constant_override("v_separation",14)
	scroll.add_child(grid)
	if category=="ZIRH":
		var empty=Label.new()
		empty.text="ZIRH ÜRÜNLERİ DAHA SONRA EKLENECEK"
		empty.custom_minimum_size=Vector2(720,80)
		empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		grid.add_child(empty)
		return
	if category=="KART AL":
		for col in 5:
			var variant=STORE_WEAPON_VARIANTS[col]
			var card_cell=VBoxContainer.new()
			card_cell.custom_minimum_size=Vector2(136,158)
			var card=TextureButton.new()
			card.custom_minimum_size=Vector2(136,104)
			card.ignore_texture_size=true
			card.stretch_mode=TextureButton.STRETCH_SCALE
			card.texture_normal=_store_png_texture(STORE_SLOT_BG[col])
			card.pressed.connect(_open_store_preview.bind("card",0,variant))
			card_cell.add_child(card)
			var cb=Button.new()
			cb.text="%s Kart • %d GJ" % [STORE_VARIANT_NAMES[col],CARD_PRICE_GJ]
			cb.custom_minimum_size=Vector2(136,42)
			cb.clip_text=true
			cb.add_theme_font_size_override("font_size",10)
			cb.pressed.connect(_open_store_preview.bind("card",0,variant))
			card_cell.add_child(cb)
			grid.add_child(card_cell)
		return
	for i in 40:
		var row=int(i/5)+1
		var col=i%5
		var variant=STORE_WEAPON_VARIANTS[col]
		var product_name="%s %s" % [STORE_VARIANT_NAMES[col],STORE_WEAPON_NAMES[row-1]]
		var cell=VBoxContainer.new()
		cell.custom_minimum_size=Vector2(136,166)
		cell.add_theme_constant_override("separation",4)
		var picture=Control.new()
		picture.custom_minimum_size=Vector2(136,104)
		picture.clip_contents=true
		var bg=TextureRect.new()
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		bg.texture=_store_png_texture(STORE_SLOT_BG[col])
		bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode=TextureRect.STRETCH_SCALE
		bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
		picture.add_child(bg)
		var image=TextureButton.new()
		image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		image.ignore_texture_size=true
		image.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		image.texture_normal=_store_png_texture("res://weapon%d%s.png" % [row,variant])
		image.pressed.connect(_open_store_preview.bind("weapon",row,variant))
		picture.add_child(image)
		cell.add_child(picture)
		var name_area=Control.new()
		name_area.custom_minimum_size=Vector2(136,46)
		name_area.clip_contents=true
		var name_bg=TextureButton.new()
		name_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		name_bg.ignore_texture_size=true
		name_bg.stretch_mode=TextureButton.STRETCH_SCALE
		name_bg.texture_normal=_store_png_texture(STORE_SLOT_BG[col])
		name_bg.pressed.connect(_open_store_preview.bind("weapon",row,variant))
		name_area.add_child(name_bg)
		var label=Label.new()
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.text=product_name
		label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size",_fit_store_name_font(product_name))
		label.add_theme_color_override("font_color",Color.WHITE)
		label.add_theme_color_override("font_shadow_color",Color.BLACK)
		label.add_theme_constant_override("shadow_offset_x",1)
		label.add_theme_constant_override("shadow_offset_y",1)
		label.mouse_filter=Control.MOUSE_FILTER_IGNORE
		name_area.add_child(label)
		cell.add_child(name_area)
		grid.add_child(cell)

func _store_weapon_glb_path(row:int,variant:String) -> String:
	if row<1 or row>STORE_WEAPON_NAMES.size(): return ""
	var rarity=variant
	if rarity=="yesil": rarity="zehir"
	var names=["bicak","karambit","kilic","buyuk_kilic","katana","pompali","cift_pompali","nisanci"]
	return "res://assets/weapons3d/%s_%s.glb" % [rarity,names[row-1]]

func _open_weapon_inspector(row:int,variant:String):
	if weapon_inspect_panel: weapon_inspect_panel.free()
	weapon_inspect_spin=Vector2.ZERO
	weapon_inspect_zoom=1.0
	weapon_inspect_panel=Panel.new()
	weapon_inspect_panel.position=Vector2(70,35)
	weapon_inspect_panel.size=Vector2(640,510)
	weapon_inspect_panel.z_index=100
	store_preview.add_child(weapon_inspect_panel)
	var title=Label.new(); title.text="%s %s • 3D İNCELEME" % [_rarity_name(variant),STORE_WEAPON_NAMES[row-1]]; title.position=Vector2(18,8); title.size=Vector2(520,34); title.add_theme_font_size_override("font_size",20); weapon_inspect_panel.add_child(title)
	var close=Button.new(); close.text="✕"; close.position=Vector2(574,6); close.size=Vector2(48,38); close.pressed.connect(_close_weapon_inspector); weapon_inspect_panel.add_child(close)
	var sub=SubViewport.new(); sub.size=Vector2i(600,390); sub.transparent_bg=false; sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS; weapon_inspect_panel.add_child(sub)
	var world=Node3D.new(); sub.add_child(world)
	var env=WorldEnvironment.new(); var e=Environment.new(); e.background_mode=Environment.BG_COLOR; e.background_color=Color(.055,.065,.08); e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color=Color.WHITE; e.ambient_light_energy=1.2; env.environment=e; world.add_child(env)
	var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-30,0); light.light_energy=2.2; world.add_child(light)
	var cam=Camera3D.new(); cam.position=Vector3(0,0,3.2); cam.look_at_from_position(cam.position,Vector3.ZERO); world.add_child(cam)
	var path=_store_weapon_glb_path(row,variant)
	if ResourceLoader.exists(path):
		var packed=load(path)
		if packed is PackedScene:
			weapon_inspect_model=packed.instantiate()
			world.add_child(weapon_inspect_model)
			weapon_inspect_model.position=Vector3.ZERO
			weapon_inspect_model.rotation_degrees=Vector3(0,-25,0)
			_fit_weapon_inspector_model()
	else:
		var missing=Label.new(); missing.text="3D DOSYA BULUNAMADI"; missing.position=Vector2(200,220); weapon_inspect_panel.add_child(missing)
	var view=TextureRect.new(); view.position=Vector2(20,48); view.size=Vector2(600,390); view.texture=sub.get_texture(); view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; view.mouse_filter=Control.MOUSE_FILTER_IGNORE; weapon_inspect_panel.add_child(view)
	var buttons=[["←",Vector2(92,452),Vector2(-1,0)],["→",Vector2(158,452),Vector2(1,0)],["↑",Vector2(224,452),Vector2(0,-1)],["↓",Vector2(290,452),Vector2(0,1)]]
	for data in buttons:
		var b=Button.new(); b.text=data[0]; b.position=data[1]; b.size=Vector2(58,42); b.add_theme_font_size_override("font_size",22); b.button_down.connect(_inspect_spin_start.bind(data[2])); b.button_up.connect(_inspect_spin_stop); weapon_inspect_panel.add_child(b)
	var stop=Button.new(); stop.text="STOP"; stop.position=Vector2(356,452); stop.size=Vector2(72,42); stop.pressed.connect(_inspect_spin_stop); weapon_inspect_panel.add_child(stop)
	var zoom_in=Button.new(); zoom_in.text="+"; zoom_in.position=Vector2(436,452); zoom_in.size=Vector2(58,42); zoom_in.add_theme_font_size_override("font_size",22); zoom_in.pressed.connect(_inspect_zoom.bind(1.18)); weapon_inspect_panel.add_child(zoom_in)
	var zoom_out=Button.new(); zoom_out.text="−"; zoom_out.position=Vector2(502,452); zoom_out.size=Vector2(58,42); zoom_out.add_theme_font_size_override("font_size",22); zoom_out.pressed.connect(_inspect_zoom.bind(0.85)); weapon_inspect_panel.add_child(zoom_out)

func _fit_weapon_inspector_model():
	if weapon_inspect_model==null: return
	var meshes:Array[MeshInstance3D]=[]
	_collect_inspect_meshes(weapon_inspect_model,meshes)
	if meshes.is_empty(): return
	var merged:AABB
	var first=true
	for mi in meshes:
		var box=mi.get_aabb()
		var gt=weapon_inspect_model.global_transform.affine_inverse()*mi.global_transform
		var wb=gt*box
		if first: merged=wb; first=false
		else: merged=merged.merge(wb)
	var longest=maxf(merged.size.x,maxf(merged.size.y,merged.size.z))
	if longest<=0.0001: return
	var s=2.35/longest
	weapon_inspect_model.scale=Vector3.ONE*s
	weapon_inspect_model.position=-(merged.get_center()*s)

func _collect_inspect_meshes(node:Node,out:Array[MeshInstance3D]):
	if node is MeshInstance3D: out.append(node)
	for child in node.get_children(): _collect_inspect_meshes(child,out)

func _inspect_spin_start(dir:Vector2):
	weapon_inspect_spin=dir

func _inspect_spin_stop():
	weapon_inspect_spin=Vector2.ZERO

func _inspect_zoom(factor:float):
	if weapon_inspect_model==null: return
	weapon_inspect_zoom=clampf(weapon_inspect_zoom*factor,0.55,2.2)
	weapon_inspect_model.scale*=factor
	var length=weapon_inspect_model.scale.length()
	if length>4.0: weapon_inspect_model.scale=weapon_inspect_model.scale.normalized()*4.0

func _process(delta:float):
	if weapon_inspect_model!=null and weapon_inspect_spin!=Vector2.ZERO:
		weapon_inspect_model.rotate_y(-weapon_inspect_spin.x*delta*1.6)
		weapon_inspect_model.rotate_x(-weapon_inspect_spin.y*delta*1.6)

func _close_weapon_inspector():
	if weapon_inspect_panel:
		weapon_inspect_panel.free()
		weapon_inspect_panel=null
		weapon_inspect_model=null

func _open_store_preview(kind:String,row:int,variant:String):
	preview_kind=kind
	preview_row=row
	preview_variant=variant
	preview_quantity=1
	if store_preview: store_preview.free()
	for child in store_panel.get_children():
		child.visible=false
	store_preview=Panel.new()
	store_preview.name="StorePreview"
	store_preview.position=Vector2.ZERO
	store_preview.size=Vector2(780,580)
	store_preview.z_index=50
	store_panel.add_child(store_preview)
	var close=Button.new()
	close.text="✕"
	close.position=Vector2(708,12)
	close.size=Vector2(52,42)
	close.pressed.connect(_close_store_preview)
	store_preview.add_child(close)
	var title=Label.new()
	title.position=Vector2(24,16)
	title.size=Vector2(650,40)
	title.add_theme_font_size_override("font_size",24)
	store_preview.add_child(title)
	var pic_frame=Control.new()
	pic_frame.position=Vector2(140,62)
	pic_frame.size=Vector2(500,245)
	pic_frame.clip_contents=true
	store_preview.add_child(pic_frame)
	var variant_index=STORE_WEAPON_VARIANTS.find(variant)
	var pic_bg=TextureRect.new()
	pic_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pic_bg.texture=_store_png_texture(STORE_SLOT_BG[variant_index])
	pic_bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	pic_bg.stretch_mode=TextureRect.STRETCH_SCALE
	pic_bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
	pic_frame.add_child(pic_bg)
	var pic=TextureRect.new()
	pic.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pic.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
	pic.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	pic_frame.add_child(pic)
	if kind=="weapon":
		title.text="%s %s" % [_rarity_name(variant),STORE_WEAPON_NAMES[row-1]]
		pic.texture=_store_png_texture("res://weapon%d%s.png" % [row,variant])
		var dmg=Label.new()
		dmg.text="Normal Hasar: 0     Özel Hasar: 0"
		dmg.position=Vector2(140,312)
		dmg.size=Vector2(500,28)
		dmg.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		dmg.add_theme_font_size_override("font_size",18)
		store_preview.add_child(dmg)
		var inspect=Button.new()
		inspect.text="3D İNCELE"
		inspect.position=Vector2(580,308)
		inspect.size=Vector2(150,40)
		inspect.add_theme_font_size_override("font_size",16)
		inspect.pressed.connect(_open_weapon_inspector.bind(row,variant))
		store_preview.add_child(inspect)
	else:
		title.text="%s Kart" % _rarity_name(variant)
		pic.texture=_store_png_texture(STORE_SLOT_BG[variant_index])
	var quick_values=[10,20,40,80,99]
	for i in quick_values.size():
		var q=Button.new()
		q.text=str(quick_values[i])
		q.position=Vector2(150+i*98,350)
		q.size=Vector2(82,38)
		q.pressed.connect(_set_preview_quantity.bind(quick_values[i]))
		store_preview.add_child(q)
	preview_slider=HSlider.new()
	preview_slider.position=Vector2(150,395)
	preview_slider.size=Vector2(474,34)
	preview_slider.min_value=1
	preview_slider.max_value=99
	preview_slider.step=1
	preview_slider.value=1
	preview_slider.value_changed.connect(_preview_slider_changed)
	store_preview.add_child(preview_slider)
	var minus=Button.new()
	minus.text="−"
	minus.position=Vector2(150,438)
	minus.size=Vector2(72,52)
	minus.add_theme_font_size_override("font_size",26)
	minus.pressed.connect(_change_preview_quantity.bind(-1))
	store_preview.add_child(minus)
	preview_qty_label=Label.new()
	preview_qty_label.position=Vector2(230,438)
	preview_qty_label.size=Vector2(120,52)
	preview_qty_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	preview_qty_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	preview_qty_label.add_theme_font_size_override("font_size",22)
	store_preview.add_child(preview_qty_label)
	var plus=Button.new()
	plus.text="+"
	plus.position=Vector2(358,438)
	plus.size=Vector2(72,52)
	plus.add_theme_font_size_override("font_size",26)
	plus.pressed.connect(_change_preview_quantity.bind(1))
	store_preview.add_child(plus)
	preview_cost_label=Label.new()
	preview_cost_label.position=Vector2(24,510)
	preview_cost_label.size=Vector2(470,48)
	preview_cost_label.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
	preview_cost_label.add_theme_font_size_override("font_size",17)
	store_preview.add_child(preview_cost_label)
	var buy=Button.new()
	buy.name="BuyButton"
	buy.position=Vector2(540,506)
	buy.size=Vector2(200,52)
	buy.pressed.connect(_confirm_preview_purchase)
	store_preview.add_child(buy)
	_update_preview_cost()

func _close_store_preview():
	if weapon_inspect_panel: _close_weapon_inspector()
	if store_preview:
		store_preview.free()
		store_preview=null
	for child in store_panel.get_children():
		child.visible=true
	_show_store_category(store_category)

func _set_preview_quantity(value:int):
	preview_quantity=clampi(value,1,99)
	if preview_slider: preview_slider.set_value_no_signal(preview_quantity)
	_update_preview_cost()

func _preview_slider_changed(value:float):
	preview_quantity=clampi(int(round(value)),1,99)
	_update_preview_cost()

func _change_preview_quantity(delta:int):
	preview_quantity=clampi(preview_quantity+delta,1,99)
	if preview_slider: preview_slider.set_value_no_signal(preview_quantity)
	_update_preview_cost()

func _update_preview_cost():
	if preview_qty_label==null or preview_cost_label==null: return
	preview_qty_label.text=str(preview_quantity)+"x"
	var buy=store_preview.get_node_or_null("BuyButton")
	if preview_kind=="card":
		var total=preview_quantity*CARD_PRICE_GJ
		preview_cost_label.text="Toplam: %d GJ" % total
		if buy: buy.text="SATIN AL"
	else:
		var each=STORE_WEAPON_COSTS[preview_row-1]
		var total_cards=each*preview_quantity
		preview_cost_label.text="Gerekli: %d %s Kart" % [total_cards,_rarity_name(preview_variant)]
		if buy: buy.text="ÜRET"

func _confirm_preview_purchase():
	if preview_kind=="card":
		var total=preview_quantity*CARD_PRICE_GJ
		if gj_balance<total: _preview_message("YETERSİZ GJ"); return
		gj_balance-=total; store_cards[preview_variant]=int(store_cards.get(preview_variant,0))+preview_quantity
	else:
		var needed=STORE_WEAPON_COSTS[preview_row-1]*preview_quantity
		if int(store_cards.get(preview_variant,0))<needed: _preview_message("YETERSİZ %s KART" % _rarity_name(preview_variant)); return
		store_cards[preview_variant]=int(store_cards.get(preview_variant,0))-needed
		var key="%s|%s" % [STORE_WEAPON_NAMES[preview_row-1],preview_variant]
		lobby_inventory[key]=int(lobby_inventory.get(key,0))+preview_quantity
	_save_lobby_state(); _update_lobby_currency()
	var bal=store_panel.get_node_or_null("GJBalance"); if bal: bal.text=str(gj_balance)+" GJ"
	_preview_message("SATIN ALINDI" if preview_kind=="card" else "ÜRETİLDİ")

func _preview_message(t:String):
	if preview_cost_label: preview_cost_label.text=t

func _enter_game():
	_save_lobby_state()
	var cfg=ConfigFile.new()
	cfg.load("user://player.cfg")
	cfg.set_value("player","character",selected_character)
	cfg.set_value("game","map",selected_map)
	cfg.set_value("game","cheat",cheat_mode)
	cfg.set_value("currency","gj",gj_balance)
	cfg.save("user://player.cfg")
	get_tree().change_scene_to_file.call_deferred("res://scenes/Main.tscn")

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode==KEY_ENTER:
		_enter_game()
