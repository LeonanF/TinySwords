extends Control

signal move_right
signal move_left
signal move_up
signal move_down
signal attack

var player
@onready var up_button = $Up
@onready var down_button = $Down
@onready var left_button = $Left
@onready var right_button = $Right
@onready var attack_button = $Attack

func _ready():
	
	up_button.connect("pressed", Callable(self, "_on_UpButton_pressed"))
	down_button.connect("pressed", Callable(self, "_on_DownButton_pressed"))
	left_button.connect("pressed", Callable(self, "_on_LeftButton_pressed"))
	right_button.connect("pressed", Callable(self, "_on_RightButton_pressed"))
	attack_button.connect("pressed", Callable(self, "_on_AttackButton_pressed"))
	

func _on_AttackButton_pressed():
	attack.emit()

func _on_UpButton_pressed():
	move_up.emit()

func _on_DownButton_pressed():
	move_down.emit()

func _on_LeftButton_pressed():
	move_left.emit()

func _on_RightButton_pressed():
	move_right.emit()
