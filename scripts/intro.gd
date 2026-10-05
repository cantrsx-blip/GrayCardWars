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
var weapon_inspect_base_scale := Vector3.ONE
var weapon_inspect_auto_spin := true
var weapon_inspect_stop_button: Button

# Lobby-only Meshy character calibration studio. It never replaces the gameplay Y Bot.
var character_control_panel: Panel
var character_control_model: Node3D
var character_control_skeleton: Skeleton3D
var character_control_anim: AnimationPlayer
var character_control_weapon: Node3D
var character_control_weapon_index := 0
var character_control_variant := "gumus"
var character_control_weapon_pos := Vector3.ZERO
var character_control_weapon_rot := Vector3.ZERO
var character_control_muzzle_pos := Vector3(0,0,0.55)
var character_control_weapon_presets := {
	0: {"pos":Vector3(0.18,0.08,0.02),"rot":Vector3(0,0,0)},
	1: {"pos":Vector3(0.08,0.06,0.10),"rot":Vector3(-345,310,15)},
	2: {"pos":Vector3(0.26,0.06,0.04),"rot":Vector3(0,0,0)},
	3: {"pos":Vector3(0.46,0.10,0.20),"rot":Vector3(185,-15,-10)},
	4: {"pos":Vector3(0.36,0.06,0.06),"rot":Vector3(190,-5,0)}
}
var character_control_status: Label
var character_control_anim_name := "Running"
var character_control_base_scale := Vector3.ONE
var character_control_zoom := 1.0
var character_control_spin := Vector2.ZERO
var character_control_auto_spin := false
var character_control_lobby_hidden:Array[CanvasItem]=[]
var character_control_motion_index := -1
var character_control_motion_time := 0.0
var character_control_base_y := 0.0
var character_control_motion_names := [
	"Normal bekleme","Yürüme","Koşma","Depar / hızlı koşma","Geri geri yürüme","Geri geri koşma","Sağa strafe","Sola strafe","Koşarken sağa/sola dönüş","Ani 180° dönüş","Dönüşlerde gövdenin yana yatması","Zıplama","Koşarak zıplama","Havada bekleme/düşüş pozu","Havada yön değiştirme","Normal iniş","Sert iniş","Yüksekten düşme tepkisi","Çömelme","Çömelerek yürüme","Çömelerek geri gitme","Çömelerek sağa/sola hareket","Çömelerek nişan alma","Çömelerek ateş etme","Ayağa kalkma geçişi","Kamera yönüne kafa çevirme","Hedefe kafa çevirme","Üst gövdeyi hedefe döndürme","Yukarı/aşağı nişan alma","Yürürken nişan alma","Koşarken silah taşıma","Geri giderken nişan alma","Strafe yaparken hedefte kalma","Zıplarken silah tutma","Zıplarken ateş etme","Tabanca/tüfek tipi silah tutuşu","Pompalı tutuşu","Çift namlulu tutuşu","Sniper tutuşu","İki elle ateşli silah tutma","Sol eli silahın ön kısmına kilitleme","Silahı omuza hizalama","Dürbüne kafa/göz hizalama","Normal ateş geri tepmesi","Pompalı güçlü geri tepmesi","Sniper güçlü geri tepmesi","Ateş sonrası toparlanma","Silah değiştirme hareketi","Bıçak bekleme duruşu","Bıçak saldırısı","Farklı bıçak saldırı açıları","Kılıç bekleme duruşu","Kılıç saldırısı","Farklı kılıç savurma açıları","Koşarak yakın dövüş saldırısı","Yakın dövüş combo sistemi","VUR → 1 → 2 → 3 saldırı zinciri","Saldırı sırasında hedefe dönme","Hafif hasar tepkisi","Ağır hasar tepkisi","Önden vurulma tepkisi","Arkadan vurulma tepkisi","Sağdan/soldan vurulma tepkisi","Sendeleme","Dengeyi toparlama","Ölüm animasyonu","Skill/Yetenek hareketi","Koşarken Skill kullanma geçişi","Yorgunluk hareketi","Boşta başını etrafa çevirme","Ağırlığı bir bacaktan diğerine verme","Nefes alma/gövde mikro hareketleri","Eğimli zemine göre ayak basışı","Merdiven/engel yüksekliğine göre otomatik adım","Küçük engellerin üzerinden otomatik atlama","Duvara/engele çarpınca hareket tepkisi","Hareket hızına göre adım ve animasyon hızını eşleme","Yürümeden koşmaya yumuşak geçiş","Koşmadan durmaya yumuşak geçiş","Animasyonlar arasında yumuşak blend/geçiş","Alt gövde hareket ederken üst gövdenin bağımsız nişan alması","Ayakların zeminde kaymasını azaltma","Silahın elde kaymasını azaltma","Eller için IK","Ayaklar için IK","Silah hedefleme IK","Vurulan bölgeye göre kemik tepkisi","Ragdoll ölüm sistemi","Ragdoll'dan kontrollü fizik tepkileri","NPC'lerin aynı hareket sistemini kullanabilmesi"
]

const STORE_WEAPON_VARIANTS := ["gumus","yesil","buz","gunes","lav"]
const STORE_VARIANT_NAMES := ["Gümüş","Zehir","Buz","Güneş","Lav"]
const STORE_WEAPON_NAMES := ["Bıçak","Karambit","Kılıç","Büyük Kılıç","Katana","Pompalı Tüfek","Çift Namlulu Pompalı","Keskin Nişancı Tüfeği"]
const STORE_WEAPON_COSTS := [2,4,8,16,32,64,128,256]
const CARD_PRICE_GJ := 2
const STORE_SLOT_BG := ["res://gumus.png","res://zehir.png","res://buz.jpg","res://gunes.png","res://lav.png"]

const CHARACTERS := ["KAYA", "S.A.Z", "AKREP", "KARAKTER 2"]
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

	var control_button=Button.new()
	control_button.text="KARAKTER KONTROL"
	control_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	control_button.position=Vector2(-195,194)
	control_button.size=Vector2(175,48)
	control_button.add_theme_font_size_override("font_size",16)
	control_button.pressed.connect(_toggle_character_control)
	add_child(control_button)
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
	weapon_inspect_auto_spin=true
	weapon_inspect_zoom=2.2
	weapon_inspect_panel=Panel.new()
	weapon_inspect_panel.position=Vector2(70,35)
	weapon_inspect_panel.size=Vector2(640,510)
	weapon_inspect_panel.z_index=100
	store_preview.add_child(weapon_inspect_panel)
	var title=Label.new(); title.text="%s %s • 3D İNCELEME" % [_rarity_name(variant),STORE_WEAPON_NAMES[row-1]]; title.position=Vector2(18,8); title.size=Vector2(520,34); title.add_theme_font_size_override("font_size",20); weapon_inspect_panel.add_child(title)
	var close=Button.new(); close.text="✕"; close.position=Vector2(574,6); close.size=Vector2(48,38); close.pressed.connect(_close_weapon_inspector); weapon_inspect_panel.add_child(close)
	var sub=SubViewport.new(); sub.size=Vector2i(600,390); sub.transparent_bg=true; sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS; weapon_inspect_panel.add_child(sub)
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
	var bg=TextureRect.new(); bg.position=Vector2(20,48); bg.size=Vector2(600,390); var vi=STORE_WEAPON_VARIANTS.find(variant); bg.texture=_store_png_texture(STORE_SLOT_BG[vi]); bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; bg.stretch_mode=TextureRect.STRETCH_SCALE; bg.mouse_filter=Control.MOUSE_FILTER_IGNORE; weapon_inspect_panel.add_child(bg)
	var detail=TextureRect.new(); detail.position=Vector2(20,48); detail.size=Vector2(600,390); detail.texture=_store_png_texture("res://weapon%d%s.png" % [row,variant]); detail.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; detail.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; detail.mouse_filter=Control.MOUSE_FILTER_IGNORE; weapon_inspect_panel.add_child(detail)
	var view=TextureRect.new(); view.position=Vector2(20,48); view.size=Vector2(600,390); view.texture=sub.get_texture(); view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; view.mouse_filter=Control.MOUSE_FILTER_IGNORE; weapon_inspect_panel.add_child(view)
	var buttons=[["←",Vector2(92,452),Vector2(-1,0)],["→",Vector2(158,452),Vector2(1,0)],["↑",Vector2(224,452),Vector2(0,-1)],["↓",Vector2(290,452),Vector2(0,1)]]
	for data in buttons:
		var b=Button.new(); b.text=data[0]; b.position=data[1]; b.size=Vector2(58,42); b.add_theme_font_size_override("font_size",22); b.button_down.connect(_inspect_spin_start.bind(data[2])); b.button_up.connect(_inspect_manual_spin_stop); weapon_inspect_panel.add_child(b)
	var stop=Button.new(); weapon_inspect_stop_button=stop; stop.text="STOP"; stop.position=Vector2(356,452); stop.size=Vector2(72,42); stop.pressed.connect(_inspect_toggle_auto_spin); weapon_inspect_panel.add_child(stop)
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
	var s=2.75/longest
	weapon_inspect_base_scale=Vector3.ONE*s
	weapon_inspect_model.scale=weapon_inspect_base_scale*weapon_inspect_zoom
	weapon_inspect_model.position=-(merged.get_center()*s)

func _collect_inspect_meshes(node:Node,out:Array[MeshInstance3D]):
	if node is MeshInstance3D: out.append(node)
	for child in node.get_children(): _collect_inspect_meshes(child,out)

func _inspect_spin_start(dir:Vector2):
	weapon_inspect_spin=dir

func _inspect_manual_spin_stop():
	weapon_inspect_spin=Vector2.ZERO

func _inspect_toggle_auto_spin():
	weapon_inspect_auto_spin=not weapon_inspect_auto_spin
	if weapon_inspect_stop_button:
		weapon_inspect_stop_button.text="STOP" if weapon_inspect_auto_spin else "START"

func _inspect_zoom(factor:float):
	if weapon_inspect_model==null: return
	weapon_inspect_zoom=clampf(weapon_inspect_zoom*factor,0.55,2.2)
	weapon_inspect_model.scale=weapon_inspect_base_scale*weapon_inspect_zoom

func _process(delta:float):
	if character_control_model!=null:
		_character_control_process_motion(delta)
		if character_control_auto_spin: character_control_model.rotate_y(delta)
		if character_control_spin!=Vector2.ZERO:
			character_control_model.rotate_y(-character_control_spin.x*delta*1.6)
			character_control_model.rotate_x(-character_control_spin.y*delta*1.6)
	if weapon_inspect_model!=null:
		if weapon_inspect_auto_spin:
			weapon_inspect_model.rotate_y(delta*1.0)
		if weapon_inspect_spin!=Vector2.ZERO:
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


func _toggle_character_control():
	if character_control_panel==null:
		_build_character_control()
	_character_control_set_studio(not character_control_panel.visible)

func _character_control_set_studio(opening:bool):
	if character_control_panel==null: return
	character_control_panel.visible=opening
	if opening:
		character_control_lobby_hidden.clear()
		for child in get_children():
			if child is CanvasItem and child!=character_control_panel and child.visible:
				character_control_lobby_hidden.append(child)
				child.visible=false
		character_control_panel.visible=true
	else:
		for item in character_control_lobby_hidden:
			if is_instance_valid(item): item.visible=true
		character_control_lobby_hidden.clear()

func _build_character_control():
	character_control_panel=Panel.new()
	character_control_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	character_control_panel.position=Vector2.ZERO
	character_control_panel.size=Vector2.ZERO
	character_control_panel.z_index=250
	add_child(character_control_panel)

	var title=Label.new(); title.text="KARAKTER KONTROL • MESHY TEST"; title.position=Vector2(18,10); title.size=Vector2(600,34); title.add_theme_font_size_override("font_size",22); character_control_panel.add_child(title)
	var close=Button.new(); close.text="KARAKTER KONTROLDEN ÇIK"; close.position=Vector2(1260,14); close.size=Vector2(250,44); close.pressed.connect(_toggle_character_control); character_control_panel.add_child(close)

	var selected_motion=Label.new(); selected_motion.name="SelectedMotion"; selected_motion.position=Vector2(790,66); selected_motion.size=Vector2(720,52); selected_motion.text="HAREKET SEÇİLMEDİ"; selected_motion.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; selected_motion.add_theme_font_size_override("font_size",16); character_control_panel.add_child(selected_motion)
	var motion_scroll=ScrollContainer.new(); motion_scroll.position=Vector2(790,126); motion_scroll.size=Vector2(720,430); character_control_panel.add_child(motion_scroll)
	var motion_grid=GridContainer.new(); motion_grid.name="MotionGrid"; motion_grid.columns=10; motion_grid.custom_minimum_size=Vector2(690,390); motion_scroll.add_child(motion_grid)
	for i in range(90):
		var mb=Button.new(); mb.text=str(i+1); mb.custom_minimum_size=Vector2(62,36); mb.pressed.connect(_character_control_select_motion.bind(i)); motion_grid.add_child(mb)

	var sub=SubViewport.new(); sub.size=Vector2i(470,400); sub.transparent_bg=false; sub.render_target_update_mode=SubViewport.UPDATE_ALWAYS; character_control_panel.add_child(sub)
	var world=Node3D.new(); sub.add_child(world)
	var env=WorldEnvironment.new(); var e=Environment.new(); e.background_mode=Environment.BG_COLOR; e.background_color=Color(.035,.04,.05); e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR; e.ambient_light_color=Color.WHITE; e.ambient_light_energy=1.35; env.environment=e; world.add_child(env)
	var light=DirectionalLight3D.new(); light.rotation_degrees=Vector3(-35,-25,0); light.light_energy=2.4; world.add_child(light)
	var cam=Camera3D.new(); cam.position=Vector3(0,1.05,3.5); cam.look_at_from_position(cam.position,Vector3(0,1.0,0)); world.add_child(cam)

	var view=TextureRect.new(); view.position=Vector2(16,48); view.size=Vector2(470,400); view.texture=sub.get_texture(); view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; view.mouse_filter=Control.MOUSE_FILTER_IGNORE; character_control_panel.add_child(view)

	var rotate_buttons=[["←",Vector2(16,414),Vector2(-1,0)],["→",Vector2(76,414),Vector2(1,0)],["↑",Vector2(136,414),Vector2(0,-1)],["↓",Vector2(196,414),Vector2(0,1)]]
	for data in rotate_buttons:
		var rb=Button.new(); rb.text=data[0]; rb.position=data[1]; rb.size=Vector2(54,34); rb.button_down.connect(_character_control_spin_start.bind(data[2])); rb.button_up.connect(_character_control_spin_stop); character_control_panel.add_child(rb)
	var zin=Button.new(); zin.text="+"; zin.position=Vector2(260,414); zin.size=Vector2(54,34); zin.pressed.connect(_character_control_zoom.bind(1.15)); character_control_panel.add_child(zin)
	var zout=Button.new(); zout.text="−"; zout.position=Vector2(320,414); zout.size=Vector2(54,34); zout.pressed.connect(_character_control_zoom.bind(0.87)); character_control_panel.add_child(zout)
	var reset_view=Button.new(); reset_view.text="SIFIRLA"; reset_view.position=Vector2(380,414); reset_view.size=Vector2(86,34); reset_view.pressed.connect(_character_control_reset_view); character_control_panel.add_child(reset_view)

	var anims=[["KOŞ","Running"],["YÜRÜ","Walking"],["SALDIR","Attack"],["YETENEK","Skill_03"],["ÖL","Dead"]]
	for i in anims.size():
		var b=Button.new(); b.text=anims[i][0]; b.position=Vector2(16+i*92,456); b.size=Vector2(86,38); b.pressed.connect(_character_control_load_anim.bind(anims[i][1])); character_control_panel.add_child(b)

	var weapon_label=Label.new(); weapon_label.text="SİLAH / NAMLU KALİBRASYONU"; weapon_label.position=Vector2(500,52); weapon_label.size=Vector2(260,28); weapon_label.add_theme_font_size_override("font_size",16); character_control_panel.add_child(weapon_label)
	var prev=Button.new(); prev.text="◀"; prev.position=Vector2(500,84); prev.size=Vector2(44,38); prev.pressed.connect(_character_control_cycle_weapon.bind(-1)); character_control_panel.add_child(prev)
	var next=Button.new(); next.text="▶"; next.position=Vector2(716,84); next.size=Vector2(44,38); next.pressed.connect(_character_control_cycle_weapon.bind(1)); character_control_panel.add_child(next)
	var weapon_name=Label.new(); weapon_name.name="WeaponName"; weapon_name.position=Vector2(548,84); weapon_name.size=Vector2(164,38); weapon_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; weapon_name.vertical_alignment=VERTICAL_ALIGNMENT_CENTER; weapon_name.add_theme_font_size_override("font_size",13); character_control_panel.add_child(weapon_name)

	var labels=["SİLAH X","SİLAH Y","SİLAH Z","DÖN X","DÖN Y","DÖN Z","NAMLU X","NAMLU Y","NAMLU Z"]
	for i in labels.size():
		var row=i
		var lab=Label.new(); lab.text=labels[i]; lab.position=Vector2(500,132+row*34); lab.size=Vector2(80,30); lab.add_theme_font_size_override("font_size",12); character_control_panel.add_child(lab)
		var minus=Button.new(); minus.text="−"; minus.position=Vector2(584,130+row*34); minus.size=Vector2(48,30); minus.pressed.connect(_character_control_adjust.bind(i,-1)); character_control_panel.add_child(minus)
		var plus=Button.new(); plus.text="+"; plus.position=Vector2(638,130+row*34); plus.size=Vector2(48,30); plus.pressed.connect(_character_control_adjust.bind(i,1)); character_control_panel.add_child(plus)

	character_control_status=Label.new(); character_control_status.position=Vector2(16,505); character_control_status.size=Vector2(744,82); character_control_status.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; character_control_status.add_theme_font_size_override("font_size",12); character_control_panel.add_child(character_control_status)
	character_control_panel.set_meta("world",world)
	_character_control_load_anim("Running")
	_character_control_update_labels()

func _character_control_anim_path(anim_name:String)->String:
	var files={"Running":"res://YBot_Running_withSkin.glb","Walking":"res://YBot_Walking_withSkin.glb","Attack":"res://YBot_Attack_withSkin.glb","Skill_03":"res://YBot_Skill_03_withSkin.glb","Dead":"res://YBot_Dead_withSkin.glb"}
	return str(files.get(anim_name,""))

func _character_control_load_anim(anim_name:String):
	if character_control_panel==null: return
	var world=character_control_panel.get_meta("world") as Node3D
	if world==null: return
	if character_control_model and is_instance_valid(character_control_model): character_control_model.free()
	character_control_model=null; character_control_skeleton=null; character_control_anim=null; character_control_weapon=null
	var path=_character_control_anim_path(anim_name)
	if not ResourceLoader.exists(path):
		if character_control_status: character_control_status.text="DOSYA BULUNAMADI: "+path
		return
	var packed=load(path)
	if not packed is PackedScene: return
	character_control_model=packed.instantiate()
	world.add_child(character_control_model)
	character_control_anim_name=anim_name
	character_control_skeleton=_character_control_find_skeleton(character_control_model)
	character_control_anim=_character_control_find_anim(character_control_model)
	_character_control_fit_model()
	if character_control_anim:
		var names:Array[StringName]=[]
		for lib_name in character_control_anim.get_animation_library_list():
			var lib=character_control_anim.get_animation_library(lib_name)
			if lib:
				for an in lib.get_animation_list(): names.append(an)
		if not names.is_empty():
			var a=character_control_anim.get_animation(names[0])
			if a and anim_name!="Dead": a.loop_mode=Animation.LOOP_LINEAR
			character_control_anim.play(names[0])
	_character_control_attach_weapon()
	_character_control_update_labels()

func _character_control_find_skeleton(node:Node)->Skeleton3D:
	if node is Skeleton3D: return node as Skeleton3D
	for child in node.get_children():
		var found=_character_control_find_skeleton(child)
		if found: return found
	return null

func _character_control_find_anim(node:Node)->AnimationPlayer:
	if node is AnimationPlayer: return node as AnimationPlayer
	for child in node.get_children():
		var found=_character_control_find_anim(child)
		if found: return found
	return null

func _character_control_fit_model():
	if character_control_model==null: return
	var meshes:Array[MeshInstance3D]=[]
	_collect_inspect_meshes(character_control_model,meshes)
	if meshes.is_empty(): return
	var merged:AABB; var first=true
	for mi in meshes:
		var gt=character_control_model.global_transform.affine_inverse()*mi.global_transform
		var box=gt*mi.get_aabb()
		if first: merged=box; first=false
		else: merged=merged.merge(box)
	var h=maxf(merged.size.y,0.001)
	var sc=1.85/h
	character_control_base_scale=Vector3.ONE*sc
	character_control_model.scale=character_control_base_scale*character_control_zoom
	character_control_model.position=Vector3(0,-merged.position.y*sc,0)
	character_control_base_y=character_control_model.position.y

func _character_control_spin_start(dir:Vector2):
	character_control_spin=dir

func _character_control_spin_stop():
	character_control_spin=Vector2.ZERO

func _character_control_zoom(factor:float):
	character_control_zoom=clampf(character_control_zoom*factor,0.45,2.5)
	if character_control_model:
		character_control_model.scale=character_control_base_scale*character_control_zoom

func _character_control_reset_view():
	character_control_zoom=1.0
	character_control_spin=Vector2.ZERO
	if character_control_model:
		character_control_model.rotation_degrees=Vector3.ZERO
		character_control_model.scale=character_control_base_scale

func _character_control_right_hand()->BoneAttachment3D:
	if character_control_skeleton==null: return null
	var old=character_control_skeleton.get_node_or_null("LobbyWeaponHand")
	if old is BoneAttachment3D: return old
	var bone=""
	for candidate in ["mixamorig_RightHand","RightHand","right_hand","hand_r","Hand.R"]:
		if character_control_skeleton.find_bone(candidate)>=0: bone=candidate; break
	if bone.is_empty(): return null
	var a=BoneAttachment3D.new(); a.name="LobbyWeaponHand"; a.bone_name=bone; character_control_skeleton.add_child(a); return a

func _character_control_attach_weapon():
	if character_control_skeleton==null: return
	var hand=_character_control_right_hand()
	if hand==null:
		if character_control_status: character_control_status.text="Sağ el kemiği bulunamadı."
		return
	for c in hand.get_children(): c.free()
	var row=character_control_weapon_index+1
	var path=_store_weapon_glb_path(row,character_control_variant)
	if not ResourceLoader.exists(path): return
	var packed=load(path)
	if not packed is PackedScene: return
	character_control_weapon=packed.instantiate()
	hand.add_child(character_control_weapon)
	var meshes:Array[MeshInstance3D]=[]; _collect_inspect_meshes(character_control_weapon,meshes)
	var merged:AABB; var first=true
	for mi in meshes:
		var gt=character_control_weapon.global_transform.affine_inverse()*mi.global_transform
		var box=gt*mi.get_aabb()
		if first: merged=box; first=false
		else: merged=merged.merge(box)
	var longest=maxf(merged.size.x,maxf(merged.size.y,merged.size.z))
	var target=[.62,.58,1.18,1.38,1.24,1.02,1.00,1.16][character_control_weapon_index]
	var sc=target/longest if longest>0.001 else .5
	character_control_weapon.scale=Vector3.ONE*sc
	character_control_weapon.position=character_control_weapon_pos-merged.get_center()*sc
	character_control_weapon.rotation_degrees=character_control_weapon_rot
	_character_control_make_muzzle_marker()

func _character_control_make_muzzle_marker():
	if character_control_weapon==null: return
	var marker=MeshInstance3D.new(); marker.name="MuzzleMarker"
	var sphere=SphereMesh.new(); sphere.radius=.035; sphere.height=.07; marker.mesh=sphere
	var mat=StandardMaterial3D.new(); mat.albedo_color=Color(1.0,.45,.05); mat.emission_enabled=true; mat.emission=Color(1.0,.18,.02); mat.emission_energy_multiplier=4.0; marker.material_override=mat
	marker.position=character_control_muzzle_pos
	character_control_weapon.add_child(marker)

func _character_control_cycle_weapon(dir:int):
	var variants=["gumus","zehir","buz","gunes","lav"]
	var vi=variants.find(character_control_variant)
	if vi<0: vi=0
	var flat=character_control_weapon_index*variants.size()+vi
	flat=posmod(flat+dir,STORE_WEAPON_NAMES.size()*variants.size())
	character_control_weapon_index=int(flat/variants.size())
	character_control_variant=variants[flat%variants.size()]
	_character_control_apply_weapon_preset()
	character_control_muzzle_pos=Vector3(0,0,.55)
	_character_control_attach_weapon()
	_character_control_update_labels()

func _character_control_apply_weapon_preset():
	if character_control_weapon_presets.has(character_control_weapon_index):
		var preset:Dictionary=character_control_weapon_presets[character_control_weapon_index]
		character_control_weapon_pos=preset["pos"]
		character_control_weapon_rot=preset["rot"]
	else:
		character_control_weapon_pos=Vector3.ZERO
		character_control_weapon_rot=Vector3.ZERO

func _character_control_adjust(axis:int,dir:int):
	var d=float(dir)
	match axis:
		0: character_control_weapon_pos.x+=.02*d
		1: character_control_weapon_pos.y+=.02*d
		2: character_control_weapon_pos.z+=.02*d
		3: character_control_weapon_rot.x+=5.0*d
		4: character_control_weapon_rot.y+=5.0*d
		5: character_control_weapon_rot.z+=5.0*d
		6: character_control_muzzle_pos.x+=.02*d
		7: character_control_muzzle_pos.y+=.02*d
		8: character_control_muzzle_pos.z+=.02*d
	_character_control_attach_weapon()
	_character_control_update_labels()

func _character_control_set_anim_speed(speed:float):
	if character_control_anim: character_control_anim.speed_scale=speed

func _cc_bone(candidates:Array[String])->int:
	if character_control_skeleton==null: return -1
	for name in candidates:
		var idx=character_control_skeleton.find_bone(name)
		if idx>=0: return idx
	return -1

func _cc_rotate_bone(candidates:Array[String],deg:Vector3,weight:float=1.0):
	var idx=_cc_bone(candidates)
	if idx<0: return
	var base=character_control_skeleton.get_bone_pose_rotation(idx)
	var add=Quaternion.from_euler(Vector3(deg.x,deg.y,deg.z)*PI/180.0)
	character_control_skeleton.set_bone_pose_rotation(idx,base.slerp(base*add,clampf(weight,0.0,1.0)))

func _cc_pose_torso(deg:Vector3,weight:float=1.0):
	_cc_rotate_bone(["mixamorig_Spine","Spine","spine"],deg*0.35,weight)
	_cc_rotate_bone(["mixamorig_Spine1","Spine1","spine_01"],deg*0.35,weight)
	_cc_rotate_bone(["mixamorig_Spine2","Spine2","spine_02","Chest"],deg*0.30,weight)

func _cc_pose_head(deg:Vector3,weight:float=1.0):
	_cc_rotate_bone(["mixamorig_Neck","Neck","neck_01"],deg*0.35,weight)
	_cc_rotate_bone(["mixamorig_Head","Head","head"],deg*0.65,weight)

func _cc_pose_arms(right:Vector3,left:Vector3,weight:float=1.0):
	_cc_rotate_bone(["mixamorig_RightArm","RightArm","upperarm_r","UpperArm.R"],right,weight)
	_cc_rotate_bone(["mixamorig_RightForeArm","RightForeArm","lowerarm_r","ForeArm.R"],Vector3(right.x*0.55,right.y*0.25,right.z*0.35),weight)
	_cc_rotate_bone(["mixamorig_LeftArm","LeftArm","upperarm_l","UpperArm.L"],left,weight)
	_cc_rotate_bone(["mixamorig_LeftForeArm","LeftForeArm","lowerarm_l","ForeArm.L"],Vector3(left.x*0.55,left.y*0.25,left.z*0.35),weight)

func _cc_pose_legs(right:Vector3,left:Vector3,weight:float=1.0):
	_cc_rotate_bone(["mixamorig_RightUpLeg","RightUpLeg","thigh_r","UpperLeg.R"],right,weight)
	_cc_rotate_bone(["mixamorig_LeftUpLeg","LeftUpLeg","thigh_l","UpperLeg.L"],left,weight)
	_cc_rotate_bone(["mixamorig_RightLeg","RightLeg","calf_r","LowerLeg.R"],Vector3(-abs(right.x)*0.65,0,0),weight)
	_cc_rotate_bone(["mixamorig_LeftLeg","LeftLeg","calf_l","LowerLeg.L"],Vector3(-abs(left.x)*0.65,0,0),weight)

func _cc_weapon_pose(kind:int,recoil:float=0.0):
	# Layered upper-body poses: 0 generic, 1 shotgun, 2 double barrel, 3 sniper.
	var shoulder=-38.0 if kind==0 else (-46.0 if kind<3 else -52.0)
	_cc_pose_torso(Vector3(-5.0-recoil*0.18,0,0))
	_cc_pose_arms(Vector3(shoulder-recoil,4,8),Vector3(shoulder-8-recoil*0.45,-12,-12))
	if kind==3: _cc_pose_head(Vector3(-5,0,0))

func _character_control_set_anim_speed(speed:float):
	if character_control_anim: character_control_anim.speed_scale=speed

func _character_control_select_motion(index:int):
	if index<0 or index>=character_control_motion_names.size(): return
	character_control_motion_index=index
	character_control_motion_time=0.0
	var n=index+1
	var clip="Walking"
	if n in [3,4,6,7,8,9,10,11,13,15,20,21,22,30,31,32,33,34,35,55,68,74,75,77,78,79,80,81,82,83,84,85,86,90]: clip="Running"
	elif n in [24,44,45,46,47,50,51,53,54,56,57,58,59,60,61,62,63,64,65,76,87]: clip="Attack"
	elif n in [66,88,89]: clip="Dead"
	elif n in [67,68]: clip="Skill_03"
	_character_control_load_anim(clip)
	_character_control_set_anim_speed(1.0)
	if n==1 and character_control_anim: character_control_anim.pause()
	elif n==4: _character_control_set_anim_speed(1.75)
	elif n==5: _character_control_set_anim_speed(-1.0)
	elif n==6: _character_control_set_anim_speed(-1.25)
	elif n in [12,14,16,17,18,19,23,25,26,27,28,29,36,37,38,39,40,41,42,43,48,49,52,69,70,71,72,73]: _character_control_set_anim_speed(0.32)
	var box=character_control_panel.get_node_or_null("SelectedMotion") if character_control_panel else null
	if box: box.text="%d - %s" % [n,character_control_motion_names[index]]

func _character_control_process_motion(delta:float):
	if character_control_motion_index<0 or character_control_model==null: return
	character_control_motion_time+=delta
	var t=character_control_motion_time
	var n=character_control_motion_index+1
	# Each clip reload starts from its fitted base, so motion offsets are absolute and never drift.
	character_control_model.position.y=character_control_base_y
	character_control_model.rotation_degrees=Vector3.ZERO
	match n:
		1:
			pass
		4:
			character_control_model.rotation_degrees.x=-8.0
		5,6:
			pass
		7:
			character_control_model.rotation_degrees.y=-90.0
			_cc_pose_torso(Vector3(0,0,7))
		8:
			character_control_model.rotation_degrees.y=90.0
			_cc_pose_torso(Vector3(0,0,-7))
		9:
			var turn=sin(t*2.2)
			character_control_model.rotation_degrees.y=turn*38.0
			_cc_pose_torso(Vector3(0,0,-turn*12.0))
		10:
			var p=clampf(t/0.32,0.0,1.0); p=p*p*(3.0-2.0*p)
			character_control_model.rotation_degrees.y=180.0*p
		11:
			_cc_pose_torso(Vector3(0,0,sin(t*2.2)*16.0))
		12:
			character_control_model.position.y=character_control_base_y+sin(minf(t,0.72)/0.72*PI)*0.48
			_cc_pose_legs(Vector3(-22,0,0),Vector3(-22,0,0)); _cc_pose_arms(Vector3(-18,0,12),Vector3(-18,0,-12))
		13:
			character_control_model.position.y=character_control_base_y+sin(fmod(t,0.82)/0.82*PI)*0.55
			_cc_pose_torso(Vector3(-12,0,0))
		14:
			character_control_model.position.y=character_control_base_y+0.32
			_cc_pose_legs(Vector3(-18,0,5),Vector3(-8,0,-5)); _cc_pose_arms(Vector3(-20,0,18),Vector3(-20,0,-18))
		15:
			character_control_model.position.y=character_control_base_y+0.30
			character_control_model.rotation_degrees.y=sin(t*2.0)*30.0; _cc_pose_torso(Vector3(-8,sin(t*2.0)*12,0))
		16:
			var q=clampf(t/0.45,0.0,1.0); _cc_pose_legs(Vector3(-28*(1.0-q),0,0),Vector3(-28*(1.0-q),0,0))
			character_control_model.position.y=character_control_base_y+0.10*(1.0-q)
		17:
			var q=clampf(t/0.55,0.0,1.0); _cc_pose_legs(Vector3(-48*(1.0-q),0,0),Vector3(-48*(1.0-q),0,0)); _cc_pose_torso(Vector3(25*(1.0-q),0,0))
		18:
			var q=clampf(t/0.75,0.0,1.0); _cc_pose_legs(Vector3(-62*(1.0-q),0,0),Vector3(-62*(1.0-q),0,0)); _cc_pose_torso(Vector3(38*(1.0-q),0,0)); _cc_pose_arms(Vector3(-35,0,25),Vector3(-35,0,-25),1.0-q)
		19:
			_cc_pose_legs(Vector3(-48,0,0),Vector3(-48,0,0)); _cc_pose_torso(Vector3(18,0,0))
		20:
			_cc_pose_legs(Vector3(-30,0,0),Vector3(-30,0,0)); _cc_pose_torso(Vector3(15,0,0))
		21:
			_cc_pose_legs(Vector3(-34,0,0),Vector3(-34,0,0)); _cc_pose_torso(Vector3(16,0,0))
		22:
			character_control_model.rotation_degrees.y=sin(t*1.7)*45.0; _cc_pose_legs(Vector3(-32,0,0),Vector3(-32,0,0))
		23:
			_cc_pose_legs(Vector3(-45,0,0),Vector3(-45,0,0)); _cc_weapon_pose(0)
		24:
			_cc_pose_legs(Vector3(-45,0,0),Vector3(-45,0,0)); _cc_weapon_pose(0,8.0*(0.5+0.5*sin(t*12.0)))
		25:
			var q=clampf(t/0.55,0.0,1.0); _cc_pose_legs(Vector3(-45*(1.0-q),0,0),Vector3(-45*(1.0-q),0,0))
		26:
			_cc_pose_head(Vector3(0,sin(t*0.8)*38.0,0))
		27:
			_cc_pose_head(Vector3(sin(t*.7)*8.0,sin(t*.9)*28.0,0))
		28:
			_cc_pose_torso(Vector3(0,sin(t*.8)*35.0,0)); _cc_pose_head(Vector3(0,sin(t*.8)*12.0,0))
		29:
			var aim=sin(t*.7)*28.0; _cc_pose_torso(Vector3(aim*.35,0,0)); _cc_pose_head(Vector3(aim*.65,0,0)); _cc_weapon_pose(0)
		30,31,32,33:
			_cc_weapon_pose(0)
			if n==32: character_control_model.rotation_degrees.y=180.0
			if n==33: character_control_model.rotation_degrees.y=sin(t*1.6)*55.0
		34:
			character_control_model.position.y=character_control_base_y+sin(fmod(t,.85)/.85*PI)*.48; _cc_weapon_pose(0)
		35:
			character_control_model.position.y=character_control_base_y+sin(fmod(t,.85)/.85*PI)*.48; _cc_weapon_pose(0,7.0*(.5+.5*sin(t*13.0)))
		36,40:
			_cc_weapon_pose(0)
		37:
			_cc_weapon_pose(1)
		38:
			_cc_weapon_pose(2)
		39,43:
			_cc_weapon_pose(3); _cc_pose_head(Vector3(-7,0,0))
		41:
			_cc_weapon_pose(0); _cc_rotate_bone(["mixamorig_LeftForeArm","LeftForeArm","lowerarm_l"],Vector3(-18,-8,0))
		42:
			_cc_weapon_pose(0); _cc_pose_torso(Vector3(-8,0,0))
		44:
			_cc_weapon_pose(0,8.0*(.5+.5*sin(t*14.0)))
		45:
			_cc_weapon_pose(1,15.0*(.5+.5*sin(t*11.0))); _cc_pose_torso(Vector3(-10,0,0))
		46:
			_cc_weapon_pose(3,20.0*(.5+.5*sin(t*9.0))); _cc_pose_torso(Vector3(-14,0,0))
		47:
			var q=maxf(0.0,1.0-clampf(t/0.7,0.0,1.0)); _cc_weapon_pose(0,14.0*q)
		48:
			_cc_pose_arms(Vector3(-25,sin(t*4.0)*24,8),Vector3(-40,-18,-10)); _cc_pose_torso(Vector3(8,sin(t*2.0)*8,0))
		49:
			_cc_pose_arms(Vector3(-12,0,18),Vector3(-8,0,-10)); _cc_pose_torso(Vector3(-5,12,0))
		50,51:
			_cc_pose_torso(Vector3(-8,sin(t*8.0)*18,0)); _cc_pose_arms(Vector3(-35,-18+sin(t*9.0)*25,20),Vector3(-15,0,-10))
		52:
			_cc_pose_arms(Vector3(-25,0,22),Vector3(-28,0,-18)); _cc_pose_torso(Vector3(-8,8,0))
		53,54:
			_cc_pose_torso(Vector3(-10,sin(t*7.0)*28,0)); _cc_pose_arms(Vector3(-55,sin(t*7.0)*35,25),Vector3(-45,-sin(t*7.0)*25,-18))
		55:
			_cc_pose_torso(Vector3(-16,sin(t*8.0)*18,0)); _cc_pose_arms(Vector3(-45,-20,24),Vector3(-28,0,-12))
		56:
			_cc_pose_torso(Vector3(-8,sin(t*11.0)*32,0)); _cc_pose_arms(Vector3(-48,sin(t*11.0)*35,22),Vector3(-32,-sin(t*11.0)*20,-16))
		57:
			var phase=fmod(t,2.0); _cc_pose_torso(Vector3(-10,sin(phase*PI*2.0)*34,0)); _cc_pose_arms(Vector3(-52,sin(phase*PI*2.0)*40,25),Vector3(-35,-sin(phase*PI*2.0)*24,-18))
		58:
			character_control_model.rotation_degrees.y=sin(t*4.0)*35.0; _cc_pose_torso(Vector3(-10,sin(t*6.0)*20,0))
		59:
			_cc_pose_torso(Vector3(4,0,sin(t*12.0)*7.0))
		60:
			_cc_pose_torso(Vector3(18,0,sin(t*9.0)*15.0)); _cc_pose_head(Vector3(10,0,0))
		61:
			_cc_pose_torso(Vector3(18,0,0)); _cc_pose_head(Vector3(8,0,0))
		62:
			_cc_pose_torso(Vector3(-20,0,0)); _cc_pose_head(Vector3(-8,0,0))
		63:
			_cc_pose_torso(Vector3(0,0,sin(t*8.0)*20.0)); _cc_pose_head(Vector3(0,0,sin(t*8.0)*8.0))
		64:
			_cc_pose_torso(Vector3(12,sin(t*6.0)*12,sin(t*7.0)*18)); character_control_model.rotation_degrees.z=sin(t*7.0)*7.0
		65:
			var q=maxf(0.0,1.0-clampf(t/0.8,0.0,1.0)); _cc_pose_torso(Vector3(10*q,0,16*q))
		66:
			pass
		67:
			_cc_pose_arms(Vector3(-65,20,30),Vector3(-65,-20,-30)); _cc_pose_torso(Vector3(-12,0,0))
		68:
			_cc_pose_arms(Vector3(-55,18,25),Vector3(-55,-18,-25)); _cc_pose_torso(Vector3(-18,0,0))
		69:
			_cc_pose_torso(Vector3(22,0,0)); _cc_pose_arms(Vector3(18,0,12),Vector3(18,0,-12))
		70:
			_cc_pose_head(Vector3(sin(t*.8)*6,sin(t*.55)*30,0))
		71:
			_cc_pose_torso(Vector3(0,0,sin(t*.8)*7)); _cc_pose_legs(Vector3(0,0,sin(t*.8)*4),Vector3(0,0,-sin(t*.8)*4))
		72:
			_cc_pose_torso(Vector3(sin(t*1.5)*2.2,0,0)); _cc_pose_head(Vector3(sin(t*1.5)*.8,0,0))
		73:
			_cc_pose_legs(Vector3(sin(t*.8)*12,0,0),Vector3(-sin(t*.8)*12,0,0)); character_control_model.rotation_degrees.z=sin(t*.8)*6
		74:
			character_control_model.position.y=character_control_base_y+maxf(0.0,sin(t*2.0))*0.18; _cc_pose_legs(Vector3(-28,0,0),Vector3(12,0,0))
		75:
			character_control_model.position.y=character_control_base_y+sin(fmod(t,.7)/.7*PI)*.34; _cc_pose_torso(Vector3(-16,0,0))
		76:
			var q=maxf(0.0,1.0-clampf(t/.5,0.0,1.0)); _cc_pose_torso(Vector3(28*q,0,0)); _cc_pose_arms(Vector3(-35,0,20),Vector3(-35,0,-20),q)
		77:
			_character_control_set_anim_speed(0.75+0.55*(0.5+0.5*sin(t*.7)))
		78:
			_character_control_set_anim_speed(clampf(t/1.2,0.35,1.0)); _cc_pose_torso(Vector3(-8*clampf(t/1.2,0,1),0,0))
		79:
			_character_control_set_anim_speed(maxf(0.08,1.0-clampf(t/1.0,0,1)))
		80:
			var q=0.5+0.5*sin(t*PI); _cc_pose_torso(Vector3(-8*q,0,0))
		81:
			_cc_weapon_pose(0); _cc_pose_torso(Vector3(0,sin(t*.8)*30,0))
		82:
			# In-place preview: feet remain visually planted while locomotion cycles.
			_cc_pose_legs(Vector3(sin(t*6.0)*4,0,0),Vector3(-sin(t*6.0)*4,0,0))
		83:
			_cc_weapon_pose(0)
		84:
			# Hand-IK preview: lock both arms into a stable two-hand weapon pose.
			_cc_weapon_pose(0); _cc_rotate_bone(["mixamorig_LeftHand","LeftHand","hand_l"],Vector3(0,-8,-10))
		85:
			# Foot-IK preview: compensate alternating terrain heights through leg chains.
			var h=sin(t*.9)*10.0; _cc_pose_legs(Vector3(h,0,0),Vector3(-h,0,0))
		86:
			_cc_weapon_pose(3); _cc_pose_head(Vector3(-6,sin(t*.5)*8,0))
		87:
			var side=sin(t*10.0); _cc_pose_torso(Vector3(abs(side)*8,0,side*18)); _cc_pose_head(Vector3(0,0,side*8))
		88:
			# Dead clip supplies the collapse pose; keep it unlooped.
			pass
		89:
			_cc_pose_torso(Vector3(18,sin(t*2.0)*15,sin(t*2.7)*20)); character_control_model.rotation_degrees.z=sin(t*2.7)*12
		90:
			# Same locomotion/skeleton stack used by NPC-compatible preview.
			_cc_pose_torso(Vector3(-5,sin(t*.8)*8,0))


func _character_control_update_labels():
	if character_control_panel==null: return
	var variant_names={"gumus":"Gümüş","zehir":"Zehir","buz":"Buz","gunes":"Güneş","lav":"Lav"}
	var full_weapon_name="%s %s" % [variant_names.get(character_control_variant,character_control_variant),STORE_WEAPON_NAMES[character_control_weapon_index]]
	var name=character_control_panel.get_node_or_null("WeaponName")
	if name: name.text=full_weapon_name
	if character_control_status:
		character_control_status.text="%s • %s\nSilah konum: %.2f, %.2f, %.2f   Dönüş: %.0f°, %.0f°, %.0f°   Namlu: %.2f, %.2f, %.2f" % [character_control_anim_name,full_weapon_name,character_control_weapon_pos.x,character_control_weapon_pos.y,character_control_weapon_pos.z,character_control_weapon_rot.x,character_control_weapon_rot.y,character_control_weapon_rot.z,character_control_muzzle_pos.x,character_control_muzzle_pos.y,character_control_muzzle_pos.z]


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
