#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
;***************************
   GPR_VAR        UDATA
   W_TEMP         RES       1      ; w register for context saving (ACCESS)
   STATUS_TEMP    RES       1      ; status used for context saving
   DELAY1	  RES	    1
   DELAY2	  RES	    1
   SERVO	  RES	    1
   SERVO1	  RES	    1
   CONT		  RES	    1
   POT3		  RES	    1   
   CONTP2	  RES	    1
   POT4		  RES	    1
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
;*******************************************************************************
;   INTERRUPCIONES
;*******************************************************************************
ISR_VECT    CODE    0x0004
PUSH:
    MOVWF   W_TEMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TEMP
ISR:
    BTFSC   INTCON, 2
    CALL    PWMA
    
POP:
    SWAPF   STATUS_TEMP, W
    MOVWF   STATUS
    SWAPF   W_TEMP, F
    SWAPF   W_TEMP, W
    RETFIE
;*******************************************************************************
; MAIN PROGRAM
    MAIN_PROG CODE                      ; let linker place main program

START
;*******************************************************************************
    CALL    CONFIG_RELOJ		; RELOJ INTERNO DE 1Mhz
    CALL    CONFIG_IO
    CALL    CONFIG_TX_RX		; 10417hz
    CALL    CONFIG_ADC			; canal 0, fosc/8, adc on, justificado a la izquierda, Vref interno (0-5V)
    CALL    CONFIG_PWM1
    CALL    CONFIG_TIMER
    CALL    CONFIG_PWM2
    BANKSEL PORTA
;*******************************************************************************
; LIMPIEZA DE VARIABLES
;*******************************************************************************
   CLRF	    SERVO
   CLRF	    SERVO1
   CLRF	    POT3
   CLRF	    POT4
;*******************************************************************************
; MACROS
;*******************************************************************************
NOMOVER	    MACRO   PUERTO, PIN	,LABEL   ; MACRO PARA NO MOVER EL SERVO
	    BCF	PUERTO, PIN
	    GOTO    LABEL
	    ENDM
	    
RUN	MACRO	VAR, PUERTO, PIN
	INCF	VAR
	BSF	PUERTO, PIN
	ENDM
;*******************************************************************************
; MAIN LOOP
;*******************************************************************************
LOOP:
    BCF ADCON0, CHS3		; CH0
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BCF ADCON0, CHS0
    CALL    DELAY_500US		    ; DELAY
    BSF	    ADCON0, GO		    ; EMPIEZA LA CONVERSIÓN
VERADC1:
    BTFSC   ADCON0, GO		    ; REVISA SI LA CONVERSIÓN SE COMPLETÓ
    GOTO    VERADC1		    ; SI NO, REVISA OTRA VEZ
    MOVF    ADRESH, W		    ; MUEVE LOS BITS DEL ADRESH A W
    MOVWF   POT3		    ; LOS MUEVE A UNA VARIABLE
    BCF	    PIR1, ADIF	
      
    BCF ADCON0, CHS3		; CH1
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BSF ADCON0, CHS0
    CALL    DELAY_50MS
    BSF	    ADCON0, GO		    ; EMPIEZA LA CONVERSIÓN
VERADC2:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    VERADC2
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVFW   ADRESH
    MOVWF   SERVO		; MOVEMOS EL VALOR HACIA VARIABLE SERVO
    MOVWF   CCPR2L			; MOVEMOS EL VALOR HACIA EL PERÍODO DEL PWM
    
    BCF ADCON0, CHS3		; CH2
    BCF ADCON0, CHS2
    BSF ADCON0, CHS1
    BCF ADCON0, CHS0
    CALL    DELAY_50MS
    BSF	    ADCON0, GO		    ; EMPIEZA LA CONVERSIÓN
VERADC3:
    BTFSC   ADCON0, GO			; revisa que terminó la conversión
    GOTO    VERADC3
    BCF	    PIR1, ADIF			; borramos la bandera del adc
    MOVFW   ADRESH
    MOVWF   SERVO		; MOVEMOS EL VALOR HACIA VARIABLE SERVO
    MOVWF   CCPR1L			; MOVEMOS EL VALOR HACIA EL PERÍODO DEL PWM
    
    BCF ADCON0, CHS3		; CH3
    BCF ADCON0, CHS2
    BSF ADCON0, CHS1
    BSF ADCON0, CHS0
    CALL    DELAY_500US		    ; DELAY
    BSF	    ADCON0, GO		    ; EMPIEZA LA CONVERSIÓN
VERADC4:
    BTFSC   ADCON0, GO		    ; REVISA SI LA CONVERSIÓN SE COMPLETÓ
    GOTO    VERADC4		    ; SI NO, REVISA OTRA VEZ
    MOVF    ADRESH, W		    ; MUEVE LOS BITS DEL ADRESH A W
    MOVWF   POT4		    ; LOS MUEVE A UNA VARIABLE
    BCF	    PIR1, ADIF	

CHECK_RCIF:			    ; RECIBE EN RX y lo manda al registro que controla al servo
    BTFSS   PIR1, RCIF
    GOTO    CHECK_TXIF
    MOVF    RCREG, W
    MOVWF   CCPR2L
    
CHECK_TXIF: 
    BTFSS   PIR1, TXIF
    GOTO    CHECK_TXIF
    MOVFW   SERVO		    ; ENVÍA SERVO POR EL TX
    MOVWF   TXREG
   
    GOTO LOOP
;*******************************************************************************
PWMA:
    BCF	    INTCON, 2		    ; LIMPIA LA BANDERA DEL TMR0
    MOVLW   .252		    ; N PARA UN PERÍODO DE 500 MS
    MOVWF   TMR0
    MOVLW   .0
    SUBWF   POT3,0		    ; REVISA SI EL POTENCIÓMTERO 3 ESTÁ EN CERO
    BTFSC   STATUS, Z
    CALL    NOMOVER1		    ; SUB RUTINA 
    RUN	    CONT, PORTC, 0			    ; 
    CONTINUAR
    MOVF    POT3,0
    SUBWF   CONT
    BTFSS   STATUS, C
    BCF	    PORTC, 0
    
    SUBWF   POT4,0		    ; REVISA SI EL POTENCIÓMTERO 4 ESTÁ EN CERO
    BTFSC   STATUS, Z
    CALL    NOMOVER2		    ; SUB RUTINA 
    RUN	    CONTP2, PORTC, 3			    ; 
    CONTINUAR2
    MOVF    POT4,3
    SUBWF   CONTP2
    BTFSS   STATUS, C
    BCF	    PORTC, 3
    
    RETURN

NOMOVER1:
    NOMOVER PORTC, 0, CONTINUAR
    
NOMOVER2:
    NOMOVER PORTC, 3, CONTINUAR2
    
CONFIG_RELOJ
    BANKSEL TRISA
    
    BSF OSCCON, IRCF2
    BCF OSCCON, IRCF1
    BSF OSCCON, IRCF0		    ; FRECUENCIA DE 2MHz
    RETURN
 
 ;------------------------------------------------------------------------------
CONFIG_TX_RX
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC		    ; ASINCRÓNO
    BSF	    TXSTA, BRGH		    ; LOW SPEED
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16	    ; 8 BITS BAURD RATE GENERATOR
    BANKSEL SPBRG
    MOVLW   .51	    
    MOVWF   SPBRG		    ; CARGAMOS EL VALOR DE BAUDRATE CALCULADO
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN		    ; HABILITAR SERIAL PORT
    BCF	    RCSTA, RX9		    ; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	    RCSTA, CREN		    ; HABILITAMOS LA RECEPCIÓN 
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN		    ; HABILITO LA TRANSMISION
    
    RETURN
;-------------------------------------------------------------------------------
CONFIG_IO
    BANKSEL TRISA
    CLRF    TRISA
    CLRF    TRISC
    CLRF    TRISD
    CLRF    TRISB
    BANKSEL ANSEL
    CLRF    ANSEL
    CLRF    ANSELH
    BANKSEL PORTA
    CLRF    PORTA
    CLRF    PORTC
    CLRF    PORTB
    RETURN    
;-------------------------------------------------------------------------------
CONFIG_ADC
    BANKSEL PORTA
    BCF ADCON0, ADCS1
    BSF ADCON0, ADCS0		; FOSC/8 RELOJ TAD
    
    BCF ADCON0, CHS3		; CH0
    BCF ADCON0, CHS2
    BCF ADCON0, CHS1
    BCF ADCON0, CHS0	
    BANKSEL TRISA
    BCF ADCON1, ADFM		; JUSTIFICACIÓN A LA IZQUIERDA
    BCF ADCON1, VCFG1		; VSS COMO REFERENCIA VREF-
    BCF ADCON1, VCFG0		; VDD COMO REFERENCIA VREF+
    BANKSEL PORTA
    BSF ADCON0, ADON		; ENCIENDO EL MÓDULO ADC
    
    BANKSEL TRISA
    BSF	    TRISA, RA0		; RA0 COMO ENTRADA
    BSF	    TRISA, RA1
    BSF	    TRISA, RA2
    BSF	    TRISA, RA3
    BANKSEL ANSEL
    BSF	    ANSEL, 0		; ANS0 COMO ENTRADA ANALÓGICA
    BSF	    ANSEL, 1
    BSF	    ANSEL, 2
    BSF	    ANSEL, 3
    
    RETURN
;-------------------------------------------------------------------------------
DELAY_50MS
    MOVLW   .100		    ; 1US 
    MOVWF   DELAY2
    CALL    DELAY_500US
    DECFSZ  DELAY2		    ;DECREMENTA CONT1
    GOTO    $-2			    ; IR A LA POSICION DEL PC - 1
    RETURN
    
DELAY_500US
    MOVLW   .250		    ; 1US 
    MOVWF   DELAY1	    
    DECFSZ  DELAY1		    ;DECREMENTA CONT1
    GOTO    $-1			    ; IR A LA POSICION DEL PC - 1
    RETURN
;-------------------------------------------------------------------------------
CONFIG_PWM1
    BANKSEL TRISC
    BSF	    TRISC, RC1		; ESTABLEZCO RC1 / CCP2 COMO ENTRADA
    MOVLW   .255
    MOVWF   PR2			; COLOCO EL VALOR DEL PERIODO DE MI SEÑAL 10mS
    
    BANKSEL PORTA
    BSF	    CCP2CON, CCP2M3
    BSF	    CCP2CON, CCP2M2
    BSF	    CCP2CON, CCP2M1
    BSF	    CCP2CON, CCP2M0		    ; MODO PWM
   
    MOVLW   B'00011011'
    MOVWF   CCPR2L		    ; MSB   DEL DUTY CICLE
    BSF	    CCP2CON, DC2B0
    BSF	    CCP2CON, DC2B1	    ; LSB del duty cicle
    
    BCF	    PIR1, TMR2IF
    
    BSF	    T2CON, T2CKPS1
    BSF	    T2CON, T2CKPS0	    ; PRESCALER 1:16
    
    BSF	    T2CON, TMR2ON	    ; HABILITAMOS EL TMR2
    BTFSS   PIR1, TMR2IF
    GOTO    $-1
    BCF	    PIR1, TMR2IF
    
    BANKSEL TRISC
    BCF	    TRISC, RC1		    ; RC1 / CCP2 SALIDA PWM
    RETURN
    
CONFIG_PWM2
    BCF	    STATUS, RP1
    BSF	    STATUS, RP0		    ; BANCO 1
    BSF	    TRISC, RC2		    ; ESTABLECE RC1 / CCP2 COMO ENTRADA
    MOVLW   .255		    ; 2.5
    MOVWF   PR2			    ; SEÑAL DE 20 MS PARA EL TMR2

    BCF	    STATUS, RP1		    ; BANCO 0
    BCF	    STATUS, RP0
    BSF	    CCP1CON, CCP1M3
    BSF	    CCP1CON, CCP1M2
    BCF	    CCP1CON, CCP1M1
    BCF	    CCP1CON, CCP1M0	    ; MODO PWM

    MOVLW   B'00011011'		    ; 
    MOVWF   CCPR1L		    ; MSB DEL DUTY CYCLE
    BSF	    CCP1CON, DC1B0
    BSF	    CCP1CON, DC1B1	    ; LSB 
    BCF	    PIR1, TMR2IF	    ; SE LIMPIA LA BANDERA DEL TMR2
    BSF	    T2CON, T2CKPS1
    BSF	    T2CON, T2CKPS0	    ; PRESCALER 1:16
    BSF	    T2CON, TMR2ON	    ; SE HABILITA EL TMR2
    BTFSS   PIR1, TMR2IF	    ; NO SIGUE HASTA QUE LA BANDERA SEA 1
    GOTO    $-1
    BCF	    PIR1, TMR2IF	    ; LIMPIA LA BANDERA
    BCF	    STATUS, RP1
    BSF	    STATUS, RP0		    ; BANCO 1
    BCF	    TRISC, RC2		    ; RC2 / CCP1 SALIDA PWM
    RETURN
   
CONFIG_TIMER
 BSF	    STATUS, 5
 BCF	    STATUS, 6		; BANCO 1
 BCF	    OPTION_REG, 5	; ACTIVAR TIMER0 COMO TEMPORIZADOR
 BCF	    OPTION_REG, 3	; PRESCALER ASIGNADO AL TIMER0
 BSF	    OPTION_REG, 2	; CONFIGURACION DEL PRESCALER
 BSF	    OPTION_REG, 1	; 1:256
 BSF	    OPTION_REG, 0
 BCF	    STATUS, 5
 BCF	    STATUS, 6		    ; BANCO 0
 BSF	    INTCON, GIE		    ;
 BCF	    INTCON, PEIE	    ;
 BSF	    INTCON, T0IE	    ;
 BCF	    INTCON, T0IF	    ; ACTIVAR LAS INTERRUPCIONES DEL TMR0
 MOVLW	    .252		    ; 2.5 MS DE PERIODO
 MOVWF	    TMR0		    ; LE ASIGNA EL 12 AL TIMER0
 RETURN
    
    END
