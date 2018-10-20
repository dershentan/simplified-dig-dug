	AREA	lib, CODE, READWRITE
	EXPORT pin_connect_block_setup
	EXPORT uart_init
	EXPORT read_character
	EXPORT output_character
	EXPORT read_string
	EXPORT output_string
	EXPORT reverse_four_bits
	EXPORT gpio_direction_register
	EXPORT illuminateLEDs
	EXPORT read_from_push_btns
	EXPORT display_digit_on_7_seg
	EXPORT Illuminate_RGB_LED
	EXPORT string_conversion
	EXPORT div_and_mod
	EXPORT interrupt_init
	EXPORT timers_start
	EXPORT timers_restart
	EXPORT timers_stop
	EXPORT timers_pause
	EXPORT binary_conversion_time
	EXPORT binary_conversion_score
	EXPORT watchdog_init
	EXPORT watchdog_start
	EXPORT timer1_start
	EXPORT timer1_stop
	EXPORT timer0_speedup

	ALIGN
	
U0LSR EQU 0x14			; UART0 Line Status Register
	
	ALIGN
		
digits_SET	
		DCD 0x00001F80  ; 0
 		DCD 0x00000300  ; 1
		DCD 0x00002D80	; 2
		DCD 0x00002780	; 3
		DCD 0x00003300	; 4
		DCD 0x00003680	; 5
		DCD 0x00003E80	; 6
		DCD 0x00000380	; 7
		DCD 0x00003F80	; 8
		DCD 0x00003380	; 9
		DCD 0x00003B80	; A
		DCD 0x00003E00	; b
		DCD 0x00001C80	; C
		DCD 0x00002F00	; d
		DCD 0x00003C80	; E
		DCD 0x00003880  ; F
		DCD 0x00002000	; INIT
			
	ALIGN			
			
colors_SET
		DCD 0x00000000	;OFF(0)
		DCD 0x00020000	;RED1(1)
		DCD 0x00040000	;BLUE(2)
		DCD 0x00200000	;GREEN(3)
		DCD 0x00060000	;PURPLE(4)
		DCD 0x00220000	;YELLOW(5)
		DCD 0x00260000	;WHITE(6)

	ALIGN


pin_connect_block_setup
	STMFD sp!, {r0, r1, lr}
	LDR r0, =0xE002C000  ; PINSEL0(only UART0 and p0.7-p0.13)
	LDR r1, [r0]
	ORR r1, r1, #5
	BIC r1, r1, #0xFFFFFFFA	;clear all except value 5 bits
	STR r1, [r0]
	LDMFD sp!, {r0, r1, lr}
	BX lr

gpio_direction_register
	STMFD sp!, {r0-r2, lr}
	LDR r0, =0xE0028008		;IO0DIR base address
	LDR r1, [r0]
	LDR r2, =0x00263F80		;set registers
	ORR r1, r1, r2
	LDR r2, =0xFFD9C07F
	BIC r1, r1, r2			;clear all but set register
	STR r1, [r0]
	LDR r0, =0xE0028018		;IO1DIR base address
	LDR r1, [r0]
	ORR r1, r1, #0x000F0000	;set register
	BIC r1, r1, #0xFFF0FFFF	;clear all but set register
	STR r1, [r0]
	LDMFD sp!, {r0-r2, lr}
	BX lr
	
uart_init

    LDR r2, =0xE000C000     ; Load Address into r2
    MOV r1, #131             ; Copy 131 to r1
    STRB r1, [r2, #0xC]     ; Load byte from r2 and offseting by C
    MOV r1, #1               ; Copy 120 to r1
    STRB r1, [r2]             ; Load byte from r2 no offsets
    MOV r1, #0                 ; Copy 0 to r1
    STRB r1, [r2, #4]         ; Load byte from r2 and offseting by 4
    MOV r1, #3                 ; Copy 3 to r1
    STRB r1, [r2, #0xC]     ; Load byte from r2 and offseting by C	
    BX lr ;exit

watchdog_init
	STMFD sp!, {r0-r2, lr}
	
	LDR r2, =0xE0000000
	MOV r0, #3
	STR r0, [r2]
	LDR r2, =0xE0000004
	LDR r0, =0xFF
	STR r0, [r2]
	
	LDMFD sp!, {r0-r2, lr}
	BX lr
	
watchdog_start
	STMFD sp!, {r0-r2, lr}
	
	LDR r2, =0xE0000008
	LDR r0, =0xAA
	STR r0, [r2]
	LDR r0, =0x55
	STR r0, [r2]
	
	LDMFD sp!, {r0-r2, lr}
	BX lr

interrupt_init       
	STMFD SP!, {r0-r1, lr}   ; Save registers 
	
	; Push button setup		 
	LDR r0, =0xE002C000
	LDR r1, [r0]
	ORR r1, r1, #0x20000000
	BIC r1, r1, #0x10000000
	STR r1, [r0]  ; PINSEL0 bits 29:28 = 10
	
	; Classify sources as IRQ or FIQ
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0xC]
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40	; UART0
	ORR r1, r1, #0x10	; Timer0
	ORR r1, r1, #0x20	; Timer1
	STR r1, [r0, #0xC]

	; Enable Interrupts Sources
	LDR r0, =0xFFFFF000
	LDR r1, [r0, #0x10] 
	ORR r1, r1, #0x8000 ; External Interrupt 1
	ORR r1, r1, #0x40	; UART0
	ORR r1, r1, #0x10	; Timer0
	ORR r1, r1, #0x20	; Timer1
	STR r1, [r0, #0x10]

	; External Interrupt 1 setup for edge sensitive
	LDR r0, =0xE01FC148
	LDR r1, [r0]
	ORR r1, r1, #2  ; EINT1 = Edge Sensitive
	STR r1, [r0]
		
	; Setting UART0 for interrupt on data received
	LDR r0, =0xE000C004
	LDR r1, [r0]
	ORR r1, r1, #1	; Enable RDA
	STR r1, [r0]
		
	;Enable Timer0 to Interrupt (Match Control Register)
	LDR r0, =0xE0004014
	LDR r1, [r0]
	ORR r1, r1, #0x18	;Generate Interrupt(bit3),Reset TC(bit4), Stop TC(bit5) for MR1
	BIC r1, r1, #0x20
	STR r1, [r0]
	
	;Enable Timer1 to Interrupt (Match Control Register)
	LDR r0, =0xE0008014
	LDR r1, [r0]
	ORR r1, r1, #0x00C8		;(Generate Interrupt(bit3),Reset TC(bit4), Stop TC(bit5))MR1,(Generate Interrupt(bit6),Reset TC(bit7), Stop TC(bit8))MR2
	BIC r1, r1, #0x0130
	STR r1, [r0]

	;Setup Match Register 1 for Timer0(MR1)
	LDR r0, =0xE000401C
	LDR r1, =0x008CA000	;0.5sec
	STR r1, [r0]
	
	;Setup Match Register 1 for Timer1(MR1)
	LDR r0, =0xE000801C
	LDR r1, =0x01194000	;1sec
	STR r1, [r0]
	
	;Setup Match Register 2 for Timer1(MR1)
	LDR r0, =0xE0008020
	LDR r1, =0x83D60000	;120sec
	STR r1, [r0]

	; Enable FIQ's, Disable IRQ's
	MRS r0, CPSR
	BIC r0, r0, #0x40
	ORR r0, r0, #0x80
	MSR CPSR_c, r0

	LDMFD SP!, {r0-r1, lr} ; Restore registers
	BX lr             	   ; Return
	

timer0_speedup
	STMFD r13!, {r0-r12, r14}
	
	;Setup Match Register 1 for Timer0(MR1)
	LDR r0, =0xE000401C
	LDR r2, =0x001C2000	;0.1sec
	LDR r1, [r0]
	CMP r1, r2
	BEQ	t0su
	SUB r1, r1, r2
	STR r1, [r0]
t0su
	;Reset Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	LDMFD r13!, {r0-r12, r14}
    BX lr

timer1_start
	STMFD r13!, {r2-r12, r14}
	
	;Enable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	ORR r1, r1, #0x03
	STR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr
	
timers_start
	STMFD r13!, {r2-r12, r14}
	
	;Enable Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	;Enable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr
	
timers_restart
	STMFD r13!, {r2-r12, r14}
	
	;Enable Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	;Enable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	BIC r1, r1, #0x02
	ORR r1, r1, #0x01
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr
	
timer1_stop
	STMFD r13!, {r2-r12, r14}
	;Reset Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	
	;Disable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	BIC r1, r1, #0x03
	STR r1, [r0]
	
	;Setup Match Register 1 for Timer1(MR1)
	LDR r0, =0xE000801C
	LDR r1, =0x01194000	;1sec
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr
	
timers_stop
	STMFD r13!, {r2-r12, r14}
	
	;Reset Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	
	;Reset Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	ORR r1, r1, #0x02
	STR r1, [r0]
	
	;Disable Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	BIC r1, r1, #0x03
	STR r1, [r0]
	
	;Disable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	BIC r1, r1, #0x03
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr

timers_pause
	STMFD r13!, {r2-r12, r14}
	
	;Enable Timer0
	LDR r0, =0xE0004004
	LDR r1, [r0]
	BIC r1, r1, #0x01
	STR r1, [r0]
	
	;Enable Timer1
	LDR r0, =0xE0008004
	LDR r1, [r0]
	BIC r1, r1, #0x01
	STR r1, [r0]
	
	LDMFD r13!, {r2-r12, r14}
    BX lr

read_character
    STMFD r13!, {r2-r12, r14}
RC
    LDR r1, = 0xE000C000    
    LDRB r2, [r1, #U0LSR]          	;Get to LSR address from r1
    AND r2, r2, #0x1        		;Get only 1st bit(RDR)
    CMP r2, #0                		
    BEQ RC							;branch if zero
	ORR r0, r0, r0    
    LDRB r0, [r1]					;Get byte from UART into r0
	    
	LDMFD r13!, {r2-r12, r14}
    BX lr

output_character
    STMFD r13!, {r2-r12, r14}
OC    
    LDR r1, =0xE000C000 
    LDRB r2, [r1, #U0LSR]				;Get to LSR address from r1	
    AND r2, r2, #0x20        			;Get only the 5th bit(THRE)
    CMP r2, #0							;branch if zero
    BEQ OC
	ORR r0, r0, r0
    STRB r0, [r1]						;store byte from r0 into UART

	LDMFD r13!, {r2-r12, r14}
    BX lr

read_string
	STMFD r13!, {r2-r12, r14}
RS
	BL read_character				
	BL output_character
	CMP r0, #0xD                    ;check if it is enter key
	BEQ ES							;branch exit
	STRB r0, [r4]					;store byte into address in r4
	ADD r4, r4, #1					;set pointer to next byte
	LDRB r3, [r4]					
	CMP r3, #0x0					;using r3 to check if next byte is a null character
	BNE RS

ES
	ORR r0, r0, r0

	LDMFD r13!, {r2-r12, r14}
    BX lr

output_string
	STMFD r13!, {r2-r12, r14}
	LDRB r0, [r4]
OS
	BL output_character				
	ADD r4, r4, #1					;}
	LDRB r0, [r4]					;}iterate through the address till it reach a null character 
	CMP r0, #0x0					;}
	BNE OS							;}

	LDMFD r13!, {r2-r12, r14}
    BX lr
	
div_and_mod
	STMFD r13!, {r2-r12, r14}
			
	; Your code for the signed division/mod routine goes here.
	; The dividend is passed in r0 and the divisor in r1.
	; The quotient is returned in r0 and the remainder in r1.
	 								; Code start here
		
	  	MOV r8, #0                  ; Initialize r8 as Dividend/Divisor negative flag
        CMP r0, #0                  ; Compare Dividend to zero value
		BGT NDVS                    ; Branch to NDVS(Negative Divisor) if Dividend is greater than zero, if not continue
        ADD r8, r8, #1              ; Increase the Dividend negative flag by 1
        MVN r0, r0                  ; Move 1's complement of r0 into r0
        ADD r0, r0, #1              ; Add value of 1 into r0 to make it a 2's complement
									; NDVS(Negative Divisor) start here
NDVS    CMP r1, #0                  ; Compare Divisor to zero value
		BGT INTL                    ; Branch to INTL(Initial) if Divisor is greater than zero, if not continue
        ADD r8, r8, #1              ; Increase the Divisor negative flag by 1
        MVN r1, r1                  ; Move 1's complement of r1 into r1
        ADD r1, r1, #1              ; Add value of 1 into r1 to make it a 2's complement
									; INTL(Initial division start here)
INTL	MOV	r7, #0xF				; Initialize r7 as Counter to 15
		MOV r5, #0					; Initialize r5 as Quotient to 0
		MOV r1, r1, LSL r7			; Logical Left Shift Divisor in r1 by 15 places
		MOV r6, r0					; Initialize r6 as Remainder Register to store Dividend	value
									; CLOOP(Counter Loop) start here
CLOOP	SUB	r6, r6, r1				; Remainder subtracted by Divisor store into r6(remainder register)
		CMP r6, #0					; Compare Remainder to zero value
		BLT RLOOP					; Branch to RLOOP(Remainder Loop) if remainder is less than zero, if not continue
		MOV r5, r5, LSL #1			; Logical Left Shift Quotient by 1
		ORR r5, r5, #1				; Logical Bitwise OR(ORR) value of 1 to make the LSB = 1
									; LOOPC(Loop Continuation) start here
LOOPC	MOV r1, r1, LSR #1			; Logical Right Shift Divisor by 1 place so that the MSB = 0
		CMP r7, #0					; Compare Counter to zero value
		BGT DCOUNT					; Branch to DCOUNT(Decrement Counter) if Counter is greater than zero, if not continue
        CMP r8, #1                  ; Compare negative flag to value of 1
        BEQ NQUO                    ; Branch to NQUO(Negative Quotient) if negative flag equal to one, if not continue
		B	FINAL					; Branch to FINAL
									; DCOUNT(Decrement Counter) start here
DCOUNT	SUB r7, r7, #1				; Subtract Counter by 1 value
		B	CLOOP					; Branch to CLOOP(Counter Loop)
									; RLOOP(Remainder Loop) start here
RLOOP	ADD r6, r6, r1				; Add Divisor Back to Remainder and store into r6(remainder register)
		MOV r5, r5, LSL #1			; Logical Left Shift Quotient by 1 to make LSB = 0
		B	LOOPC					; Branch to LOOPC(Loop Continuation)
									; NQUO(Negative Quotient) start here
NQUO    MVN r5, r5                  ; Move 1's complement of r5 into r5
		ADD r5, r5, #1				; Add value of 1 into r5 to make it a 2's complement 
									; Final part(moving answer to r0 and r1) start here
FINAL  	MOV r0, r5					; Move value in r5(Quotient Register) to r0 
		MOV r1, r6					; Move value in r6(Remainder Register) to r1
		B	STOP					; Branch to STOP
									; STOP here
STOP

	LDMFD r13!, {r2-r12, r14}
    BX lr
	
string_conversion
	STMFD r13!, {r2-r12, r14}
	MOV r12, #0						;set negative flag to 0
	MOV r11, #10					;set decimal counter to 0
	MOV r0, #0						;clear r0
	LDRB r3, [r4]					;}
	CMP r3, #45						;}check if 1st byte is negative,if not branch SCL
	BNE SCL							;}
	MOV r12, #1						;set n flag to 1
	ADD r4, r4, #1					
SCL
	LDRB r3, [r4]					;}
	CMP r3, #48						;}
	BLT SCN							;}check if byte is numbers
	CMP r3, #57						;}
	BGT SCN							;}
	MUL r10, r0, r11				;multiple value with correct base
	MOV r0, r10						
	SUB r3, r3, #48 				;converting asciiz to decimal
	ADD r0, r0, r3					;store value into r0
	ADD r4, r4, #1
	B SCL
SCN
	CMP r12, #0						;}
	BEQ SCE							;}checking n flag, and set if required
	MVN r0, r0						;}
	ADD r0, r0, #1					;}
SCE

	LDMFD r13!, {r2-r12, r14}
    BX lr
	
display_digit_on_7_seg
	STMFD SP!,{r2-r12, lr}
	LDR r1, =0xE0028000				;load base address of IO0PIN
	LDR r2, =0xFFFFFFFF				;load a word full of 1 bits
	STR r2, [r1, #12]				;address of IO0CLR
	LDR r3, =digits_SET				;load address of digit set
	MOV r0, r0, LSL #2				;}
	LDR r2, [r3, r0]				;}To jump to the address of word in memory base on the value and set IO0SET.
	STR r2, [r1, #4]				;}
	LDMFD sp!,{r2-r12, lr}			;}
    BX lr
	
read_from_push_btns
	STMFD SP!,{r2-r12, lr}			
	LDR r12, =0xE0028014			;base address of IO1SET 
	LDR r11, =0xE0028010			;base address of IO1PIN
	LDR r10, [r12]					;}
	ORR r10, r10, #0x000F0000		;}setup for IO1SET to clear turn off LED
	STR r10, [r12]					;}
	LDR r9, [r11]						;}
	MOV r8, r9							;}Set up r7-r9 to compare changes in IO1PIN
	MOV r7, r9							;}
rfpbl
	LDR r2, = 0xE000C000    
    LDRB r3, [r2, #U0LSR]          	;Get to LSR address from r1
    AND r3, r3, #0x1        		;Get only 1st bit(RDR)
    ;CMP r3, #0
	LDRB r4, [r2]
	CMP r4, #0xD                    ;check if it is enter key
	BEQ rfpbq
	LDR r9, [r11]					;}
	AND r8, r8, r9					;}check for changes in IO1PIN
	CMP r8, r7						;}
	BEQ rfpbl
	AND r7, r7, r8					;}
	MOV r0, r7, LSR #20				;}update r7 to changes and load it into r0 as a reverse binary next step
	MVN r0, r0						;}
	BL	reverse_four_bits
	BL 	illuminateLEDs
	B	rfpbl
rfpbq
	BL	reverse_four_bits			;}
	BL	binary_conversion			;}changing value in r6 to a binary value to display in putty
	LDMFD sp!, {r2-r12, lr}
    BX lr

illuminateLEDs
	STMFD r13!, {r0-r12, r14}
	LDR r12, =0xE002801C			;base address of IO1CLR
	LDR r11, =0xE0028014			;base address of IO1SET
	LDR r10, [r11]					;}
	ORR r10, r10, #0x000F0000		;}prep LED and set them to off
	STR r10, [r11]					;}
	BL reverse_four_bits					;}
	MOV r2, r0								;}prep binary value to be set in IO1CLR(turn on)
	BIC r2, r2, #0xFFFFFFF0					;}
	MOV r10, r2, LSL #16			;set value at right bits position
	STR r10, [r12]					;set led
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
Illuminate_RGB_LED
	STMFD r13!, {r0-r12, r14}
	LDR r12, =0xE0028004			;base address of IO0SET
	LDR r2, =0x00260000				;bits set to set PORT
	STR r2, [r12]
	LDR r11, =0xE002800C			;base address of IO0CLR
	LDR r3, =colors_SET				;base address of colors set
	MOV r0, r0, LSL #2				;}
	LDR r2, [r3, r0]				;}set word in memory to set colors of RGB LED
	STR r2, [r11]					;}
	LDMFD r13!, {r0-r12, r14}
    BX lr
	
reverse_four_bits
	STMFD SP!,{r2-r12, lr}
	MOV r12, #3						;initialize counter to 3
	MOV r3, #0						;init r3 to 0(reverse word register)
	MOV r2, #0						;init r2 to 0(lsb holder)
rfbl
	AND r2, r0, #1					;get LSB
	ADD r3, r3, r2					;concatenate reverse word bits 
	MOV r3, r3, LSL #1				;}adjust both word by the bits moved
	MOV r0, r0, LSR #1				;}
	SUB r12, r12, #1					;}
	CMP r12, #0							;}check counter
	BNE rfbl
	AND r2, r0, #1						;}
	ADD r3, r3, r2						;}move the last bits into the reverse word register and store into r0
	MOV r0, r3							;}
	LDMFD sp!, {r2-r12, lr}
    BX lr
	
binary_conversion
	STMFD SP!,{r2-r12, lr}
    MOV r2, r0
	MOV r1, #10
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 1's
	MOV r0, r2                            
	ADD r0, r0, #48
	BL output_character 
bc_done
	LDMFD sp!, {r2-r12, lr}
    BX lr
	
binary_conversion_time
	STMFD SP!,{r2-r12, lr}
	MOV r2, r0
	MOV r1, #100
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 100's
	MOV r0, r2
	MOV r1, #10
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 10's
	MOV r0, r2                            
	ADD r0, r0, #48
	BL output_character 
bct_done
	LDMFD sp!, {r2-r12, lr}
    BX lr
	
binary_conversion_score
	STMFD SP!,{r2-r12, lr}
	MOV r2, r0
	LDR r1, =0x2710
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 100's
	MOV r0, r2
	MOV r1, #1000
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 100's
	MOV r0, r2
	MOV r1, #100
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 100's
	MOV r0, r2
	MOV r1, #10
	BL div_and_mod                        ;check if there is a number exist in 10's
	MOV r2, r1
	ADD r0, r0, #48
	CMP r0, #47
	BLGT output_character				  ;print out 10's
	MOV r0, r2                            
	ADD r0, r0, #48
	BL output_character 
bcs_done
	LDMFD sp!, {r2-r12, lr}
    BX lr
	
	END