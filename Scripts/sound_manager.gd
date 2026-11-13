extends Control

# Called when the node enters the scene tree for the first time.
func play_enemy_sound():
	$SoundEnemy.play()
	
func play_fireball_sound():
	$SoundFireball.play()

func play_coin_sound():
	$SoundCoin.play()

func play_menu_music():
	$MusicMenu.play()

func stop_menu_music():
	$MusicMenu.stop()

func play_level_music():
	$MusicLevel.play()

func stop_level_music():
	$MusicLevel.stop()
