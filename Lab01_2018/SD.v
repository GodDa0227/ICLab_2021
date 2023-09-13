module SD(
	in_n0,
	in_n1, 
	in_n2, 
	in_n3, 
	mode,
	out_n
);
input [3:0] in_n0;   
input [3:0] in_n1;   
input [3:0] in_n2;   
input [3:0] in_n3;   
input mode;
   
output [3:0] out_n;

//================================================================
//    Wire & Registers 
//================================================================
wire[3:0]temp1,temp2,temp3,temp4;
wire[3:0]temp5,temp6,temp7,temp8;
wire[3:0]temp9,temp10;
wire[6:0]divider1,divider2;
reg [3:0]out_n,Q;
reg [3:0]sub3,sub2,sub1;

assign temp1  = (in_n0>in_n1)?in_n0:in_n1;
assign temp2  = (in_n0>in_n1)?in_n1:in_n0;
assign temp3  = (in_n2>in_n3)?in_n2:in_n3;
assign temp4  = (in_n2>in_n3)?in_n3:in_n2;
			  
assign temp5  = (temp1>temp3)?temp1:temp3;
assign temp6  = (temp2>temp4)?temp2:temp4;
assign temp7  = (temp1>temp3)?temp3:temp1;
assign temp8  = (temp2>temp4)?temp4:temp2;
			  
assign temp9  = (temp6>temp7)?temp6:temp7;
assign temp10 = (temp6>temp7)?temp7:temp6;

assign divider1 = {3'b000,temp5};
assign divider2 = {3'b000,temp8};

always@(*)begin
     if(divider1>=(divider2<<3))begin
	        Q[3]=1'd1;
			sub3=divider1-(divider2<<3);
	 end
     else begin
            Q[3]=1'd0;
			sub3=divider1;
	 end	 
end

always@(*)begin
     if(sub3>=(divider2<<2))begin
	        Q[2]=1'd1;
			sub2=sub3-(divider2<<2);
	 end
     else begin
            Q[2]=1'd0;
			sub2=sub3;
	 end	 
end

always@(*)begin
     if(sub2>=(divider2<<1))begin
	        Q[1]=1'd1;
			sub1=sub2-(divider2<<1);
	 end
     else begin
            Q[1]=1'd0;
			sub1=sub2;
	 end	 
end
always@(*)begin
     if(sub1>=divider2)begin
	        Q[0]=1'd1;
	 end
     else begin
            Q[0]=1'd0;
	 end	 
end
always@(*)begin
     case(mode)
	   1'd0:out_n=Q;
	   1'd1:out_n=temp5-temp9+temp10-temp8;
	 endcase  
end

endmodule