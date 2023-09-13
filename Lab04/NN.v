module NN(clk,rst_n,
          in_valid_d,
		  in_valid_t,
		  in_valid_w1,
		  in_valid_w2,
		  data_point,
		  target,
		  weight1,
		  weight2,
		  out_valid,out
         );
////--------------------PARAMETER--------------------------/////
// IEEE 754
parameter inst_sig_width = 23;
parameter inst_exp_width = 8;
parameter inst_ieee_compliance = 0;
parameter inst_arch = 2;
// LEARNING RATE
parameter lr   = 32'h3A83126F; //lr = 0.001
parameter one  = 32'h3F800000;
parameter zero = 32'h00000000;
// FSM PARAMETER
parameter IDLE       =3'd0,
          IN         =3'd1,
		  IN1        =3'd2, 
		  CAL        =3'd3,
		  OUT        =3'd4;
//--------------------------------------------------------------------//
input clk,rst_n,in_valid_d,in_valid_t,in_valid_w1,in_valid_w2;
input [31:0] data_point,target,weight1,weight2;
output reg out_valid;
output reg [31:0] out;

reg [2:0] state,next_state;
reg [31:0]weight1_data[0:11],weight2_data[0:2];
reg [31:0]data_point_data[0:3];
reg [31:0]target_data;
reg [4:0]cnt;
reg [31:0]mult1,mult2,mult3,mult4,mult5,mult6;
reg [31:0]add1,add2,add3,add4,add5,add6;
reg [31:0]sub1,sub2,sub3,sub4,sub5,sub6;
reg [31:0]sum1,sum2,sum3;
wire[31:0]out_mult1,out_mult2,out_mult3;
wire[31:0]out_add1,out_add2,out_add3;
wire[31:0]out_sub1,out_sub2,out_sub3;
wire[31:0]out_sum1;
reg [31:0]y0[0:2],y1[0:2];
//reg [31:0]delta0;
reg [31:0]delta1[0:2];

//////////////////////FSM//////////////////////////
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)
	   state<=IDLE;
	 else
       state<=next_state;	 
end

always@(*)begin
    case(state)
	    IDLE:begin
		        if(in_valid_w1)
				   next_state=IN;
				else if(in_valid_d)
                   next_state=IN1;
                else
                   next_state=IDLE;				
		end
		IN:next_state=in_valid_w1?IN:IDLE;
		IN1:next_state=in_valid_d?IN1:CAL;
		CAL:next_state=(cnt==5'd22)?OUT:CAL;
		OUT:next_state=IDLE;
		default:next_state=IDLE;
	endcase
end
//////////////////////FORWARD_1//////////////////////////
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M0 ( .a(mult1), .b(mult2), .rnd(3'b000), .z(out_mult1));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M1 ( .a(mult3), .b(mult4), .rnd(3'b000), .z(out_mult2));
DW_fp_mult #(inst_sig_width, inst_exp_width, inst_ieee_compliance) M2 ( .a(mult5), .b(mult6), .rnd(3'b000), .z(out_mult3));


DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A0 ( .a(add1), .b(add2), .rnd(3'b000), .z(out_add1));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A1 ( .a(add3), .b(add4), .rnd(3'b000), .z(out_add2));
DW_fp_add #(inst_sig_width, inst_exp_width, inst_ieee_compliance) A2 ( .a(add5), .b(add6), .rnd(3'b000), .z(out_add3));
DW_fp_sum3 #(inst_sig_width, inst_exp_width, inst_ieee_compliance) U0 ( .a(sum1), .b(sum2), .c(sum3), .rnd(3'b000), .z(out_sum1));


DW_fp_addsub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S0 ( .a(sub1), .b(sub2), .op(1'b1), .rnd(3'b000), .z(out_sub1));
DW_fp_addsub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S1 ( .a(sub3), .b(sub4), .op(1'b1), .rnd(3'b000), .z(out_sub2));
DW_fp_addsub #(inst_sig_width, inst_exp_width, inst_ieee_compliance) S2 ( .a(sub5), .b(sub6), .op(1'b1), .rnd(3'b000), .z(out_sub3));


///////////////FORWARD//////////////////////////
always@(posedge clk or negedge rst_n)begin 
     if(!rst_n)begin
	   mult1<=0;
	   mult2<=0;
	 end  
	 else begin
	     case(cnt)
		    5'd0:begin
                mult1<=data_point_data[0];
	            mult2<=weight1_data[0];			     
			end
		    5'd1:begin
                mult1<=data_point_data[1];
	            mult2<=weight1_data[1];			     
			end
		    5'd2:begin
                mult1<=data_point_data[2];
	            mult2<=weight1_data[2];			     
			end
		    5'd3:begin
                mult1<=data_point_data[3];
	            mult2<=weight1_data[3];			     
			end
            5'd6:begin
                mult1<=y0[0];
	            mult2<=weight2_data[0];                
			end
            5'd9:begin
                mult1<=out_sub1;
	            mult2<=weight2_data[0];                
			end
            5'd10:begin
                mult1<=out_mult1;
	            mult2<=y1[0];               
			end	
            5'd11:begin
                mult1<=out_sub1;
	            mult2<=y0[0];               
			end	
            5'd12:begin
                mult1<=out_mult1;
	            mult2<=lr ;            
			end	
            5'd13:begin
                mult1<=data_point_data[0];
	            mult2<=delta1[0] ;           
			end	
            5'd14:begin
                mult1<=out_mult1;
	            mult2<=lr ;           
			end	
            5'd15:begin
                mult1<=data_point_data[1];
	            mult2<=delta1[0] ;          
			end	
            5'd16:begin
                mult1<=out_mult1;
	            mult2<=lr ;          
			end
			5'd17:begin
                mult1<=data_point_data[2];
	            mult2<=delta1[0] ;         
			end
			5'd18:begin
                mult1<=out_mult1;
                mult2<=lr ;        
			end			
			5'd19:begin
                mult1<=data_point_data[3];
	            mult2<=delta1[0] ;      
			end	
			5'd20:begin
               mult1<=out_mult1;
	           mult2<=lr ;       
			end	
            default:begin
               mult1<=0;
	           mult2<=0;                
			end			
		 endcase
	 end
 
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   mult3<=0;
	   mult4<=0;
	 end 
     else begin
          case(cnt)	 
	        5'd0:begin
              mult3<=data_point_data[0];
	          mult4<=weight1_data[4];
	        end  
            5'd1:begin
              mult3<=data_point_data[1];
	          mult4<=weight1_data[5];
            end
            5'd2:begin
              mult3<=data_point_data[2];
	          mult4<=weight1_data[6];
            end
            5'd3:begin
              mult3<=data_point_data[3];
	          mult4<=weight1_data[7];
            end
	        5'd6:begin
              mult3<=y0[1];
	          mult4<=weight2_data[1];
	        end 
	        5'd9:begin
              mult3<=out_sub1;
	          mult4<=weight2_data[1];
	        end  
	        5'd10:begin
              mult3<=out_mult2;
	          mult4<=y1[1];
	        end 
	        5'd11:begin
              mult3<=out_sub1;
	          mult4<=y0[1];
	        end 
	        5'd12:begin
              mult3<=out_mult2;
	          mult4<=lr ;
	        end
	        5'd13:begin
              mult3<=data_point_data[0];
	          mult4<=delta1[1] ;
	        end 
	        5'd14:begin
              mult3<=out_mult2;
	          mult4<=lr ;
	        end 
	        5'd15:begin
              mult3<=data_point_data[1];
	          mult4<=delta1[1] ;
	        end 
	        5'd16:begin
              mult3<=out_mult2;
	          mult4<=lr ;
	        end 	
	        5'd17:begin
              mult3<=data_point_data[2];
	          mult4<=delta1[1] ;
	        end 
	        5'd18:begin
              mult3<=out_mult2;
	          mult4<=lr ;
	        end 	 
	        5'd19:begin
              mult3<=data_point_data[3];
	          mult4<=delta1[1] ;
	        end 
	        5'd20:begin
              mult3<=out_mult2;
	          mult4<=lr ;
	        end
            default:begin
              mult3<=0;
	          mult4<=0;        
			end			
	   endcase
	 end  
end
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   mult5<=0;
	   mult6<=0;
	 end 
     else begin
       case(cnt)	 
	      5'd0:begin
            mult5<=data_point_data[0];
	        mult6<=weight1_data[8];
	      end  
          5'd1:begin
            mult5<=data_point_data[1];
	        mult6<=weight1_data[9];
          end
          5'd2:begin
            mult5<=data_point_data[2];
	        mult6<=weight1_data[10];
          end
          5'd3:begin
            mult5<=data_point_data[3];
	        mult6<=weight1_data[11];
          end
	      5'd6:begin
            mult5<=y0[2];
	        mult6<=weight2_data[2];
	      end 
	      5'd9:begin
            mult5<=out_sub1;
	        mult6<=weight2_data[2];
	      end  
	      5'd10:begin
            mult5<=out_mult3;
	        mult6<=y1[2];
	      end 
	      5'd11:begin
            mult5<=out_sub1;
	        mult6<=y0[2];
	      end 
	      5'd12:begin
            mult5<=out_mult3;
	        mult6<=lr ;
	      end 
	      5'd13:begin
            mult5<=data_point_data[0];
	        mult6<=delta1[2] ;
	      end 
	      5'd14:begin
            mult5<=out_mult3;
	        mult6<=lr ;
	      end  	 
	      5'd15:begin
            mult5<=data_point_data[1];
	        mult6<=delta1[2] ;
	      end 
	      5'd16:begin
            mult5<=out_mult3;
	        mult6<=lr ;
	      end  	
	      5'd17:begin
            mult5<=data_point_data[2];
	        mult6<=delta1[2] ;
	      end 
	      5'd18:begin
            mult5<=out_mult3;
	        mult6<=lr ;
	      end 
	      5'd19:begin
            mult5<=data_point_data[3];
	        mult6<=delta1[2] ;
	      end 
	      5'd20:begin
            mult5<=out_mult3;
	        mult6<=lr ;
	      end 
		  default:begin
            mult5<=0;
	        mult6<=0;  
		  end
        endcase
     end		
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   add1<=0;
	   add2<=0;
	 end  
	 else if(cnt>5'd0)begin
	   add1<=out_add1;
	   add2<=out_mult1;
	 end
 	 
	 else if(state==IDLE)begin
	   add1<=0;
	   add2<=0;
	 end  	 
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   add3<=0;
	   add4<=0;
	 end  
	 else if(cnt>5'd0)begin
	   add3<=out_add2;
	   add4<=out_mult2;
	 end  
	 else if(state==IDLE)begin
	   add3<=0;
	   add4<=0;
	 end  	 
end
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   add5<=0;
	   add6<=0;
	 end  
	 else if(cnt>5'd0)begin
	   add5<=out_add3;
	   add6<=out_mult3;
	 end  
	 else if(state==IDLE)begin
	   add5<=0;
	   add6<=0;
	 end  	 
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   sub1<=0;
	   sub2<=0;
	 end 
     else begin 
       case(cnt)	 
	   5'd8:begin
	     sub1<=out_sum1;
	     sub2<=target_data;
	   end  
	   5'd13:begin
	     sub1<=weight2_data[0];
	     sub2<=out_mult1;
	   end   	 
	   5'd15:begin
	     sub1<=weight1_data[0];
	     sub2<=out_mult1;
	   end 
	   5'd17:begin
	     sub1<=weight1_data[1];
	     sub2<=out_mult1;
	   end 	 
	   5'd19:begin
	     sub1<=weight1_data[2];
	     sub2<=out_mult1;
	   end	 
	   5'd21:begin
	     sub1<=weight1_data[3];
	     sub2<=out_mult1;
	   end

	   endcase
	 end   
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   sub3<=0;
	   sub4<=0;
	 end  
	 else begin
	   case(cnt)
	    5'd13:begin
	     sub3<=weight2_data[1];
	     sub4<=out_mult2;
	    end  
	    5'd15:begin
	     sub3<=weight1_data[4];
	     sub4<=out_mult2;
	    end 	 
	    5'd17:begin
	     sub3<=weight1_data[5];
	     sub4<=out_mult2;
	    end
	    5'd19:begin
	     sub3<=weight1_data[6];
	     sub4<=out_mult2;
	    end 
	    5'd21:begin
	     sub3<=weight1_data[7];
	     sub4<=out_mult2;
	    end 
		
       endcase
     end		
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   sub5<=0;
	   sub6<=0;
	 end 
     else begin 
       case(cnt)	 
	     5'd13:begin
	      sub5<=weight2_data[2];
	      sub6<=out_mult3;
	     end  
	     5'd15:begin
	      sub5<=weight1_data[8];
	      sub6<=out_mult3;
	     end 	 
	     5'd17:begin
	      sub5<=weight1_data[9];
	      sub6<=out_mult3;
	     end 
	     5'd19:begin
	      sub5<=weight1_data[10];
	      sub6<=out_mult3;
	     end 	 
	     5'd21:begin
	      sub5<=weight1_data[11];
	      sub6<=out_mult3;
	     end
        		 
    endcase
    end	
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   sum1<=0;
	   sum2<=0;
	   sum3<=0;
	 end  
	 else if(cnt==5'd7)begin
	   sum1<=out_mult1;
	   sum2<=out_mult2;
	   sum3<=out_mult3;
	 end  
	 else if(state==IDLE)begin
	   sum1<=0;
	   sum2<=0;
	   sum3<=0;
	 end  	 
end
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   y0[0]<=0;
	   y0[1]<=0;
	   y0[2]<=0;
	 end  
	 else if(cnt==5'd5)begin
	   y0[0]<=(out_add1[31]==1'b0)?out_add1:zero;
	   y0[1]<=(out_add2[31]==1'b0)?out_add2:zero;
	   y0[2]<=(out_add3[31]==1'b0)?out_add3:zero;
	 end  
	 
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   y1[0]<=1'd0;
	   y1[1]<=1'd0;
	   y1[2]<=1'd0;
	 end  
	 else if(cnt==5'd5)begin
	   y1[0]<=(out_add1[31]==1'b0)?one:zero;
	   y1[1]<=(out_add2[31]==1'b0)?one:zero;
	   y1[2]<=(out_add3[31]==1'b0)?one:zero;
	 end  
	 
end
/*
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)
	   delta0<=0;
	 else if(cnt==5'd9)
	   delta0<=out_sub1;
end
*/
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	   delta1[0]<=0;
	   delta1[1]<=0;
	   delta1[2]<=0;
	 end   
	 else if(cnt==5'd11)begin
	   delta1[0]<=out_mult1;
	   delta1[1]<=out_mult2;
	   delta1[2]<=out_mult3;
	 end  
end




//////////////INPUT////////////
always@(posedge clk or negedge rst_n)begin
       if(!rst_n)begin
	     weight1_data[0 ]<=0;
		 weight1_data[1 ]<=0;
		 weight1_data[2 ]<=0;
		 weight1_data[3 ]<=0;
		 weight1_data[4 ]<=0;
		 weight1_data[5 ]<=0;
		 weight1_data[6 ]<=0;
		 weight1_data[7 ]<=0;
		 weight1_data[8 ]<=0;
		 weight1_data[9 ]<=0;
		 weight1_data[10]<=0;
		 weight1_data[11]<=0;
	   end	 
	   else if(in_valid_w1)begin
	     weight1_data[0 ]<=weight1_data[1 ];
		 weight1_data[1 ]<=weight1_data[2 ];
		 weight1_data[2 ]<=weight1_data[3 ];
		 weight1_data[3 ]<=weight1_data[4 ];
		 weight1_data[4 ]<=weight1_data[5 ];
		 weight1_data[5 ]<=weight1_data[6 ];
		 weight1_data[6 ]<=weight1_data[7 ];
		 weight1_data[7 ]<=weight1_data[8 ];
		 weight1_data[8 ]<=weight1_data[9 ];
		 weight1_data[9 ]<=weight1_data[10];
		 weight1_data[10]<=weight1_data[11];
		 weight1_data[11]<=weight1;  
	   end	
       else if(cnt==5'd16)begin
         weight1_data[0]<=out_sub1;
         weight1_data[4]<=out_sub2;
         weight1_data[8]<=out_sub3;		 
       end
       else if(cnt==5'd18)begin
         weight1_data[1]<=out_sub1;
         weight1_data[5]<=out_sub2;
         weight1_data[9]<=out_sub3;		 
       end
       else if(cnt==5'd20)begin
         weight1_data[2]<=out_sub1;
         weight1_data[6]<=out_sub2;
         weight1_data[10]<=out_sub3;		 
       end	
       else if(cnt==5'd22)begin
         weight1_data[3]<=out_sub1;
         weight1_data[7]<=out_sub2;
         weight1_data[11]<=out_sub3;		 
       end		   
end 


always@(posedge clk or negedge rst_n)begin
       if(!rst_n)begin
	     weight2_data[0]<=0;
		 weight2_data[1]<=0;
		 weight2_data[2]<=0;

	   end	 
	   else if(in_valid_w2)begin
	     weight2_data[0]<=weight2_data[1];
		 weight2_data[1]<=weight2_data[2];
		 weight2_data[2]<=weight2;
	   end	 
	   else if(cnt==5'd14)begin
	     weight2_data[0]<=out_sub1;
		 weight2_data[1]<=out_sub2;
		 weight2_data[2]<=out_sub3;
	   end
end 

always@(posedge clk or negedge rst_n)begin
       if(!rst_n)begin
	     data_point_data[0]<=0;
         data_point_data[1]<=0;
		 data_point_data[2]<=0;
		 data_point_data[3]<=0;
	   end	 
	   else if(in_valid_d)begin
	     data_point_data[0]<=data_point_data[1];
         data_point_data[1]<=data_point_data[2];
		 data_point_data[2]<=data_point_data[3];
		 data_point_data[3]<=data_point;

	   end	 

end 

always@(posedge clk or negedge rst_n)begin
       if(!rst_n)begin
         target_data<=0;
	   end	 
	   else if(in_valid_t)begin
	     target_data<=target;

	   end	 

end 
//////////////OUTPUT////////////
always@(posedge clk or negedge rst_n)begin
       if(!rst_n)
         out_valid<=1'd0;
 	   else if(state==OUT)
	     out_valid<=1'd1;
       else
	     out_valid<=1'd0;
end 

always@(posedge clk or negedge rst_n)begin
       if(!rst_n)
         out<=0;
       else if(state==OUT)
	     out<=out_sum1;
	   else
         out<=0;	   
end 
////////////CNT/////////////////
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)
	   cnt<=5'd0;
	 else if(state==CAL)
       cnt<=cnt+1'd1;
	 else
       cnt<=5'd0;	 
end



endmodule