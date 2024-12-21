extends Node2D


@rpc("any_peer", 'call_local')
func destroy():
	queue_free()
