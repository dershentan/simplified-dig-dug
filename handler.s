   AREA handler, CODE, READWRITE
	EXPORT FIQ_Handler
	EXPORT pause_flag
    IMPORT interrupt_init
	IMPORT read_character
	IMPORT output_character
	IMPORT output_string
	IMPORT div_and_mod
	IMPORT Display_board
	IMPORT exitloopflag
	IMPORT timers_start
	IMPORT timers_restart
	IMPORT timers_stop
	IMPORT timers_pause
	IMPORT stopwatchcounter
	IMPORT Board_array	
	IMPORT p_status
    IMPORT update_score
	IMPORT s_died
    IMPORT q_died
    IMPORT p_died
    IMPORT p_life
    IMPORT lvl_data
	IMPORT sf_status
	IMPORT ss_status
	IMPORT q_status
	IMPORT move_enemy
	IMPORT watchdog_init
	IMPORT watchdog_start
	IMPORT start_state
	IMPORT pause_prompt
	IMPORT Illuminate_RGB_LED
	
	ALIGN
pause_state DCD 0x00000000
pause_flag DCD 0x00000001
s_flag DCD 0x00000001
direction_status_f DCD 0x00000000
direction_status_s DCD 0x00000000
direction_status_q DCD 0x00000000
refresh_rate_flag DCD 0x0FFFFFFF
direction_hit  DCD 0x00000000	
	ALIGN

FIQ_Handler
		STMFD SP!, {r0-r12, lr}   ; Save registers
		
TIMER1I1			; Check for Timer1 Match Register 1 interrupt
		LDR r0, =0xE0008000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFD
		TEQ r1, #2
		BEQ TM1I1
		
TIMER1I2			; Check for Timer1 Match Register 2 interrupt
		LDR r0, =0xE0008000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFB
		TEQ r1, #4
		BEQ TM1I2
		
UART0I			; Check for UART0 interrupt
		LDR r0, =0xE000C008
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFE
		TEQ r1, #0
		BNE TIMER0I1
		LDR r0, =refresh_rate_flag
		LDR r1, [r0]
		TEQ r1, #0
		BNE READBYTE
		BL	read_character
		B	FIQ_Exit

TIMER0I1			; Check for Timer0 Match Register 2 interrupt
		LDR r0, =0xE0004000
		LDR r1, [r0]
		BIC r1, r1, #0xFFFFFFFD
		TEQ r1, #2
		BEQ TM0I1

EINT1			; Check for EINT1 interrupt
		LDR r0, =0xE01FC140
		LDR r1, [r0]
		TST r1, #2
		BEQ FIQ_Exit
	
		STMFD SP!, {r0-r12, lr}   ; Save registers 
			
		; Push button EINT1 Handling Code
		LDR r4, =pause_flag
		LDR r0, [r4]
		TEQ r0, #1
		BEQ eint1exit
		LDR r4, =pause_state
		LDR r0, [r4]
		TEQ r0, #0
		BEQ ispausestate
		MOV r0, #0
		STR r0, [r4]
		BL	timers_restart
		B	eint1exit
		
ispausestate
		MOV r0, #1
		STR r0, [r4]
		BL	timers_pause
		MOV r0, #0x0C
		BL output_character
		LDR r4, =pause_prompt
		BL output_string
		BL Display_board
		MOV r0, #2
		BL	Illuminate_RGB_LED
		
eint1exit

		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
		ORR r1, r1, #2		; Clear Interrupt
		STR r1, [r0]
		
		B	FIQ_Exit		;end of EINT1
		
READBYTE
		STMFD SP!, {r0-r12, lr}   ; Save registers

		; UART0I Handling Code
		
		BL reset_rrf
		BL read_character


		LDR r4, =pause_state		; set initial state to 0	
		LDRB r1, [r4]
		CMP r1 , #1									  
		BEQ uart_exit
	   
		CMP r0, #0x20            ;check if airbomb
		BEQ Its_Space
	   
		CMP r0, #0x0D            ;check if enter
		BEQ Its_Enter
	   
		CMP r0, #0x67            ;check if g
		BEQ Its_g

		CMP r0, #0X77		   ;check if input is up
		BEQ Its_U
	   
		CMP r0, #0x73           ;check if input is down side
		BEQ Its_D

		CMP r0, #0x61           ;check if input is left side
		BEQ Its_L
	   
		CMP r0, #0x64           ;check if input is right side
		BEQ Its_R
	   
		B uart_exit
	   
Its_g
		LDR r4, =start_state
		MOV r0, #1
		STR r0, [r4]
		B uart_exit
	   
Its_Enter
		BL watchdog_start
		B uart_exit
	   
Its_Space
		MOV r0, #1
		BL	Illuminate_RGB_LED
		LDR r4,= p_status
		LDR r2, [r4]
		LDR r0,= Board_array
		LDRB r1, [r0, r2]!
		CMP r1, #4          ;<
		BEQ hit_left
		CMP r1, #3          ;>
		BEQ hit_right 
		CMP r1, #5          ;^
		BEQ hit_top
		CMP r1, #6           ;v
		BEQ hit_bot
		ORR r0, r0, r0
		B uart_exit
	   
hit_left
		LDRB r1, [r0, #1]!     ; check if left side is dirt/wall or enemy
		CMP r1, #0
		BNE hit_l
		MOV r1, #10
		STRB r1, [r0]
		B hit_left
hit_l		
		CMP r1, #1
		BEQ l_mark
		CMP r1, #2
		BEQ l_mark
		CMP r1, #10
		BEQ l_mark		
		CMP r1, #8 
		ADDEQ r5, r2, #1	   
		BLEQ s_died
		BLGT q_died
l_mark
		LDR r4, = direction_hit
		MOV r1, #1
		STR r1, [r4]
		B uart_exit	

hit_right
		LDRB r1, [r0, #-1]!     ; check if left side is dirt/wall or enemy
		CMP r1, #0
		BNE hit_r
		MOV r1, #10
		STRB r1, [r0]
		B hit_right
hit_r		
		CMP r1, #1
		BEQ r_mark
		CMP r1, #2
		BEQ r_mark
		CMP r1, #10
		BEQ r_mark
		CMP r1, #8
		SUBEQ r5, r2, #1	       
		BLEQ s_died
		BLGT q_died
r_mark		
		LDR r4, = direction_hit
		MOV r1, #2
		STR r1, [r4]
		B uart_exit	
	   
hit_top
		LDRB r1, [r0, #-24]!     ; check if left side is dirt/wall or enemy
		CMP r1, #0
		BNE hit_t
		MOV r1, #10
		STRB r1, [r0]
		B hit_top
hit_t	
		CMP r1, #1
		BEQ t_mark
		CMP r1, #10
		BEQ t_mark		
		CMP r1, #2
		BEQ t_mark		   
		CMP r1, #8 
		SUBEQ r5, r2, #24	 	   
		BLEQ s_died
		BLGT q_died
t_mark
		LDR r4, = direction_hit
		MOV r1, #3
		STR r1, [r4]
		B uart_exit	
	   
hit_bot
		LDRB r1, [r0, #24]!     ; check if left side is dirt/wall or enemy
		CMP r1, #0
		BNE hit_b
		MOV r1, #10
		STRB r1, [r0]
		B hit_bot
hit_b	
		CMP r1, #1
		BEQ b_mark
		CMP r1, #2
		BEQ b_mark
		CMP r1, #10
		BEQ b_mark	
		CMP r1, #8
		ADDEQ r5, r2, #24	       
		BLEQ s_died
		BLGT q_died
b_mark
		LDR r4, = direction_hit
		MOV r1, #1
		STR r1, [r4]
		B uart_exit	
	   
Its_U
		LDR r4, =p_status
		LDR r0, [r4]
		LDR r5, =Board_array
		LDRB r1, [r5, r0]
		CMP r1, #5
		BEQ move_u
		MOV r2, #5
		STRB r2, [r5, r0]
		B uart_exit
move_u
		LDR r4,= p_status
		LDR r0, [r4]	
		SUB r4, r0, #24
		CMP r4, #48
		BLE uart_exit
		LDR r5,= Board_array
		ADD r5, r5, r0
		LDRB r1, [r5, #-24]
		CMP r1, #2 
		BEQ uart_exit
		CMP r1, #7
		BLGT p_died
		BGT uart_exit
		CMP r1, #1
		BLEQ update_score
		MOV r1, #0	  
		STRB r1, [r5]
		MOV r1, #5
		STRB r1, [r5, #-24]
		ADD r0, r0, #-24
		LDR r4,= p_status
		STR r0, [r4]
		B uart_exit	  
Its_D
		LDR r4, =p_status
		LDR r0, [r4]
		LDR r5, =Board_array
		LDRB r1, [r5, r0]
		CMP r1, #6
		BEQ move_d
		MOV r2, #6
		STRB r2, [r5, r0]
		B uart_exit
move_d
		LDR r4,= p_status
		LDR r0, [r4]	  
		LDR r5,= Board_array
		ADD r5, r5, r0
		LDRB r1, [r5, #24]
		CMP r1, #2 
		BEQ uart_exit
		CMP r1, #7
		BLGT p_died
		BGT uart_exit
		CMP r1, #1
		BLEQ update_score
		MOV r1, #0	  
		STRB r1, [r5] 
		MOV r1, #6
		STRB r1, [r5, #24]
		ADD r0, r0, #24
		STR r0, [r4]
		B uart_exit
Its_R
		LDR r4, =p_status
		LDR r0, [r4]
		LDR r5, =Board_array
		LDRB r1, [r5, r0]
		CMP r1, #3
		BEQ move_r
		MOV r2, #3
		STRB r2, [r5, r0]
		B uart_exit
move_r
		LDR r4,= p_status
		LDR r0, [r4]	  
		LDR r5,= Board_array
		ADD r5, r5, r0
		LDRB r1, [r5, #-1]
		CMP r1, #2 
		BEQ uart_exit
		CMP r1, #7
		BLGT p_died
		BGT uart_exit
		CMP r1, #1
		BLEQ update_score
		MOV r1, #0	  
		STRB r1, [r5]
		MOV r1, #3
		STRB r1, [r5, #-1]
		ADD r0, r0, #-1
		STR r0, [r4]
		B uart_exit
Its_L
		LDR r4, =p_status
		LDR r0, [r4]
		LDR r5, =Board_array
		LDRB r1, [r5, r0]
		CMP r1, #4
		BEQ move_l
		MOV r2, #4
		STRB r2, [r5, r0]
		B uart_exit
move_l
		LDR r4,= p_status
		LDR r0, [r4]	  
		LDR r5,= Board_array
		ADD r5, r5, r0
		LDRB r1, [r5, #1]
		CMP r1, #2 
		BEQ uart_exit
		CMP r1, #7
		BLGT p_died
		BGT uart_exit
		CMP r1, #1
		BLEQ update_score
		MOV r1, #0	  
		STRB r1, [r5]
		MOV r1, #4
		STRB r1, [r5, #1]
		ADD r0, r0, #1
		STR r0, [r4]
		B uart_exit
update_lvl
      LDR r4,= sf_status
      CMP r4, #0
      BNE uart_exit
      LDR r4,= ss_status
      CMP r4, #0
      BNE uart_exit
      LDR r4,= p_life
      CMP r4, #0
      BNE uart_exit
      LDR r4,= lvl_data
      LDR r0, [r4]
      ADD r0, r0, #1
      STR r0,[r4]
uart_exit
		
		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		B	FIQ_Exit
		
TM0I1
		STMFD SP!, {r0-r12, lr}   ; Save registers
		
		LDR r4, =refresh_rate_flag
		MOV r0, #1
		STR r0, [r4]

        LDR r4, = s_flag
		LDR r0, [r4]
		CMP r0, #1
		ADDNE r0, r0, #2
		STRNE r0, [r4]
		BNE q_move
sf_move
        LDR r4, = direction_status_f
		LDR r1, [r4]
        LDR r4, = sf_status
		LDR r2, [r4]
		CMP r2, #0
		BEQ  ss_move	
		LDR r5,= Board_array
	    ADD r5, r5, r2
		LDRB r3, [r5]
		CMP r3, #8
		BLEQ move_enemy
		STR r0, [r4]
        LDR r4,=direction_status_f
	    STR r1,[r4]       
ss_move	
        LDR r4, = direction_status_s
		LDR r1, [r4]
        LDR r4, = ss_status
		LDR r2, [r4]
		CMP r2, #0
		BEQ  q_move
		LDR r5,= Board_array
	    ADD r5, r5, r2
		LDRB r3, [r5]
		CMP r3, #8
		BLEQ move_enemy
		STR r0, [r4]
        LDR r4,=direction_status_s
	    STR r1,[r4]   
q_move
        LDR r4, = direction_status_q
		LDR r1, [r4]
        LDR r4, = q_status
		LDR r2, [r4]
		CMP r2, #0
		BEQ  T1_done
		LDR r5,= Board_array
	    ADD r5, r5, r2
		LDRB r3, [r5]
		CMP r3, #9
		BLEQ move_enemy
		STR r0, [r4]
        LDR r4,=direction_status_q
	    STR r1,[r4]  
		; TIMER0I1 Handling Code
T1_done	
        LDR r4, = s_flag
		LDR r0, [r4]
 		SUB r0, r0, #1
		STR r0, [r4]
		MOV r0, #0x0C
		BL output_character
		BL Display_board
	
	    
		LDR r4,= p_status
		LDR r2, [r4]
		LDR r0,= Board_array
		LDRB r1, [r0, r2]!
		LDR r4,= direction_hit
		LDR r1,[r4]
		CMP r1, #1
		BEQ bullet_left
	    CMP r1, #2
		BEQ bullet_right
		CMP r1, #3
		BEQ bullet_top
		CMP r1, #4
		BEQ bullet_bot
		B T1_exit
bullet_left
        LDRB r1, [r0, #1]!     ; check if left side is dirt/wall or enemy
		CMP r1, #10
		BNE T1_exit
		MOV r1, #0
		STRB r1, [r0]
		B bullet_left
bullet_right
        LDRB r1, [r0, #-1]!     ; check if left side is dirt/wall or enemy
		CMP r1, #10
		BNE T1_exit
		MOV r1, #0
		STRB r1, [r0]
		B bullet_right
bullet_top
        LDRB r1, [r0, #-24]!     ; check if left side is dirt/wall or enemy
		CMP r1, #10
		BNE T1_exit
		MOV r1, #0
		STRB r1, [r0]
		B bullet_top
bullet_bot
        LDRB r1, [r0, #24]!     ; check if left side is dirt/wall or enemy
		CMP r1, #10
		BNE T1_exit
		MOV r1, #0
		STRB r1, [r0]
		B bullet_bot
T1_exit	
        LDR r4,= direction_hit
		MOV r1, #0
		STR r1,[r4]
	
		LDMFD SP!, {r0-r12, lr}   ; Restore registers
		
		LDR r0, =0xE0004000		; Timer0 Interrupt registers
		LDR r1, [r0]
		ORR r1, r1, #2			; Clear bit1
		STR	r1, [r0]
		
		B	FIQ_Exit
		
TM1I1
		STMFD SP!, {r0-r12, lr}   ; Save registers

		; TIMER1I1 Handling Code
		LDR r4, =stopwatchcounter
		LDR r0, [r4]
		ADD r0, r0, #1
		STR r0, [r4]
		
		;Setup Match Register 1 for Timer1(MR1)
		LDR r0, =0xE000801C
		LDR r1, [r0]
		LDR r2, =0x01194000
		LDR r3, =0x82BCC000
		TEQ r1, r3
		BEQ TM1I1_EXIT
		ADD r1, r1, r2
		STR r1, [r0]
TM1I1_EXIT		
		LDMFD SP!, {r0-r12, lr}   ; Restore registers and end of TM1I
		
		LDR r0, =0xE0008000		; Timer1 Interrupt registers
		LDR r1, [r0]
		ORR r1, r1, #2			; Clear bit1
		STR	r1, [r0]
		
		B	FIQ_Exit
		
TM1I2
		STMFD SP!, {r0-r12, lr}   ; Save registers

		; TIMER1I2 Handling Code
		LDR r4, =exitloopflag
		LDR r0, =0x00000001
		STRB r0, [r4]
		BL	timers_stop
		LDR r4, =refresh_rate_flag		;set rrf to max
		LDR r0, =0x0FFFFFFF
		STR r0, [r4]
		MOV r0, #4
		BL	Illuminate_RGB_LED
		LDR r0, =pause_flag
		LDR r1, =0x00000001
		STR r1, [r0]
		
		LDMFD SP!, {r0-r12, lr}   ; Restore registers and end of TM1I
		
		LDR r0, =0xE0008000		; Timer1 Interrupt registers
		LDR r1, [r0]
		ORR r1, r1, #4			; Clear bit1
		STR	r1, [r0]
		
FIQ_Exit
		LDMFD SP!, {r0-r12, lr}
		SUBS pc, lr, #4
		
reset_rrf
	STMFD r13!, {r0-r12, r14}
	
	LDR r4, =refresh_rate_flag
	LDR r0, [r4]
	SUB r0, r0, #1
	STR r0, [r4]
	
	LDMFD r13!, {r0-r12, r14}
    BX lr

	END