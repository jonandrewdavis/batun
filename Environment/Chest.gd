extends Node2D


@rpc("any_peer", 'reliable')
func destroy():
	queue_free()
