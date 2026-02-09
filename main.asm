;
; PRELAB.asm
;
;Creado: 2/febrero/2026
;Autor : Wendy Samira Hernández Rivera
;Descripción:Contador de 4 bits, con la implementación de dos botones uno que incrementa y otro que decrementa
;

.include "m328pbdef.inc"

; =========================
; REGISTROS
; =========================
.def cont1 = r16		//Contador 1
.def cont2 = r17		//Contador 2
.def temp  = r18		//Operaciones intermedias
.def portb_t  = r19 	//Copia de los puertos
.def portc_t = r20		//Copia de los puertos


; =========================
; RESET
; =========================
.cseg
.org 0x0000
    rjmp RESET

RESET:
    ; Configuración de Pila
    ldi temp, LOW(RAMEND)
    out SPL, temp
    ldi temp, HIGH(RAMEND)
    out SPH, temp

; =========================
; CONFIGURACIÓN CONTADOR 1
; =========================
    ; LEDs D13–D10 (PB5–PB2) como salida
    sbi DDRB, 5
    sbi DDRB, 4
    sbi DDRB, 3
    sbi DDRB, 2

    ; Botones D9 y D8 (PB1, PB0) como entrada
    cbi DDRB, 1
    cbi DDRB, 0
    ; Pull-up internos
    sbi PORTB, 1
    sbi PORTB, 0

; =========================
; CONFIGURACIÓN CONTADOR 2
; =========================
    ; LEDs A0-A3 (PC0-PC3) como salida
    sbi DDRC, 0
    sbi DDRC, 1
    sbi DDRC, 2
    sbi DDRC, 3

    ; Botones A4 y A5 (PC4,PC5) como entrada
    cbi DDRC, 4
    cbi DDRC, 5
    ; Pull-up internos
    sbi PORTC, 4
    sbi PORTC, 5

    clr cont1		//Pone el contador en 0
	clr cont2
; =========================
; LOOP PRINCIPAL
;Botón suelto = 1
;Botón presionado = 0
; =========================
LOOP:
;-------------Contador 1--------------
    sbis PINB, 1  //Verifica si el botón esta presionado, entra a incrementar
    rjmp INC1
	sbis PINB, 0  //Verifica si el botón esta presionado, entra a decrementar
    rjmp DEC1
;-------------Contador 2--------------
    sbis PINC, 4  //Verifica si el botón esta presionado, entra a incrementar
    rjmp INC2
	sbis PINC, 5  //Verifica si el botón esta presionado, entra a decrementar
    rjmp DEC2


    rjmp LOOP

; =========================
; CONTADOR 1
; =========================
INC1:
    rcall DELAY
    sbis PINB, 1		//Verifica si el PB1 esta presionado 
    rjmp DO_INC1
    rjmp LOOP
DO_INC1: 
	inc cont1	//Incrementa en 1
	andi cont1, 0x0F	//Mantiene el valor entre 0 y 15
	rcall LEDS1
WAIT1I:
	sbic PINB, 1
	rjmp WAIT1I
	rjmp LOOP

DEC1: 
rcall DELAY
    sbis PINB, 0		//Verifica si el PB0 esta presionado 
    rjmp DO_DEC1
    rjmp LOOP
DO_DEC1: 
	tst cont1
	brne D1OK
	ldi cont1, 16	//Carga 16 como numero para decrementar
D1OK: 
	dec cont1	//Decrementa en 1 el contador
	rcall LEDS1
WAIT1D:
	sbic PINB, 0
	rjmp WAIT1D
	rjmp LOOP



; =========================
; CONTADOR 2
; =========================
INC2:
    rcall DELAY
    sbis PINC, 4		//Verifica si el botón esta presionado
    rjmp DO_INC2
    rjmp LOOP
DO_INC2: 
	inc cont2	//Incrementa en 1
	andi cont2, 0x0F	//Limita el contador a 16 bits
	rcall LEDS2
WAIT2I:
	sbic PINC, 4	//Verifica si esta presionado el botón
	rjmp WAIT2I
	rjmp LOOP

DEC2: 
rcall DELAY
    sbis PINC, 5		//Verifica si el PB0 esta presionado 
    rjmp DO_DEC2
    rjmp LOOP
DO_DEC2: 
	tst cont2
	brne D2OK
	ldi cont2, 16	//Carga 16 como numero para decrementar
D2OK: 
	dec cont2	//Decrementa en 1 el contador
	rcall LEDS2
WAIT2D:
	sbic PINC, 5
	rjmp WAIT2D
	rjmp LOOP

; =========================
; MOSTRAR EN LEDS
; =========================
LEDS1:
    in portb_t, PORTB
    andi portb_t, 0b00000011   //Conservar puertos de push button
    mov temp, cont1
    lsl temp
    lsl temp                 //Mover puertos de LEDs
    or portb_t, temp
    out PORTB, portb_t	//Escribe las LEDS sin afectar entradas
    ret

LEDS2:
    in portc_t, PORTC
    andi portc_t, 0b11110000  //Conservar puertos de push button
    or portc_t, cont2
    out PORTC, portc_t	//Escribe las LEDS sin afectar entradas
    ret

; =========================
; DELAY ANTIRREBOTE
; =========================
DELAY:
    ldi r19, 120		//Carga un valor inicial
D1:
    ldi r20, 255	//Bucle que deja un tiempo 
D2:
    dec r20	//Resta uno a r20 hasta verificar que llega a 0
    brne D2
    dec r19
    brne D1
    ret

