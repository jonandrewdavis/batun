extends HBoxContainer


var id: String = ''
var player_name: String = ''
var score: int = 0

func _ready():
	$Label.text = id
	$Label2.text = player_name
	$Label3.text = str(score)
	
func set_up(_id, _player_name):
	pass

func make_score(new_score):
	$Label3.text = str(score + new_score)
