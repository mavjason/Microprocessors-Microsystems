#include<mega 16.h>
unsigned char z,output;

void main(){
	DDRC=0x00; //eisodos
	DDRA=0xFF; //eksodos
	unsigned char temp4,temp3,temp2,temp1,temp0,temp4_new,temp3_new,temp2_new,temp1_new,temp0_new;
	output=0x80;
	PORTA=output;
	temp4 = 0;
	temp3 = 0;
	temp2 = 0;
	temp1 = 0;
	temp0 = 0;
	while(1){
		z=PINC;
		temp4_new=z&0x10;
		temp3_new=z&0x08;
		temp2_new=z&0x04;
		temp1_new=z&0x02;
		temp0_new=z&0x01;
		if( (temp4!=0) && (temp4_new==0) ){
			output=0x80;
			PORTA=output;			
		}
		else if( (temp3!=0) && (temp3_new==0) ){
			if(output==0x40){
				output=0x01;
				PORTA=output;
			}
			else if(output==0x80){
				output=0x02;
				PORTA=output;
			}
			else{
				output=output<<2;
				PORTA=output;
			}
		}
		else if( (temp2!=0) && (temp2_new==0)){
			if(output==0x02){
				output=0x80;
				PORTA=output;
			}
			else if(output==0x01){
				output=0x40;
				PORTA=output;
			}
			else{
				output=output>>2;
				PORTA=output;
			}
		}
		else if( (temp1!=0) && (temp1_new==0) ){
			if(output==0x80){
				output=0x01;
				PORTA=output;
			}
			else{
				output=output<<1;
				PORTA=output;
			}
		}
		else if( (temp0!=0) && (temp0_new==0) ){
			if(output==0x01){
				output=0x80;
				PORTA=output;
			}
			else{
				output=output>>1;
				PORTA=output;
			}
		}
		temp0=temp0_new;
		temp1=temp1_new;
		temp2=temp2_new;
		temp3=temp3_new;
		temp4=temp4_new;
	}
}
