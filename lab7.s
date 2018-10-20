	AREA interrupts, CODE, READWRITE
	EXPORT lab7
	IMPORT FIQ_Handler
	IMPORT output_string
	IMPORT output_character
	IMPORT read_character
    IMPORT read_string
	IMPORT div_and_mod
	IMPORT pin_connect_block_setup
	IMPORT gpio_direction_register
	IMPORT uart_init
	IMPORT timers_start
	IMPORT Board_array		
	IMPORT Board_array_initial
	IMPORT Copy_board	
    IMPORT ADD_enemy_s
	IMPORT ADD_enemy_q
	IMPORT Display_board
	IMPORT interrupt_init
	IMPORT watchdog_init
	IMPORT watchdog_start
	IMPORT timer1_start
	IMPORT timer1_stop
	IMPORT timer0_speedup
	IMPORT display_digit_on_7_seg
	IMPORT illuminateLEDs
	IMPORT Illuminate_RGB_LED
	IMPORT pause_flag
	IMPORT Score_S
	IMPORT binary_conversion_score
	
	EXPORT pause_prompt
	EXPORT start_state
	EXPORT pause_state
    EXPORT sf_status
    EXPORT ss_status
	EXPORT q_status
    EXPORT p_status
	EXPORT p_life
	EXPORT score
	EXPORT lvl_data
	EXPORT exitloopflag
	EXPORT stopwatchcounter
	EXPORT random_base
	EXPORT set_enemies_status

    ALIGN

prompt = "Welcome to Game Dig Dug\n\rControls for the game:\n\rw: to move up\n\rs: to move down",0
prompt1 = "\n\ra: to move left\n\rd: to move right\n\rspacebar: to fire airpump\n\rEnter: to restart game",0
prompt2 = "\n\rExternal Interrupt Button: to pause the game\n\rg: to start the game",0
pause_prompt = "PAUSE\n\r",0
exitprompt = "\n\rGame Over!",0
exitloopflag = " ",0
	
	ALIGN

sf_status DCD 0x00000000
ss_status DCD 0x00000000
q_status DCD 0x00000000
enemies_status DCD 0x00000000
p_status DCD 0x00000000 	
p_life DCD 0x00000000	
score DCD 0x00000000	
lvl_data DCD 0x00000000
pause_state DCD 0x00000000
start_state DCD 0x00000000
stopwatchcounter DCD	0x00000000
random_base DCD 0x00000000	
    ALIGN

lab7	 	
	STMFD sp!, {lr}
	BL	pin_connect_block_setup          ;initialize block and gpio and uart 
	BL	gpio_direction_register
	BL	uart_init
	BL	interrupt_init
	BL	watchdog_init
	BL	timer1_start                     ;timer1 for random position
	MOV r0, #0x0C
	BL output_character
	LDR r4, =prompt
	BL output_string
	LDR r4, =prompt1
	BL output_string
	LDR r4, =prompt2
	BL output_string
	MOV r0, #6
	BL	Illuminate_RGB_LED                ;set start lvl and lifes
	MOV r0, #0
	BL	display_digit_on_7_seg
startpageloop                             ;check if game start, if not loop on the rule page
	LDR r4, =start_state
	LDR r0, [r4]
	CMP r0, #1
	BEQ startpageexit
	LDR r4, =stopwatchcounter
	LDR r0, [r4]
	LDR r1, =0x82BCC000
	CMP r0, r1
	BNE startpageloop
	BL 	timer1_stop
	LDR r4, =stopwatchcounter
	LDR r0, [r4]
	LDR r1, =0x00000000
	STR r1, [r0]
	BL	timer1_start
	B	startpageloop
startpageexit
	LDR r4, =Board_array			; Make a initial copy of Board_array
	LDR r5, =Board_array_initial
	BL Copy_board	
    BL ADD_enemy_s                   ;adding enemy to board
	BL ADD_enemy_q
	BL 	timer1_stop
	LDR r4, =stopwatchcounter
	LDR r0, =0x00000000
	STR r0, [r4]
	
	BL	timers_start
	
	LDR r4, =pause_flag        
	MOV r0, #0
	STR r0, [r4]
	BL	set_level
	LDR r4, =random_base
	MOV r0, #1
	STR r0, [r4]
	LDR r4, =p_status
	MOV r0, #202
	STR r0, [r4]
	LDR r4, =p_life
	LDR r0, =0x0000000F
	STR r0, [r4]
	BL	illuminateLEDs
	LDR r4, =lvl_data
	MOV r0, #1
	STR r0, [r4]
	LDR r4, =start_state
	MOV r0, #0
	STR r0, [r4]
	LDR r4, =pause_state
	MOV r0, #0
	STR r0, [r4]
	
loop
	LDR r4, =enemies_status
	LDR r0, [r4]
	CMP r0, #3
	BNE loop_i
	BL timer0_speedup
	BL set_level
	BL reset_enemies_status
	LDR r5, =Board_array			; Make a initial copy of Board_array
	LDR r4, =Board_array_initial
	BL Copy_board
	BL reset_player
	B	newboard
loop_i
	LDR r4, =exitloopflag
	LDRB r0, [r4]
	CMP r0, #1
	BEQ lab7exit
	B	loop
	
newboard							; create a new board on level up
	LDR r4, =Board_array			; Make a initial copy of Board_array
	LDR r5, =Board_array_initial
	BL Copy_board	
    BL ADD_enemy_s
	BL ADD_enemy_q
	B  loop

lab7exit					;print end screen + final score with bonus for extra life
	MOV r0, #0x0C
	BL output_character
	LDR r4, =exitprompt
	BL	output_string
	LDR r4, =Score_S 
	BL output_string
	LDR r4, =score
	LDR r0, [r4]
	LDR r4, =p_life
	LDR r1, [r4]
	CMP r1, #0
	BEQ	telescore
	ADD r1, r1, #1
telescore
	LDR r2, =0x000000FA
	MUL r3, r1, r2
	ADD r0, r0, r3
	BL binary_conversion_score
	
    BX lr
	

	
reset_player
	STMFD r13!, {r0-r12, r14}
	
	LDR r4,= p_status
	MOV r0, #202
	STR r0, [r4]
	
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
set_enemies_status
	STMFD r13!, {r0-r12, r14}
	
	LDR r4, =enemies_status
	LDR r0, [r4]
	ADD r0, #1
	STRB r0, [r4]
	
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
set_level
	STMFD r13!, {r0-r12, r14}
	
	LDR r4, =lvl_data
	LDR r0, [r4]
	ADD r0, #1
	STRB r0, [r4]
	CMP	r0, #9
	BLE	set_7_seg
	SUB r0, #10
set_7_seg
	BL	display_digit_on_7_seg
	
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
reset_enemies_status
	STMFD r13!, {r0-r12, r14}
	
	LDR r4, =enemies_status
	MOV r0, #0
	STR r0, [r4]
	
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
	
set_exitloopflag
	STMFD r13!, {r2-r12, r14}
	
	LDR r4, =exitloopflag
	LDR r0, =0x00000000
	STRB r0, [r4]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr

	END