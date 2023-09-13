module SMC(
  // Input signals
    mode,
    W_0, V_GS_0, V_DS_0,
    W_1, V_GS_1, V_DS_1,
    W_2, V_GS_2, V_DS_2,
    W_3, V_GS_3, V_DS_3,
    W_4, V_GS_4, V_DS_4,
    W_5, V_GS_5, V_DS_5,   
  // Output signals
    out_n
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [2:0] W_0, V_GS_0, V_DS_0;
input [2:0] W_1, V_GS_1, V_DS_1;
input [2:0] W_2, V_GS_2, V_DS_2;
input [2:0] W_3, V_GS_3, V_DS_3;
input [2:0] W_4, V_GS_4, V_DS_4;
input [2:0] W_5, V_GS_5, V_DS_5;
input [1:0] mode;
//output [8:0] out_n;         							// use this if using continuous assignment for out_n  // Ex: assign out_n = XXX;
 output reg [9:0] out_n; 								// use this if using procedure assignment for out_n   // Ex: always@(*) begin out_n = XXX; end

//================================================================
//    Wire & Registers 
//================================================================
// Declare the wire/reg you would use in your circuit
// remember 
// wire for port connection and cont. assignment
// reg for proc. assignment
wire [2:0]Vov0,Vov1,Vov2,Vov3,Vov4,Vov5;
wire [6:0]W_VDS0,W_VDS1,W_VDS2,W_VDS3,W_VDS4,W_VDS5;
wire [6:0]W_Vov0,W_Vov1,W_Vov2,W_Vov3,W_Vov4,W_Vov5;
wire [6:0]VDS_2Vov_VDS0,VDS_2Vov_VDS1,VDS_2Vov_VDS2,VDS_2Vov_VDS3,VDS_2Vov_VDS4,VDS_2Vov_VDS5;
wire [5:0]Vov_Vov0,Vov_Vov1,Vov_Vov2,Vov_Vov3,Vov_Vov4,Vov_Vov5;
wire [8:0]W_Vov_Vov0,W_Vov_Vov1,W_Vov_Vov2,W_Vov_Vov3,W_Vov_Vov4,W_Vov_Vov5;        
wire [8:0]W_VDS_2Vov_VDS0,W_VDS_2Vov_VDS1,W_VDS_2Vov_VDS2,W_VDS_2Vov_VDS3,W_VDS_2Vov_VDS4,W_VDS_2Vov_VDS5;
         
//wire Triode_mode0,Triode_mode1,Triode_mode2,Triode_mode3,Triode_mode4,Triode_mode5;
//wire [8:0]I_0,I_1,I_2,I_3,I_4,I_5;
//
//wire [6:0]gm_0,gm_1,gm_2,gm_3,gm_4,gm_5;

wire [6:0]I_gm0,I_gm1,I_gm2,I_gm3,I_gm4,I_gm5;
//================================================================
//    DESIGN
//================================================================
// --------------------------------------------------
// write your design here
// --------------------------------------------------
VGS_VTH Vov_0(.VGS(V_GS_0),.Vov(Vov0));
VGS_VTH Vov_1(.VGS(V_GS_1),.Vov(Vov1));
VGS_VTH Vov_2(.VGS(V_GS_2),.Vov(Vov2));
VGS_VTH Vov_3(.VGS(V_GS_3),.Vov(Vov3));
VGS_VTH Vov_4(.VGS(V_GS_4),.Vov(Vov4));
VGS_VTH Vov_5(.VGS(V_GS_5),.Vov(Vov5));

///2WVDS
mult1 W_VDS_0(.x(W_0),.y({V_DS_0,1'b0}),.out(W_VDS0));
mult1 W_VDS_1(.x(W_1),.y({V_DS_1,1'b0}),.out(W_VDS1));
mult1 W_VDS_2(.x(W_2),.y({V_DS_2,1'b0}),.out(W_VDS2));
mult1 W_VDS_3(.x(W_3),.y({V_DS_3,1'b0}),.out(W_VDS3));
mult1 W_VDS_4(.x(W_4),.y({V_DS_4,1'b0}),.out(W_VDS4));
mult1 W_VDS_5(.x(W_5),.y({V_DS_5,1'b0}),.out(W_VDS5));

//2WVov
mult1 W_Vov_0(.x(W_0),.y({Vov0,1'b0}),.out(W_Vov0));
mult1 W_Vov_1(.x(W_1),.y({Vov1,1'b0}),.out(W_Vov1));
mult1 W_Vov_2(.x(W_2),.y({Vov2,1'b0}),.out(W_Vov2));
mult1 W_Vov_3(.x(W_3),.y({Vov3,1'b0}),.out(W_Vov3));
mult1 W_Vov_4(.x(W_4),.y({Vov4,1'b0}),.out(W_Vov4));
mult1 W_Vov_5(.x(W_5),.y({Vov5,1'b0}),.out(W_Vov5));

//VDS(2Vov-VDS)
mult1 VDS_2Vov_VDS_0(.x(V_DS_0),.y({Vov0,1'b0}-V_DS_0),.out(VDS_2Vov_VDS0));
mult1 VDS_2Vov_VDS_1(.x(V_DS_1),.y({Vov1,1'b0}-V_DS_1),.out(VDS_2Vov_VDS1));
mult1 VDS_2Vov_VDS_2(.x(V_DS_2),.y({Vov2,1'b0}-V_DS_2),.out(VDS_2Vov_VDS2));
mult1 VDS_2Vov_VDS_3(.x(V_DS_3),.y({Vov3,1'b0}-V_DS_3),.out(VDS_2Vov_VDS3));
mult1 VDS_2Vov_VDS_4(.x(V_DS_4),.y({Vov4,1'b0}-V_DS_4),.out(VDS_2Vov_VDS4));
mult1 VDS_2Vov_VDS_5(.x(V_DS_5),.y({Vov5,1'b0}-V_DS_5),.out(VDS_2Vov_VDS5));

//Vov*Vov
mult Vov_Vov_0(.x(Vov0),.y(Vov0),.out(Vov_Vov0));
mult Vov_Vov_1(.x(Vov1),.y(Vov1),.out(Vov_Vov1));
mult Vov_Vov_2(.x(Vov2),.y(Vov2),.out(Vov_Vov2));
mult Vov_Vov_3(.x(Vov3),.y(Vov3),.out(Vov_Vov3));
mult Vov_Vov_4(.x(Vov4),.y(Vov4),.out(Vov_Vov4));
mult Vov_Vov_5(.x(Vov5),.y(Vov5),.out(Vov_Vov5));

//W*Vov*Vov
mult2 W_Vov_Vov_0(.x(W_0),.y(Vov_Vov0),.out(W_Vov_Vov0));
mult2 W_Vov_Vov_1(.x(W_1),.y(Vov_Vov1),.out(W_Vov_Vov1));
mult2 W_Vov_Vov_2(.x(W_2),.y(Vov_Vov2),.out(W_Vov_Vov2));
mult2 W_Vov_Vov_3(.x(W_3),.y(Vov_Vov3),.out(W_Vov_Vov3));
mult2 W_Vov_Vov_4(.x(W_4),.y(Vov_Vov4),.out(W_Vov_Vov4));
mult2 W_Vov_Vov_5(.x(W_5),.y(Vov_Vov5),.out(W_Vov_Vov5));

//W*VDS(2Vov-VDS)
mult3 W_VDS_2Vov_VDS_0(.x(W_0),.y(VDS_2Vov_VDS0),.out(W_VDS_2Vov_VDS0));
mult3 W_VDS_2Vov_VDS_1(.x(W_1),.y(VDS_2Vov_VDS1),.out(W_VDS_2Vov_VDS1));
mult3 W_VDS_2Vov_VDS_2(.x(W_2),.y(VDS_2Vov_VDS2),.out(W_VDS_2Vov_VDS2));
mult3 W_VDS_2Vov_VDS_3(.x(W_3),.y(VDS_2Vov_VDS3),.out(W_VDS_2Vov_VDS3));
mult3 W_VDS_2Vov_VDS_4(.x(W_4),.y(VDS_2Vov_VDS4),.out(W_VDS_2Vov_VDS4));
mult3 W_VDS_2Vov_VDS_5(.x(W_5),.y(VDS_2Vov_VDS5),.out(W_VDS_2Vov_VDS5));

//assign Triode_mode0=(Vov0>V_DS_0)?1:0;
//assign Triode_mode1=(Vov1>V_DS_1)?1:0;
//assign Triode_mode2=(Vov2>V_DS_2)?1:0;
//assign Triode_mode3=(Vov3>V_DS_3)?1:0;
//assign Triode_mode4=(Vov4>V_DS_4)?1:0;
//assign Triode_mode5=(Vov5>V_DS_5)?1:0;
/*
assign I_0=(Triode_mode0)?W_VDS_2Vov_VDS0:W_Vov_Vov0;
assign I_1=(Triode_mode1)?W_VDS_2Vov_VDS1:W_Vov_Vov1;
assign I_2=(Triode_mode2)?W_VDS_2Vov_VDS2:W_Vov_Vov2;
assign I_3=(Triode_mode3)?W_VDS_2Vov_VDS3:W_Vov_Vov3;
assign I_4=(Triode_mode4)?W_VDS_2Vov_VDS4:W_Vov_Vov4;
assign I_5=(Triode_mode5)?W_VDS_2Vov_VDS5:W_Vov_Vov5;

assign gm_0=(Triode_mode0)?W_VDS0:W_Vov0;
assign gm_1=(Triode_mode1)?W_VDS1:W_Vov1;
assign gm_2=(Triode_mode2)?W_VDS2:W_Vov2;
assign gm_3=(Triode_mode3)?W_VDS3:W_Vov3;
assign gm_4=(Triode_mode4)?W_VDS4:W_Vov4;
assign gm_5=(Triode_mode5)?W_VDS5:W_Vov5;

assign I_gm0=((mode[0])?I_0:gm_0)/3;
assign I_gm1=((mode[0])?I_1:gm_1)/3;
assign I_gm2=((mode[0])?I_2:gm_2)/3;
assign I_gm3=((mode[0])?I_3:gm_3)/3;
assign I_gm4=((mode[0])?I_4:gm_4)/3;
assign I_gm5=((mode[0])?I_5:gm_5)/3;
*/
assign I_gm0=((mode[0])?((Vov0>V_DS_0)?W_VDS_2Vov_VDS0:W_Vov_Vov0):((Vov0>V_DS_0)?W_VDS0:W_Vov0))/3;
assign I_gm1=((mode[0])?((Vov1>V_DS_1)?W_VDS_2Vov_VDS1:W_Vov_Vov1):((Vov1>V_DS_1)?W_VDS1:W_Vov1))/3;
assign I_gm2=((mode[0])?((Vov2>V_DS_2)?W_VDS_2Vov_VDS2:W_Vov_Vov2):((Vov2>V_DS_2)?W_VDS2:W_Vov2))/3;
assign I_gm3=((mode[0])?((Vov3>V_DS_3)?W_VDS_2Vov_VDS3:W_Vov_Vov3):((Vov3>V_DS_3)?W_VDS3:W_Vov3))/3;
assign I_gm4=((mode[0])?((Vov4>V_DS_4)?W_VDS_2Vov_VDS4:W_Vov_Vov4):((Vov4>V_DS_4)?W_VDS4:W_Vov4))/3;
assign I_gm5=((mode[0])?((Vov5>V_DS_5)?W_VDS_2Vov_VDS5:W_Vov_Vov5):((Vov5>V_DS_5)?W_VDS5:W_Vov5))/3;


wire [6:0] a0, a1, a2, a3, a4, a5;
wire [6:0] b0, b1, b2, b3, b4, b5;
wire [6:0] c0, c1, c2, c3, c4, c5;
wire [6:0] d0, d1, d2, d3, e0, e1;

assign a0 = (I_gm0 > I_gm1) ? I_gm0 : I_gm1;
assign a1 = (I_gm0 > I_gm1) ? I_gm1 : I_gm0;
assign a2 = (I_gm2 > I_gm3) ? I_gm2 : I_gm3;
assign a3 = (I_gm2 > I_gm3) ? I_gm3 : I_gm2;
assign a4 = (I_gm4 > I_gm5) ? I_gm4 : I_gm5;
assign a5 = (I_gm4 > I_gm5) ? I_gm5 : I_gm4;
assign b0 = (a0 > a2) ? a0 : a2;
assign b1 = (a0 > a2) ? a2 : a0;
assign b2 = (a1 > a4) ? a1 : a4;
assign b3 = (a1 > a4) ? a4 : a1;
assign b4 = (a3 > a5) ? a3 : a5;
assign b5 = (a3 > a5) ? a5 : a3;
assign c0 = (b0 > b2) ? b0 : b2; //0
assign c1 = (b0 > b2) ? b2 : b0;
assign c2 = (b1 > b4) ? b1 : b4;
assign c3 = (b1 > b4) ? b4 : b1;
assign c4 = (b3 > b5) ? b3 : b5;
assign c5 = (b3 > b5) ? b5 : b3; //5
assign d0 = (c1 > c2) ? c1 : c2; //1
assign d1 = (c1 > c2) ? c2 : c1;
assign d2 = (c3 > c4) ? c3 : c4;
assign d3 = (c3 > c4) ? c4 : c3; //4
assign e0 = (d1 > d2) ? d1 : d2; //2
assign e1 = (d1 > d2) ? d2 : d1; //3

always@(*)begin
    case(mode)
	  2'd0:out_n=e1+d3+c5;
	  2'd1:out_n=(e1<<1)+e1+(d3<<2)+(c5<<2)+c5;
	  2'd2:out_n=c0+d0+e0;
	  2'd3:out_n=(c0<<1)+c0+(d0<<2)+(e0<<2)+e0;
	endcase
end
endmodule
 

module VGS_VTH(VGS,Vov);
 input  [2:0]VGS;
 output [2:0]Vov;

 assign Vov[2]=VGS[2]&(VGS[1]|VGS[0]); 
 assign Vov[1]=~VGS[1]^VGS[0];
 assign Vov[0]=~VGS[0];  
 
endmodule

module mult(x,y,out);
   input  [2:0]x,y;
   output [5:0]out;

   wire [5:0]temp1,temp2,temp3;

   assign temp1=y[0]?x:6'd0;
   assign temp2=y[1]?x<<1:6'd0;
   assign temp3=y[2]?x<<2:6'd0;
   assign out = temp1+temp2+temp3;
endmodule

module mult1(x,y,out);
   input  [2:0]x;
   input  [3:0]y;
   output [6:0]out;

   wire [6:0]temp1,temp2,temp3;

   assign temp1=x[0]?y:7'd0;
   assign temp2=x[1]?y<<1:7'd0;
   assign temp3=x[2]?y<<2:7'd0;

   assign out = temp1+temp2+temp3;
endmodule

module mult2(x,y,out);
   input  [2:0]x;
   input  [5:0]y;
   output [8:0]out;

   wire [8:0]temp1,temp2,temp3;

   assign temp1=x[0]?y:9'd0;
   assign temp2=x[1]?y<<1:9'd0;
   assign temp3=x[2]?y<<2:9'd0;

   assign out = temp1+temp2+temp3;
endmodule

module mult3(x,y,out);
   input  [2:0]x;
   input  [6:0]y;
   output [8:0]out;

   wire [8:0]temp1,temp2,temp3;

   assign temp1=x[0]?y:9'd0;
   assign temp2=x[1]?y<<1:9'd0;
   assign temp3=x[2]?y<<2:9'd0;

   assign out = temp1+temp2+temp3;
endmodule


