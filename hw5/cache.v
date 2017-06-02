module cache(
    clk,
    proc_reset,
    proc_read,
    proc_write,
    proc_addr,
    proc_wdata,
    proc_stall,
    proc_rdata,
    mem_read,
    mem_write,
    mem_addr,
    mem_rdata,
    mem_wdata,
    mem_ready
);
    
//==== input/output definition ============================
    input          clk;
    // processor interface
    input          proc_reset;
    input          proc_read, proc_write;
    input   [29:0] proc_addr;
    input   [31:0] proc_wdata;
    output         proc_stall;
    output  [31:0] proc_rdata;
    // memory interface
    input  [127:0] mem_rdata;
    input          mem_ready;
    output         mem_read, mem_write;
    output  [27:0] mem_addr;
    output [127:0] mem_wdata;
    
//==== wire/reg definition ================================
    //state
    reg [1:0]     state; 
    /*  state = 2'b00: Read/ Write
        state = 2'b01: Write-back
        state = 2'b10: Renew-Data
        state = 2'b11: Wait*/
    // block register
    reg  [31:0]    block [7:0][3:0];
    reg  [24:0]    tag   [7:0];
    reg            valid [7:0];
    reg            dirty [7:0];

    //address register
    wire [1:0]     word_index;
    wire [2:0]     block_index;

    //prev___ output
    reg   	   prev_proc_stall, prev_mem_read, prev_mem_write;
    reg   [31:0]   prev_proc_rdata; 
    reg   [127:0]  prev_mem_wdata;
    reg   [27:0]   prev_mem_addr; 
    reg   [31:0]   next_proc_wdata;
    reg   [29:0]   next_proc_addr;
  //  reg   	   next_mem_ready;
    reg		   next_proc_read, next_proc_write;
    reg            rw_status;
    reg 	   from_state_2;
    /* read = 1'b0, write = 1'b1*/
reg [25:0]tagsee;
//==== combinational circuit ==============================
    //address assignment
    assign word_index = proc_addr[1:0];
    assign block_index = proc_addr[4:2];
    //non blocking output net 
    //control signal part
    assign proc_stall = prev_proc_stall;
    assign mem_read = prev_mem_read;
    assign mem_write = prev_mem_write;
    //data output part
    assign proc_rdata = prev_proc_rdata;
    assign mem_addr = prev_mem_addr;
    assign mem_wdata = prev_mem_wdata;
    
  //check the asynchronus mem_ready sign
    always@(*) begin
	//word_index = proc_addr[1:0];
  	//block_index = proc_addr[4:2];
	next_proc_read <= proc_read;
	next_proc_write <= proc_write;
        /*if(mem_ready == 1'b1) begin
	    next_mem_ready <= 1'b1;		
        end*/
        next_proc_addr <= proc_addr[29:0];
    end
//==== sequential circuit =================================
always@( posedge clk or posedge proc_reset ) begin
    if( proc_reset ) begin
    // reset all value in cache blocks to zero
        block[0][0] <= 32'b0;
        block[0][1] <= 32'b0;
        block[0][2] <= 32'b0;
        block[0][3] <= 32'b0;
        block[1][0] <= 32'b0;
        block[1][1] <= 32'b0;
        block[1][2] <= 32'b0;
        block[1][3] <= 32'b0;
        block[2][0] <= 32'b0;
        block[2][1] <= 32'b0;
        block[2][2] <= 32'b0;
        block[2][3] <= 32'b0;
        block[3][0] <= 32'b0;
        block[3][1] <= 32'b0;
        block[3][2] <= 32'b0;
        block[3][3] <= 32'b0;
        block[4][0] <= 32'b0;
        block[4][1] <= 32'b0;
        block[4][2] <= 32'b0;
        block[4][3] <= 32'b0;
        block[5][0] <= 32'b0;
        block[5][1] <= 32'b0;
        block[5][2] <= 32'b0;
        block[5][3] <= 32'b0;
        block[6][0] <= 32'b0;
        block[6][1] <= 32'b0;
        block[6][2] <= 32'b0;
        block[6][3] <= 32'b0;
        block[7][0] <= 32'b0;
        block[7][1] <= 32'b0;
        block[7][2] <= 32'b0;
        block[7][3] <= 32'b0;
        //set all the tag to 0 
        tag[0] <= 25'b0;
        tag[1] <= 25'b0;
        tag[2] <= 25'b0;
        tag[3] <= 25'b0;
        tag[4] <= 25'b0;
        tag[5] <= 25'b0;
        tag[6] <= 25'b0;
        tag[7] <= 25'b0;
        // set all the valid bit to 0 as nothing is stored in cache
        valid[0] <= 1'b0;
        valid[1] <= 1'b0;
        valid[2] <= 1'b0;
        valid[3] <= 1'b0;
        valid[4] <= 1'b0;
        valid[5] <= 1'b0;
        valid[6] <= 1'b0;
        valid[7] <= 1'b0;
        // set all the dirty bit to 0 as not be changed a.k.a not 'dirty'
        dirty[0] <= 1'b0;
        dirty[1] <= 1'b0;
        dirty[2] <= 1'b0;
        dirty[3] <= 1'b0;
        dirty[4] <= 1'b0;
        dirty[5] <= 1'b0;
        dirty[6] <= 1'b0;
        dirty[7] <= 1'b0;
	//state reset to 0
	state <= 2'b00;
	//set all the register to 0
	prev_proc_stall <= 1'b0;
	prev_mem_read <= 1'b0;
	prev_mem_write <= 1'b0;
	prev_proc_rdata <= 32'b0;
	prev_mem_wdata <= 128'b0;
	prev_mem_addr <= 28'b0;
	next_proc_wdata <= 32'b0;
//	next_mem_ready <= 1'b0;
	rw_status <= 1'b0;
	next_proc_read <= 1'b0;
	next_proc_write <= 1'b0;
	from_state_2 <= 1'b0;
    end
    else begin
        //state 0: READ /WRITE
        if (state == 2'b00) begin
            /*CASE DEFAULT
            if((proc_read == 1'b0 && proc_write == 1'b0) || (proc_read == 1'b1 && proc_write == 1'b1)) begin
                prev_mem_read <= 1'b0;
                prev_mem_write <= 1'b0;
                prev_proc_stall <= 1'b0;
	    end*/
	    if(from_state_2 == 1'b1) begin
		//state : goto state3_ wait
		state <= 2'b11;
		 //if read is undone yet
                if(rw_status == 1'b0) begin
                    prev_proc_rdata <= block[block_index][word_index];     
                end
                //if write is undone yet
                else begin
                    block[block_index][word_index] <= next_proc_wdata;
                    dirty[block_index] <= 1'b1;
                end
		//cache control
		prev_mem_read <= 1'b0;
		prev_mem_write <= 1'b0;
		prev_proc_stall <= 1'b0;
		from_state_2 <= 1'b0;
	    end
	    else begin
            //CASE1: READ
            if(proc_read == 1'b1) begin
                //READ_CASE1: READ_HIT => remain state 0: Read/hit
                if(tag[block_index] == proc_addr[29:5] && valid[block_index] == 1'b1) begin
                    //state: goto  state 3: Wait
                    state <= 2'b11;
                    //cache data
                    prev_proc_rdata <= block[block_index][word_index];
                    //cache control
                    prev_mem_read <= 1'b0;
                    prev_mem_write <= 1'b0;
                    prev_proc_stall <= 1'b0;

                end
                //READ_CASE2: READ_MISS => goto state 1: Write-back || goto state 2: Renew Data
                else begin
                    //store what status you are doing 
                    rw_status <= 1'b0;
                    //goto state 1: Write-back 
                    if(dirty[block_index] == 1'b1) begin
                        //state : goto state 1: Write back
                        state <= 2'b01;
                        //cache control
                        prev_mem_write <= 1'b1;
                        prev_mem_read <= 1'b0;
                        prev_proc_stall <= 1'b1;
                        //cache data
                        prev_mem_wdata[127:96] <= block[block_index][3];
                        prev_mem_wdata[95:64]  <= block[block_index][2];
                        prev_mem_wdata[63:32]  <= block[block_index][1];
                        prev_mem_wdata[31:0]   <= block[block_index][0];
                        prev_mem_addr[27:3] <= tag[block_index];
                        prev_mem_addr[2:0]  <= block_index;
                        
                        //refreshed dirty
                        dirty[block_index] <= 1'b0;
                    end
                    //goto state 2: Renew data
                    else begin
                        //state : goto state 2: Renew data
                        state <= 2'b10;
                        //cache control
                        prev_mem_write <= 1'b0;
                        prev_mem_read <= 1'b1;
                        prev_proc_stall <= 1'b1;
                        //cache data
                        prev_mem_addr <= proc_addr[29:2];
                        
                    end
                end
            end
            //CASE2: WRITE
            if(proc_write == 1'b1) begin
		next_proc_wdata <= proc_wdata;
                 rw_status <= 1'b1;
		//WRITE_CASE1: WRITE_HIT => remain state 0: Read/Hit
                if(tag[block_index] == proc_addr[29:5] && valid[block_index] == 1'b1) begin
                    //state 0: remain in Read / Write state
                    state <= 2'b11;
                    // cache control
                    prev_mem_read <= 1'b0;
                    prev_mem_write <= 1'b0;
                    prev_proc_stall <= 1'b0;
                    // cache data
                    block[block_index][word_index] <= proc_wdata;
                    dirty[block_index] <= 1'b1;
                end
                //WRITE_CASE2: WRITE_MISS => goto state 1: Write-back
                else begin
                    //store what status you are doing
                   
                     
                    //goto state 1: Write-back
                    if(dirty[block_index] == 1'b1) begin
                        //state : goto state 1: Write back
                        state <= 2'b01;
                        //cache control
                        prev_mem_write <= 1'b1;
                        prev_mem_read <= 1'b0;
                        prev_proc_stall <= 1'b1;
                        //cache data
                        prev_mem_wdata[127:96] <= block[block_index][3];
                        prev_mem_wdata[95:64]  <= block[block_index][2];
                        prev_mem_wdata[63:32]  <= block[block_index][1];
                        prev_mem_wdata[31:0]   <= block[block_index][0];
                        
                        prev_mem_addr[27:3] <= tag[block_index];
                        prev_mem_addr[2:0]  <= block_index;
                        
                        //refreshed dirty
                        dirty[block_index] <= 1'b0;

                    end
                    //goto state 2: Renew data
                    else begin
                        //state : goto state 2: Renew data
                        state <= 2'b10;
                        //cache control
                        prev_mem_write <= 1'b0;
                        prev_mem_read <= 1'b1;
                        prev_proc_stall <= 1'b1;
                        //cache data
                        prev_mem_addr <= proc_addr[29:2];
                        
                    end
                end
            end
	    end
        end
        //state 1: Write-back
        if (state == 2'b01) begin
            // if write-back finished , goto state 2 : Renew Data
            if(mem_ready == 1'b1) begin
                //state : goto state 2: renew data
                state <= 2'b10;
                //cache control 
                prev_proc_stall <= 1'b1;
                prev_mem_read <= 1'b1;
                prev_mem_write <= 1'b0;
                //cache data
                prev_mem_addr <= proc_addr[29:2];
                //reset mem_ready to 0
		//        next_mem_ready <= 1'b0;
            end
	    else begin 
		//state remain in state 1
		state <= 2'b01;
	    end
        end
        //state 2: Renew Data
        if (state == 2'b10) begin
            //if renew data is finished write the data into cache and goto state0:read/write to wait for next inst.
            if(mem_ready == 1'b1) begin
                //state : goto state 0: read/write 
                state <= 2'b00;
                //cache control
                prev_proc_stall <= 1'b1;
                prev_mem_read <= 1'b0;
                prev_mem_write <= 1'b0;
                //cache data
                block[block_index][3] <= mem_rdata[127:96];
                block[block_index][2] <= mem_rdata[95:64];
                block[block_index][1] <= mem_rdata[63:32];
                block[block_index][0] <= mem_rdata[31:0];
                //let the block be valid 
                valid[block_index] <= 1'b1;
		tag[block_index] <= next_proc_addr[29:5];
		tagsee <= next_proc_addr[29:5];
/*
                //if read is undone yet
                if(rw_status == 1'b0) begin
                    prev_proc_rdata <= block[block_index][word_index];     
                end
                //if write is undone yet
                else begin
                    block[block_index][word_index] <= next_proc_wdata;
                    dirty[block_index] <= 1'b1;
                end
*/
			from_state_2 <= 1'b1;
		        //reset nen_ready to 0
		        //next_mem_ready <= 1'b0;
                end
	        else begin 
		        //state remain in state2
		        state <= 2'b10;
	        end
        end
        //state 3 : return data 
        if (state == 2'b11) begin
            //goto state 0: read/write
            state <= 2'b00;
            prev_proc_stall <= 1'b1;
        end
    end
end

endmodule
