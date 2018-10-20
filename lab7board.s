	AREA board, CODE, READWRITE
	EXPORT Copy_board
	EXPORT Display_board
	EXPORT Board_array
	EXPORT Board_array_initial
	EXPORT ADD_enemy_s
	EXPORT ADD_enemy_q
    EXPORT update_score
	EXPORT s_died
    EXPORT q_died
    EXPORT p_died
	EXPORT move_enemy
	EXPORT Score_S
	IMPORT output_string
	IMPORT output_character
	IMPORT div_and_mod
    IMPORT sf_status
    IMPORT ss_status
	IMPORT q_status
    IMPORT p_status
	IMPORT p_life
	IMPORT score
	IMPORT lvl_data
	IMPORT stopwatchcounter
	IMPORT binary_conversion_time
    IMPORT random_base
	IMPORT binary_conversion_score
	IMPORT set_enemies_status
	IMPORT illuminateLEDs
	IMPORT Illuminate_RGB_LED
		
	ALIGN
		
			;	   [3:0]	   [7:4]	   [11:8]      [15:12]     [20:16]     [21]	  
Board_array	DCD 0x02020202, 0x02020202, 0x02020202, 0x02020202, 0x02020202, 0x07070702 		; 0 [Wall]
			DCD 0x00000002, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x07070702 		; 1
			DCD 0x00000002, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x07070702 		; 2
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702 		; 3
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702 		; 4
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702 		; 5
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 6
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 7
			DCD 0x01010102, 0x01010101, 0x01030101, 0x01010101, 0x01010101, 0x07070702		; 8
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 9
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702 		; 10
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702 		; 11
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702      ; 12
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 13
		    DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 14
			DCD 0x01010102, 0x01010101, 0x01010101, 0x01010101, 0x01010101, 0x07070702		; 15
			DCD 0x02020202, 0x02020202, 0x02020202, 0x02020202, 0x02020202, 0x07070702     ;16wall
				
	ALIGN

Board_array_initial		; 102 words
			DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0				
			DCD 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
			DCD 0, 0
				
	ALIGN
			
Status      
            DCD Empty, Dirt, Wall, Right, Left, Top, Bot, unused, Enemy_s, Enemy_q, bullet; 0-9
Title           = "digdug \n\r", 0
Time_S          = "Time : ", 0
Score_S         = "\n\r Score : ", 0
Score_S_Paused  = "\n\r Score :                  PAUSED", 0
Empty           = " ", 0
Dirt            = "#", 0
Wall            = "Z", 0
Right           = ">", 0
Left            = "<", 0
Top             = "^", 0
Bot             = "v", 0
Enemy_s         = "s", 0
Enemy_q         = "q", 0
unused			= "",  0
bullet          = ".", 0
new_line        = "\n\r", 0


	ALIGN
		
		
Copy_board
	STMFD sp!, {lr}
    MOV r0, #102
copy_loop
    LDR r1, [r4], #4
	STR r1, [r5], #4
	SUBS r0, r0, #1
	BNE copy_loop
	LDMFD sp!, {lr}
	BX lr
	
Display_board
	STMFD sp!, {lr}
	MOV r0, #3
	BL Illuminate_RGB_LED
	LDR r4, =Title
	BL output_string
	LDR r4, =Time_S
	BL output_string
	LDR r4, =stopwatchcounter
	LDR r0, [r4]
	BL	binary_conversion_time
	LDR r4, =Score_S 
	BL output_string
	LDR r4, =score
	LDR r0, [r4]
	BL binary_conversion_score
	
	MOV r7, #-24
	MOV r0, #-1
	LDR r5, = Board_array
	LDR r6, = Status
loop_board_1
    LDR r4,= new_line
	STMFD sp!, {r0}
	BL output_string 
	LDMFD sp!, {r0}
	ADD r0, r0, #1
	CMP r0, #17
	BEQ quit_board   
	MOV r1, #20
	ADD r7, r7, #24
loop_board_2
    ADD r3, r7, r1
	LDRB r2, [r5, r3]
	LDR r4, [r6, r2, LSL #2] 
	STMFD sp!, {r0, r1}
	BL output_string
	LDMFD sp!, {r0, r1}
	SUBS r1, r1 , #1
	BLT loop_board_1
	B loop_board_2
quit_board
	LDMFD sp!, {lr}
	BX lr
	
ADD_enemy_s
	STMFD sp!, {lr}
	MOV r0, #2
as_loop
	BL random_generator			;make sure enemy wont be in the same box with player in the beginning
	CMP r1, #201
	BEQ as_loop
	CMP r1, #200
	BEQ as_loop
	CMP r1, #204
	BEQ as_loop
	CMP r1, #203
	BEQ as_loop
	CMP r1, #178
	BEQ as_loop
	CMP r1, #177
	BEQ as_loop
	CMP r1, #179
	BEQ as_loop
	CMP r1, #226
	BEQ as_loop
	CMP r1, #225
	BEQ as_loop
	CMP r1, #227
	BEQ as_loop
	LDR r4,= Board_array
	LDRB r3, [r4,r1]
	CMP r3, #0x01
	BNE as_loop
	MOV r3, #0x08
	STRB r3, [r4, r1]!
	MOV r3, #0x00
	LDRB r2, [r4, #1]
	CMP r2, #0x01
	BNE s_left
	STRB r3, [r4, #1]
s_left
	LDRB r2, [r4, #-1]		;check if left is wall
	CMP r2, #0x01
    BNE s_tail
	STRB r3, [r4, #-1]
s_tail	
	SUB r0, r0, #1			 ;check if right is wall
	CMP r0, #0
	BNE as_loop
    LDMFD sp!, {lr} 
    BX lr  

ADD_enemy_q
	STMFD sp!, {lr}
aq_loop
	BL random_generator				 ;make sure enemy wont be in the same box with player in the beginning
	CMP r1, #201
	BEQ aq_loop
	CMP r1, #200
	BEQ aq_loop
	CMP r1, #204
	BEQ aq_loop 
	CMP r1, #203
	BEQ aq_loop
	CMP r1, #178
	BEQ aq_loop
	CMP r1, #177
	BEQ aq_loop
	CMP r1, #179
	BEQ aq_loop
	CMP r1, #226
	BEQ aq_loop
	CMP r1, #225
	BEQ aq_loop
	CMP r1, #227
	BEQ aq_loop
	LDR r4,= Board_array
	LDRB r3, [r4,r1]
	CMP r3, #0x01
	BNE aq_loop
	MOV r3, #0x09
	STRB r3, [r4, r1]!
	MOV r3, #0x00
	LDRB r2, [r4, #1]
	CMP r2, #0x01
	BNE q_left
	STRB r3, [r4, #1]
q_left
	LDRB r2, [r4, #-1]				
	CMP r2, #0x01					;check if left is wall
    BNE q_tail
	STRB r3, [r4, #-1]
q_tail								;check if right is wall
    LDMFD sp!, {lr} 
    BX lr 

random_generator
    STMFD sp!, {r0,r4,lr}
    CMP r0, #2
    BEQ set_sf   
    CMP r0, #1
    BEQ set_ss
    CMP r0, #0
    BEQ set_q
set_sf	
	LDR r1, =0xE0008008		       ;getting random character for first slow enemy
	LDRH r0, [r1]
	MOV r1, #200
	ADD r1, r1, #208
	BL div_and_mod
	LDR r4,= sf_status
	STR r1, [r4]
	B r_done
set_ss	
	LDR r1, =0xE0008008		       ;getting random character   for second slow enemy
	LDRH r0, [r1]
	MOV r1, #200
	ADD r1, r1, #208
	BL div_and_mod
	LDR r4,= ss_status
	STR r1, [r4]
	B r_done
set_q	
	LDR r1, =0xE0008008		       ;getting random character for quick enemy
	LDRH r0, [r1]
	MOV r1, #200
	ADD r1, r1, #208
	BL div_and_mod
	LDR r4,= q_status
	STR r1, [r4]
	B r_done
r_done
	LDMFD sp!, {r0, r4,lr} 
    BX lr

update_score						 ;update score
    STMFD sp!, {r0-r12, lr} 
	LDR r4,= score
	LDR r0, [r4]
	CMP r1, #8
	ADDEQ r0, r0, #50				;slow enemy 50
	ADDGT r0, r0, #100				;quick enemy 100
	ADDLT r0, r0, #10				;brick 10
    STR r0, [r4]
	LDMFD sp!, {r0-r12, lr} 
    BX lr
	
s_died
    STMFD sp!, {r0-r12,lr}
 	LDR r4,= sf_status         ;check if it is s1 or s2 in the location 
	LDR r2,[r4]
	MOV r3, #0
	CMP r2, r5
	STREQ r3, [r4]               ;set status to 0 if it is s1
	BEQ sd_done
	LDR r4,= ss_status
	STR r3, [r4]
sd_done
    LDR r5,= Board_array
	STRB r3, [r0]
    BL update_score
	BL set_enemies_status
	LDMFD sp!, {r0-r12,lr} 
    BX lr 

q_died
    STMFD sp!, {r0-r12,lr}
	LDR r4,= q_status				;clena q_status and store space to board
	MOV r3, #0
	STRB r3, [r0]
    STR r3, [r4]
	BL update_score
	BL set_enemies_status
	LDMFD sp!, {r0-r12,lr} 
    BX lr

p_died
    STMFD sp!, {r0-r12,lr}			;restore plyer to start position
	MOV r1, #0	  
	STRB r1, [r5] 
	MOV r1, #3
	MOV r0, #202
	LDR r5, =Board_array
	STRB r1, [r5, r0]
	LDR r4,= p_status
	MOV r0, #202
	STR r0, [r4]
    LDR r4,= p_life					;lower life data by 1
	LDR r0, [r4]
	MOV r0, r0, LSR #1				
	STR r0, [r4]
	BL	illuminateLEDs
	LDR r4,= p_life
	LDR r0, [r4]
	CMP r0, #0
	BGT p_still_have_life
	LDR r4, =0xE0008008
	LDR r0, [r4]
	;Setup Match Register 2 for Timer1(MR1)
	LDR r1, =0x001C0000	;less than 0.1sec
	ADD r0, r0, r1
	LDR r4, =0xE0008020
	STR r0, [r4]
p_still_have_life
	LDMFD sp!, {r0-r12,lr} 
    BX lr
	
move_enemy
    STMFD sp!, {r2-r12,lr}
	CMP r1, #1
	BEQ e_left
	CMP r1, #2
	BEQ e_right
	CMP r1, #3
	BEQ e_up
	CMP r1, #4
	BEQ e_down
e_loop
	LDR r1, =p_status	       ;getting random character
	LDRH r0, [r1]
	LDR r4,= random_base
	LDR r1, [r4]
	ADD r1, r1, #1
	CMP r1, #1000
	MOVEQ r1, #1
	STR r1, [r4]
	ADD r0, r0, r1
	LDR r4, =0xE0008008		       ;getting random character
	LDRB r1, [r4]
	ADD r0, r0, r1
	MOV r1, #14
	BL div_and_mod
	CMP r1, #3
	BLT e_right
	CMP r1, #6
	BLT e_left
	CMP r1, #10
	BLT e_up
	CMP r1, #14
	BLT e_down
	
e_left
    LDR r5,= Board_array			 ;check if there is space left , change direction if there is not
	ADD r5, r5, r2
	LDRB r1, [r5, #1]!
	CMP r1, #3
	BLT empty_left
	CMP r1, #6
	BGT empty_left
    BL p_died
    MOV r1, #2
    B e_right	
empty_left
	CMP r1, #0
	BNE e_loop
	LDRB r0, [r5,#-1]
	STRB r1, [r5,#-1]
	STRB r0, [r5]
	MOV r1, #1
    B e_done
	
e_right
    LDR r5,= Board_array			 ;check if there is space right , change direction if there is not
	ADD r5, r5, r2
	LDRB r1, [r5, #-1]!
	CMP r1, #3
	BLT empty_right
	CMP r1, #6
	BGT empty_right
    BL p_died	
    MOV r1, #1
    B e_left
empty_right
	CMP r1, #0
	BNE e_loop
	LDRB r0, [r5, #1]
	STRB r1, [r5, #1]
	STRB r0, [r5]
	MOV r1, #2
    B e_done
	
e_up
    SUB r4, r2, #24					;check if there is space top , change direction if there is not
    CMP r4, #48
	BLE e_loop
    LDR r5,= Board_array
	ADD r5, r5, r2
	LDRB r1, [r5, #-24]!
	CMP r1, #3
	BLT empty_top
	CMP r1, #6
	BGT empty_top
    BL p_died
    MOV r1, #4
    B e_down
empty_top
	CMP r1, #0
	BNE e_loop
	LDRB r0, [r5, #24]
	STRB r1, [r5, #24]
	STRB r0, [r5]
	MOV r1, #3
    B e_done
	
e_down
    LDR r5,= Board_array			;check if there is space button , change direction if there is not
	ADD r5, r5, r2
	LDRB r1, [r5, #24]!
	CMP r1, #3
	BLT empty_bot
	CMP r1, #6
	BGT empty_bot
    BL p_died
    MOV r1, #3
    B e_up
empty_bot
    CMP r1, #0
	BNE e_loop
	LDRB r0, [r5, #-24]
	STRB r1, [r5, #-24]
	STRB r0, [r5]
	MOV r1, #4
    B e_done
e_done
    MOV r0, r5
    LDR r5,= Board_array
    SUB r0, r0, r5
	LDMFD sp!, {r2-r12,lr} 
    BX lr
	
	END