extends KinematicBody2D

#-----------------------------------------------------
# Numeric constants
const BASE_SPEED = 500
const JUMP_FORCE = -1100
const GRAVITY = 9.8
const WEIGHT = 8.16
const EPSILON = 0.01

#-----------------------------------------------------
# String constants
# Animation states
const RUNNING = "Running"
const IDLE = "Idle"
const ATTACK = "OverheadAttack"

# Input keys
const LEFT = "left"
const RIGHT = "right"
const JUMP = "jump"
const SELECT = "select"

# Player State
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
	self.scale.x *= -1 if new_dir != dir else 1
	dir = new_dir

func set_running():
	$AnimationPlayer.play(RUNNING)

func attack():
	state = STATE_ATTACK
	$AnimationPlayer.play(ATTACK)

func calcGravity():
	return WEIGHT * GRAVITY

#-----------------------------------------------------
# Internal methods
func _ready():
	velocity = Vector2()
	state = STATE_NO_ATTACK
	dir = RIGHT if self.scale.x > 0 else LEFT
	$AnimationPlayer.play(IDLE)

func _physics_process(_delta):
	if state == STATE_NO_ATTACK:
		if Input.is_action_pressed(RIGHT):
			flip(RIGHT)
			velocity.x = BASE_SPEED
			set_running()
		elif Input.is_action_pressed(LEFT):
			flip(LEFT)
			velocity.x = -BASE_SPEED
			set_running()

		if Input.is_action_just_pressed(JUMP) and is_on_floor():
			velocity.y = JUMP_FORCE
		elif Input.is_action_just_pressed(SELECT):
			attack()

	velocity.y += calcGravity()
	if abs(velocity.x) <= EPSILON and not state == STATE_ATTACK:
		velocity.x = 0
		$AnimationPlayer.play(IDLE)

	velocity = move_and_slide(velocity, Vector2.UP)

	if is_on_floor():
		velocity.x = lerp(velocity.x, 0, .6)

func _on_animation_player_finished(animation_name):
	if animation_name == ATTACK:
		state = STATE_NO_ATTACK
		$AnimationPlayer.play(IDLE)
