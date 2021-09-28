#include <avr/io.h>
unsigned char input ,output;

void main(){
	DDRA = 0x00;	//Port A as input
	DDRC = 0xFF;	//Port C as output
	output = 0x00;
	PORTC = output;	//Initialise Port C
	unsigned char A, B, C, D, E, F0, F1, F2;
	unsigned char temp1, temp2, temp3;
	while(1){
		input = PINA;
		A = input & 0x01;
		B = (input & 0x02)>>1;
		C = (input & 0x04)>>2;
		D = (input & 0x08)>>3;
		E = (input & 0x10)>>4;
		temp1 = A & B & C;
		temp2 = C & D;
		temp3 = D & E;
		temp2 = temp1 | temp2 | temp3;
		F0 = ~temp2;
		temp2 = (~D) & (~E);
		F1 = temp1 | temp2;
		F2 = F0 | F1;
		F0 = F0 & 0x01;
		F1 = F1 & 0x01;
		F2 = F2 & 0x01;
		F0 = F0 << 5;
		F1 = F1 << 6;
		F2 = F2 << 7;
		output = F0 | F1 | F2;
		PORTC = output;
	}
}