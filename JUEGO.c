/* 
 * File:   JUEGO.c
 * Author: Daniela Baldizon
 *
 * Created on 22 de enero de 2020, 02:21 PM
 */







// PIC16F887 Configuration Bit Settings

// 'C' source line config statements

// CONFIG1
#pragma config FOSC = INTRC_NOCLKOUT// Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
#pragma config WDTE = OFF        // Watchdog Timer Enable bit (WDT enabled)
#pragma config PWRTE = OFF      // Power-up Timer Enable bit (PWRT disabled)
#pragma config MCLRE = ON       // RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
#pragma config CP = OFF         // Code Protection bit (Program memory code protection is disabled)
#pragma config CPD = OFF        // Data Code Protection bit (Data memory code protection is disabled)
#pragma config BOREN = OFF       // Brown Out Reset Selection bits (BOR enabled)
#pragma config IESO = OFF        // Internal External Switchover bit (Internal/External Switchover mode is enabled)
#pragma config FCMEN = OFF      // Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is enabled)
#pragma config LVP = OFF         // Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

// CONFIG2
#pragma config BOR4V = BOR40V   // Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
#pragma config WRT = OFF        // Flash Program Memory Self Write Enable bits (Write protection off)


// #pragma config statements should precede project file includes.
// Use project enums instead of #define for ON and OFF.

#include <xc.h>
#include <stdio.h>
#include <stdlib.h>

#define _XTAL_FREQ 4000000

int main() {
    //CONFIGURACION
ANSELH = 0;
ANSEL = 0;
TRISB = 0;
TRISC = 0;
TRISD = 0;
TRISAbits.TRISA0 = 0;
TRISAbits.TRISA1 = 1;
TRISAbits.TRISA2 = 1;
TRISAbits.TRISA3 = 0;
TRISAbits.TRISA4 = 1;
TRISAbits.TRISA5 = 0;
TRISAbits.TRISA6 = 0;
TRISAbits.TRISA7 = 0;

// LIMPIEZA Y DECLARACION DE VARIABLES Y PUERTOS
PORTB = 0;
PORTC = 0b11111111;
PORTD = 0;
PORTAbits.RA5 = 0; // APAGA EL LED ROJO
PORTAbits.RA6 = 0; // APAGA EL LED AMARILLO
PORTAbits.RA7 = 0; // APAGA EL LED VERDE
PORTAbits.RA0 = 0; // APAGA EL LED AZUL
PORTAbits.RA3 = 0; // APAGA EL LED BLANCO
char B1;
char B2;
char activado;
char AR1;
B1 = 0;
B2 = 0;
activado = 0;
AR1 = 0;
char AR2 = 0;

// Inicio
while (1) // LOOP INFINITO
{
    if (PORTAbits.RA2 == 1){ // SI EL BOTON DE INICIO ESTA APACHADO
        B1 = 0; //LIMPIAR LOS CONTADORES
        B2 = 0;
        PORTAbits.RA0 = 0; // APAGAR LEDS
        PORTAbits.RA3 = 0;
        PORTB = 0;
        PORTD = 0;
        PORTAbits.RA5 = 1; // ENCIENDE EL LED ROJO
        PORTC = 0b10110000; // PONE EL VALOR DE 3 EN EL DISPLAY
        __delay_ms(1000); // ESPERA UN SEGUNDO
        PORTAbits.RA5 = 0; // APAGA EL LED ROJO
        PORTAbits.RA6 = 1; // ENCIENDE EL LED AMARILLO
        PORTC = 0b10100100; // PONE UN 2 EB EL DISPLAY
        __delay_ms(1000); // ESPERA UN SEGUNDO
        PORTAbits.RA6 = 0; // APAGA EL LED AMARILLO
        PORTAbits.RA7 = 1; // ENCIENDE EL LED VERDE
        PORTC = 0b11111001; // PONE UN 1 EB EL DISPLAY
        __delay_ms(1000); // ESPERA UN SEGUNDO
        PORTAbits.RA7 = 0; // APAGA EL LED VERDE
        PORTC = 0b11111111; // 0 EN EL DISPLAY
        activado = 1; // ACTIVACION  DEL JUEGO
    
        
    }
    while (activado == 1){ // NO DEJA HACER OTRA COSA QUE NO SEA JUGAR XDXDXD
        if (PORTAbits.RA1 == 1)// REVISA EL BOTÓN 
        {
            AR1=1; // CAMBIO DE ESTADO DEL BOTON
        }
        else{
            if(AR1 == 1){
                B1++; // INCREMENTO DE CONTADOR
                AR1 = 0; // REGRESO AL BOTON ESTADO INICIAL
                __delay_ms(25); // DELAY POR SI LAS MOSCAS
            }
        }
            
            switch (B1){ // REVISION Y ASIGNACION DE VALORES PARA LOS LEDS
                case 0:
                    PORTB = 0;
                    break;
                case 1: 
                    PORTB = 0b00000001;
                    break;
                case 2:
                    PORTB = 0b00000010;
                    break;
                case 3:
                    PORTB = 0b00000100;
                    break;
                case 4:
                    PORTB = 0b00001000;
                    break;
                case 5:
                    PORTB = 0b00010000;
                    break;
                case 6:
                    PORTB = 0b00100000;
                    break;
                case 7:
                    PORTB = 0b01000000;
                    break;
                case 8:
                    PORTB = 0b10000000;
                    PORTC = 0b11111001; // PONE UN 1 EB EL DISPLAY
                    PORTAbits.RA0=1;
                    activado = 0;
                    break;
            }// CIERRE SWITCH
   
        if (PORTAbits.RA4 == 1)/////no tocar
        {
            AR2=1;
        }
        else{
            if(AR2 == 1){
                B2++;
                AR2 = 0;
                __delay_ms(25);
            }
        }
            
            switch (B2){
                case 0:
                    PORTD = 0;
                    break;
                case 1: 
                    PORTD = 0b00000001;
                    break;
                case 2:
                    PORTD = 0b00000010;
                    break;
                case 3:
                    PORTD = 0b00000100;
                    break;
                case 4:
                    PORTD = 0b00001000;
                    break;
                case 5:
                    PORTD = 0b00010000;
                    break;
                case 6:
                    PORTD = 0b00100000;
                    break;
                case 7:
                    PORTD = 0b01000000;
                    break;
                case 8:
                    PORTD = 0b10000000;
                    PORTC = 0b10100100; // PONE UN 1 EB EL DISPLAY
                    PORTAbits.RA3=1;
                    activado = 0;
                    break;
            }// CIERRE SWITCH
  
}
            
}} // CIERRE MAIN