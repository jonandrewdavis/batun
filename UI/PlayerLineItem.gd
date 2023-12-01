extends HBoxContainer


var id: String = ''
var player_name: String = ''
var score: int = 0
var win: int = 0


func _ready():
	$Label.text = id
	$Label2.text = player_name
	$Label3.text = str(score)
	$Label4.text = str(win)
	$Label5.text = str(0)
		
func set_up(_id, _player_name):
	pass

func make_score(new_score):
	$Label3.text = str(score + new_score)

func make_win(new_win):
	$Label4.text = str(win + new_win)

func make_coin(new_coin):
	$Label5.text = str(new_coin)
