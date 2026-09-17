extends Node3D

var gray_cards := 1
var green_cards := 0
var blue_cards := 0
var orange_cards := 0
var red_cards := 0
const BOT_COUNT := 99
const BOSS_COUNT := 10
const LOOT_CHEST_COUNT := 300
const MAX_HOME_PROTECTION_HOURS := 36
const DAY_CYCLE_SECONDS := 1800
const TRADE_EXIT_IMMUNITY_SECONDS := 180

func _ready():
    print("GRAY CARD WARS prototype started")
    print("Bots: ", BOT_COUNT, " Bosses: ", BOSS_COUNT)

func combine_gray() -> bool:
    if gray_cards < 2:
        return false
    gray_cards -= 2
    green_cards += 1
    return true

func boss_reward(boss_id:int) -> int:
    return clamp(boss_id, 1, 10) * 50
