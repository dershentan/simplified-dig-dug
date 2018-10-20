	AREA logic, CODE, READWRITE
	EXPORT Move_enemy
	EXPORT Air_bomb
	
	
Move_enemy_s
    ;2 arguments needed
	; r4 for enemy_status
	; r5 for enemy_location
    STMFD sp!, { lr}
	LDR r1, [r4]                      ;r4=any enemy_status
	CMP r1, #0
	BLT dead_enemy
move_loop	
	BL random_generator
	BL r3,=Board_array
	CMP r1, #0
	BEQ left
	CMP r1, #1
	BEQ right
	CMP r1, #2
	BEQ up
	CMP r1, #3
	BEQ down
left
    LDR r1, [r3, r5, #-1]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5,#-1]!
	B smove_end
right
    LDR r1, [r3, r5, #1]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #1]!
	B smove_end
up 
    LDR r1, [r3, r5, #-24]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #-24]!
	B smove_end
down 
	LDR r1, [r3, r5, #24]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #24]!
	B smove_end
smove_end
    MOV r5, r3            ;store location to s_data after subroutine end;
sdead_enemy
	LDMFD sp!, {lr} 
    BX lr 

Move_enemy_q
    LDR r1, 
    STMFD sp!, { lr}
	LDR r1, [r4]                      ;r4=any enemy_status
	CMP r1, #0
	BLT dead_enemy
move_loop	
	BL random_generator
	BL r3,=Board_array
	CMP r1, #0
	BEQ left
	CMP r1, #1
	BEQ right
	CMP r1, #2
	BEQ up
	CMP r1, #3
	BEQ down
left
    LDR r1, [r3, r5, #-1]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5,#-1]!
	B qmove_end
right
    LDR r1, [r3, r5, #1]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #1]!
	B qmove_end
up 
    LDR r1, [r3, r5, #-24]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #-24]!
	B qmove_end
down 
	LDR r1, [r3, r5, #24]
	CMP r1, #0
	BNE move_loop
	MOV r1, #0
	STRB r1, [r3]
	MOV r1, #$
	STRB r1, [r3, r5, #24]!
	B qmove_end
qmove_end
    MOV r5, r3            ;store location to s_data after subroutine end;
qdead_enemy
	LDMFD sp!, {lr} 
    BX lr 
	

	
	
end