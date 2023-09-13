module MAZE(
    //Input Port
    clk,
    rst_n,
    in_valid,
    in,
    //Output Port
    out_valid,
    out
);

input            clk, rst_n, in_valid, in;
output reg		 out_valid;
output reg [1:0] out;

parameter	IDLE	    =	3'd0;
parameter	INPUT	    =	3'd1;
parameter	WALL	    =	3'd2;
parameter	WALK_RIGHT	=	3'd3;
parameter	WALK_DOWN	=	3'd4;
parameter	WALK_LEFT	=	3'd5;
parameter	WALK_UP	    =	3'd6;

integer i,j;
reg	[2:0] state,next_state;
reg in_data[0:18][0:18];

reg [4:0] cnt_x,cnt_y;
reg [5:0] cnt_wall;
reg [4:0] col,row;


/////////////FSM////////////////////////
always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     state<=IDLE;
	  else
         state<=next_state;	  
end

 always@(*)begin 
      case(state)
 	     IDLE:next_state=in_valid?INPUT:IDLE;
 		 INPUT:next_state=in_valid?INPUT:WALL;
 		 WALL:next_state=(cnt_wall==6'd45)?((in_data[row][col+1'd1])?WALK_RIGHT:WALK_DOWN):WALL;
 		 WALK_RIGHT:begin
 		           if(in_data[row][col+1'd1])
                           next_state=WALK_RIGHT;
                    else if(in_data[row+1'd1][col])						  
 		               next_state=WALK_DOWN;
                    else if(in_data[row-1'd1][col])						  
 		               next_state=WALK_UP;
 				   else
 				       next_state=IDLE; 
          end
 		 WALK_DOWN:begin
 		           if(in_data[row][col+1'd1])
                           next_state=WALK_RIGHT;
                    else if(in_data[row+1'd1][col])						  
 		               next_state=WALK_DOWN;
                    else if(in_data[row][col-1'd1])						  
 		               next_state=WALK_LEFT;
 				   else
 				       next_state=IDLE; 			   
 		 end
 		 WALK_LEFT:begin
                    if(in_data[row+1'd1][col])						  
 		               next_state=WALK_DOWN;
                    else if(in_data[row][col-1'd1])						  
 		               next_state=WALK_LEFT;
                    else if(in_data[row-1'd1][col])						  
 		               next_state=WALK_UP;
                    else 	
                        next_state=IDLE;				   
 		 end
 		 WALK_UP:begin
 		           if(in_data[row][col+1'd1])
                           next_state=WALK_RIGHT;
                    else if(in_data[row][col-1'd1])						  
 		               next_state=WALK_LEFT;
                    else if(in_data[row-1'd1][col])						  
 		               next_state=WALK_UP;
                    else 	
                        next_state=IDLE;				   
 		 end
          default:next_state=IDLE;		 
 	 endcase
 end 

always@(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
	     col<=5'd1;
		 row<=5'd1;
	  end 
	  else begin
         case(next_state)
		    WALK_RIGHT:col<=col+1'd1;
			WALK_DOWN:row<=row+1'd1;
			WALK_LEFT:col<=col-1'd1;
			WALK_UP:row<=row-1'd1;
			default:begin
			       col<=5'd1;
				   row<=5'd1;
			end
       	 endcase		 
	  end
	  /*
	  else if(next_state==WALK_RIGHT)begin
	     col<=col+1'd1;
		 row<=row;		 
	  end else if(next_state==WALK_DOWN)begin
	     col<=col;
		 row<=row+1'd1;
	  end else if(next_state==WALK_LEFT)begin
	     col<=col-1'd1;
		 row<=row;
	  end else if(next_state==WALK_UP)begin
	     col<=col;
		 row<=row-1'd1;
      end else begin
	     col<=5'd1;
		 row<=5'd1;	     
      end 
      */	  
end

/////////////////////INPUT///////////////////////////
always@(posedge clk or negedge rst_n)begin
      if(!rst_n)begin
	     for(i=0;i<19;i=i+1)begin
		    for(j=0;j<19;j=j+1)begin
		        in_data[i][j]<=1'b0;
		    end
         end			
	  end else if(next_state==INPUT)begin
         in_data[cnt_y][cnt_x]<=in;
	     in_data[0][1]<=1'b1;
		 in_data[18][17]<=1'b1;
	  end else if(next_state==WALL)begin
	     for(i=1;i<18;i=i+1)begin
		    for(j=1;j<18;j=j+1)begin
		        //if((in_data[i][j-1]+in_data[i][j+1]+in_data[i-1][j]+in_data[i+1][j])==2'd1)
				if(((in_data[i][j-1]^in_data[i][j+1])&~in_data[i-1][j]&~in_data[i+1][j])|((in_data[i+1][j]^in_data[i-1][j])&~in_data[i][j+1]&~in_data[i][j-1]))
				      in_data[i][j]<= 1'b0;
		
			
		    end
         end 
      end else if((next_state==WALK_RIGHT)|(next_state==WALK_DOWN))
		    in_data[18][17]<=1'b0;
end  

always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     cnt_x<=5'd1;
      else if(next_state==INPUT && cnt_x==5'd17)
	     cnt_x<=5'd1;		 
      else if(next_state==INPUT)
	     cnt_x<=cnt_x+1'd1;
	  else
      	 cnt_x<=5'd1; 
end
always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     cnt_y<=5'd1;
	  else if(next_state==INPUT && cnt_x==5'd17)
	     cnt_y<=cnt_y+1'd1;
	  else if(next_state==INPUT)
	     cnt_y<=cnt_y;		 
	  else
	     cnt_y<=5'd1; 
end
///////////////////////DESIGN///////////////////
always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     cnt_wall<=6'd0;
	  else if(next_state==WALL)
	     cnt_wall<=cnt_wall+1'd1;		 
      else
	     cnt_wall<=6'd0;
end

/////////////////////OUTPUT//////////////////////
always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     out_valid<=1'd0;
	  else begin	 
         case(next_state)
		    WALK_RIGHT:out_valid<=1'd1;
			WALK_DOWN: out_valid<=1'd1;
			WALK_LEFT: out_valid<=1'd1;
			WALK_UP:   out_valid<=1'd1;
			default:   out_valid<=1'd0;
	     endcase 
 	 end		
end

always@(posedge clk or negedge rst_n)begin
      if(!rst_n)
	     out<=2'd0;
      else begin
         case(next_state)
		    WALK_RIGHT:out<=2'd0;
			WALK_DOWN: out<=2'd1;
			WALK_LEFT: out<=2'd2;
			WALK_UP:   out<=2'd3;
			default:   out<=2'd0;
		 endcase
	  end 	  
end
    
endmodule 