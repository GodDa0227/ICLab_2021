module LU(//input port
             input clk, 
			 input rst_n, 
			 input in_valid,
             input in_data,
//output port
              output reg out_valid,
			  output reg invertible, 
			  output reg decomposable, 
			  output reg [2:0]out_l,
              output reg [2:0]out_u
			  );
//***********************************			  
// parameter	  
//***********************************	  
parameter IDLE        =  3'd0;
parameter INPUT       =  3'd1;
parameter CHECK_INV	  =  3'd2;
parameter DEC   =  3'd3;
parameter DEC_1 =  3'd4;
parameter OUTPUT      =  3'd5;
parameter OUTPUT_1    =  3'd6;
		


//****************************************
//Reg Daclaration		  
//****************************************
reg [2:0]state;
reg [2:0]next_state;

			  			  
reg signed[2:0]A[0:2][0:2];
reg signed[2:0]L[0:2][0:2];
wire signed[2:0]A_det;



reg [3:0]cnt_out;
assign A_det= (A[0][0]&A[1][1]&A[2][2])
             +(A[0][1]&A[1][2]&A[2][0])
             +(A[0][2]&A[1][0]&A[2][1])
             -(A[0][2]&A[1][1]&A[2][0])
             -(A[1][2]&A[2][1]&A[0][0])
             -(A[2][2]&A[1][0]&A[0][1]);

//************************************
//		  FSM_sample code
//************************************
always@(posedge clk or negedge rst_n)begin
	if(!rst_n) 
		state <= IDLE;
	else
		state <= next_state; 
end

//FSM
always@(*)begin
    case(state)
	    IDLE :next_state=in_valid?INPUT:IDLE;
		INPUT:next_state=in_valid?INPUT:CHECK_INV;
		CHECK_INV:next_state=(A_det==0)?OUTPUT_1:DEC;
		DEC:next_state=DEC_1;
		DEC_1:next_state=OUTPUT;
		OUTPUT:next_state=(cnt_out==4'd9)?IDLE:OUTPUT;
		OUTPUT_1:next_state=IDLE;
		default:next_state=IDLE;
	endcase
end

////INPUT
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	    A[0][0]<=3'd0; A[0][1]<=3'd0; A[0][2]<=3'd0;
        A[1][0]<=3'd0; A[1][1]<=3'd0; A[1][2]<=3'd0;
        A[2][0]<=3'd0; A[2][1]<=3'd0; A[2][2]<=3'd0;		
	  end
	  else if(in_valid)begin
	    A[0][0]<=A[0][1]; A[0][1]<=A[0][2]; A[0][2]<=A[1][0];
        A[1][0]<=A[1][1]; A[1][1]<=A[1][2]; A[1][2]<=A[2][0];
        A[2][0]<=A[2][1]; A[2][1]<=A[2][2]; A[2][2]<=in_data;    
	  end

      else if(next_state==DEC)begin
            case({A[0][0][0],A[1][0][0],A[2][0][0]})
			    3'b001:begin
	                 A[0][0]<=A[2][0]; A[0][1]<=A[2][1]; A[0][2]<=A[2][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[0][0]; A[2][1]<=A[0][1]; A[2][2]<=A[0][2]; 				    
				end
				3'b010:begin
	                 A[0][0]<=A[1][0]; A[0][1]<=A[1][1]; A[0][2]<=A[1][2];
                     A[1][0]<=A[0][0]; A[1][1]<=A[0][1]; A[1][2]<=A[0][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2]; 				  
				end
				3'b011:begin
	                 A[0][0]<=A[1][0]; A[0][1]<=A[1][1]; A[0][2]<=A[1][2];
                     A[1][0]<=A[0][0]; A[1][1]<=A[0][1]; A[1][2]<=A[0][2];
                     A[2][0]<=A[2][0]-A[1][0]; A[2][1]<=A[2][1]-A[1][1]; A[2][2]<=A[2][2]-A[1][2]; 				  
				end
				3'b100:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];			  
				end
                3'b101:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]-A[0][0]; A[2][1]<=A[2][1]-A[0][1]; A[2][2]<=A[2][2]-A[0][2];	                
				end
                3'b110:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]-A[0][0]; A[1][1]<=A[1][1]-A[0][1]; A[1][2]<=A[1][2]-A[0][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];                
				end
                3'b111:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]-A[0][0]; A[1][1]<=A[1][1]-A[0][1]; A[1][2]<=A[1][2]-A[0][2];
                     A[2][0]<=A[2][0]-A[0][0]; A[2][1]<=A[2][1]-A[0][1]; A[2][2]<=A[2][2]-A[0][2];                
				end
                default:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];                     
				end				
			endcase
	  end
	  
      else if(next_state==DEC_1)begin
           case({A[1][1],A[2][1]})
				6'b000_000:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];				     
				end		   
		        6'b000_001:begin
				     A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[2][0]; A[1][1]<=A[2][1]; A[1][2]<=A[2][2];
                     A[2][0]<=A[1][0]; A[2][1]<=A[1][1]; A[2][2]<=A[1][2];  
				end
				6'b001_000:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];				     
				end
				6'b001_001:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]-A[1][0]; A[2][1]<=A[2][1]-A[1][1]; A[2][2]<=A[2][2]-A[1][2];				     
				end	
				6'b000_111:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[2][0]; A[1][1]<=A[2][1]; A[1][2]<=A[2][2];
                     A[2][0]<=A[1][0]; A[2][1]<=A[1][1]; A[2][2]<=A[1][2];				     
				end
				6'b111_000:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];					     
				end	
				6'b111_111:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]-A[1][0]; A[2][1]<=A[2][1]-A[1][1]; A[2][2]<=A[2][2]-A[1][2];					     
				end
				6'b111_001:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]+A[1][0]; A[2][1]<=A[2][1]+A[1][1]; A[2][2]<=A[2][2]+A[1][2];					     
				end
				6'b001_111:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]+A[1][0]; A[2][1]<=A[2][1]+A[1][1]; A[2][2]<=A[2][2]+A[1][2];					     
				end					
				default:begin
	                 A[0][0]<=A[0][0]; A[0][1]<=A[0][1]; A[0][2]<=A[0][2];
                     A[1][0]<=A[1][0]; A[1][1]<=A[1][1]; A[1][2]<=A[1][2];
                     A[2][0]<=A[2][0]; A[2][1]<=A[2][1]; A[2][2]<=A[2][2];				     
				end
		   endcase
	  end	
      	  
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	    L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
        L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
        L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;		      
	 end
	 else if(next_state==DEC)begin
	     case({A[0][0][0],A[1][0][0],A[2][0][0]})
		     3'b000:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;			      
			 end
			 3'b001:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;		 
			 end
			 3'b010:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
			 3'b011:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd1; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
			 3'b100:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
			 3'b101:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd1; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
			 3'b110:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd1; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
			 3'b111:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd1; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd1; L[2][1]<=3'd0; L[2][2]<=3'd1;			 
			 end
             default:begin
	             L[0][0]<=3'd1; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=3'd0; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=3'd0; L[2][1]<=3'd0; L[2][2]<=3'd1;                 
			 end			 
		 endcase
	 end
	 else if(next_state==DEC_1)begin
	       case({A[1][1],A[2][1]})
		      6'b000_000:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd0; L[2][2]<=3'd1;				    
				 end
		      6'b000_001:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[2][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[1][0]; L[2][1]<=3'd0; L[2][2]<=3'd1;				    
				 end
		      6'b001_000:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd0; L[2][2]<=3'd1;				    
				 end
		      6'b001_001:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd1; L[2][2]<=3'd1;				    
				 end
		      6'b001_111:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'b111; L[2][2]<=3'd1;				    
				 end
		      6'b000_111:begin
	             L[0][0]<=L[0][0];  L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[2][0];  L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[1][0] ; L[2][1]<=3'd0; L[2][2]<=3'd1;				    
				 end
		      6'b111_000:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd0; L[2][2]<=3'd1;				    
				 end
		      6'b111_001:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'b111; L[2][2]<=3'd1;				    
				 end
		      6'b111_111:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd1; L[2][2]<=3'd1;				    
				 end				 
			  default:begin
	             L[0][0]<=L[0][0]; L[0][1]<=3'd0; L[0][2]<=3'd0;
                 L[1][0]<=L[1][0]; L[1][1]<=3'd1; L[1][2]<=3'd0;
                 L[2][0]<=L[2][0]; L[2][1]<=3'd0; L[2][2]<=3'd1;					 
				 end
		   endcase
	 end
end
	
///OUTPUT
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)
	    out_valid<=1'd0;
	  else if(next_state==OUTPUT_1||next_state==OUTPUT)
	    out_valid<=1'd1;
	  else 
	    out_valid<=1'd0;
end

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
        invertible<=1'd0;
        decomposable<=1'd0;		
	  end
	  else if(next_state==OUTPUT)begin
        invertible<=1'd1;
        decomposable<=1'd1;	  
	  end
      else begin	  
        invertible<=1'd0;
        decomposable<=1'd0;        
	  end 
end
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	    out_u<=3'd0;
	 end
     else if(next_state==OUTPUT)begin
	    case(cnt_out)
			4'd0: out_u <= 3'd1;
			4'd1: out_u <= A[0][1];
			4'd2: out_u <= A[0][2];
			4'd3: out_u <= 3'd0;
			4'd4: out_u <= A[1][1];
			4'd5: out_u <= A[1][2];
			4'd6: out_u <= 3'd0;
			4'd7: out_u <= 3'd0;
			4'd8: out_u <= A[2][2];
			default: out_u <= 3'd0;
		endcase
	 end
	 else begin
	    out_u<=3'd0;
	 end
end
always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
        out_l<=3'd0;
	 end
     else if(next_state==OUTPUT)begin
	    case(cnt_out)
	        4'd0:out_l<=3'd1;
			4'd1:out_l<=3'd0;
			4'd2:out_l<=3'd0;
			4'd3:out_l<=L[0];
			4'd4:out_l<=3'd1;
			4'd5:out_l<=3'd0;
			4'd6:out_l<=L[1];
			4'd7:out_l<=L[2];
			4'd8:out_l<=3'd1;
			default:out_l<=3'd0;
		endcase
	 end	 
     else begin
        out_l<=3'd0;
	 end
end
//out_cnt

always@(posedge clk or negedge rst_n)begin
     if(!rst_n)begin
	    cnt_out<=4'd0;
	 end
     else if(next_state==OUTPUT) begin
	    cnt_out<=cnt_out+1'd1;
	 end
	 else begin
	    cnt_out<=4'd0;
	 end
end

endmodule