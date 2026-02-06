extends Node

## Game Management
var paused = false # Whether the game is paused or not
var sensitivity = 1.0

## Equipped Attachments
var left_arm: PackedScene
var right_arm: PackedScene
var special_attachment: PackedScene
