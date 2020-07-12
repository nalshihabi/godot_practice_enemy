extends KinematicBody2D

#-----------------------------------------------------
# Numeric constants
const BASE_SPEED = 500
const JUMP_FORCE = -2200
const GRAVITY = 9.8
const WEIGHT = 20
const EPSILON = 0.01
const BODY_HITBOX_OFFSET = 8.428

#-----------------------------------------------------
# String constants
# Animation states
const RUNNING = "running"
const IDLE = "idle"
const ATTACK = "oa"

# Input keys
const LEFT = "left"
const RIGHT = "right"
const JUMP = "jump"
const SELECT = "select"

# Enemy State
const STATE_NO_ATTACK = "NO ATTACK"
const STATE_ATTACK = "ATTACK"

#-----------------------------------------------------
# Member Variables
var dir = 1
var velocity
var state = STATE_NO_ATTACK

#-----------------------------------------------------
# Member methods
func flip(new_dir):
	$Sprite.flip_h = false if new_dir == 1 else true
	if new_dir == 1:
		pass
	dir = new_dir

func set_running():
	$Sprite.animation = RUNNING

func attack():
	state = STATE_ATTACK
	$Sprite.play(ATTACK)

func calcGravity():
	return WEIGHT * GRAVITY

#-----------------------------------------------------
# Internal methods
func _ready():
	velocity = Vector2()
	$Sprite.playing = true
	state = STATE_NO_ATTACK

func _physics_process(_delta):
	if state == STATE_NO_ATTACK:
		if Input.is_action_pressed(RIGHT):
			flip(1)
			velocity.x = BASE_SPEED
			set_running()
		elif Input.is_action_pressed(LEFT):
			flip(0)
			velocity.x = -BASE_SPEED
			set_running()

		if Input.is_action_just_pressed(JUMP) and is_on_floor():
			velocity.y = JUMP_FORCE
		# elif Input.is_action_just_pressed(SELECT):
		# 	attack()

	velocity.y += calcGravity()
	if abs(velocity.x) <= EPSILON and not state == STATE_ATTACK:
		velocity.x = 0
		$Sprite.animation = IDLE

	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, .6)

func _on_animation_finished():
	if $Sprite.animation == ATTACK:
		$Sprite.animation = IDLE
		state = STATE_NO_ATTACK