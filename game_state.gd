extends Node

## Game Management
var paused = false # Whether the game is paused or not
var sensitivity = 1.0
var victory = false

## Equipped Attachments
var left_arm: PackedScene
var right_arm: PackedScene
var special_attachment: PackedScene

## Reset
func reset_to_defaults():
	paused = false
	sensitivity = 1.0
	victory = false
	left_arm = null
	right_arm = null
	special_attachment = null
