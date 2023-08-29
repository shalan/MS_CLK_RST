`timescale 1ns/1ps
module MS_CLK_RST_tb;

    reg         xclk0 = 0;
    reg         xclk1 = 0;
    reg         xrst_n = 1;
    reg         sel_mux0;
    reg         sel_mux1;
    reg         sel_mux2;
    reg [1:0]   sel_rosc;
    reg [1:0]   clk_div;
    wire        clk;
    wire        rst_n;
    wire        por_n;

    reg         xclk0_stop = 0;
    reg         xclk1_stop = 1;

    initial begin
        `ifdef VCS
            $vcdplusfile("MS_CLK_RST_tb.vpd");
		    $vcdpluson();
	    `else 
            $dumpfile("MS_CLK_RST_tb.vcd");
            $dumpvars;
        `endif
    end
    
    `ifdef ENABLE_SDF
		initial begin
            $sdf_annotate({`SDF_PATH,"/",`CORNER_1,"/MS_CLK_RST.",`CORNER_2 ,".sdf"}, MUV ,,{`RUN_PATH,"/sdf.log"},"MINIMUM"); 
		end
	`endif // ENABLE_SDF

    wire vssd1 = 0;
    wire vccd1 = 1;
    MS_CLK_RST MUV (
        `ifdef USE_POWER_PINS
            .vssd1(vssd1),
            .vccd1(vccd1),
        `endif
        .xclk0(xclk0),
        .xclk1(xclk1),
        .xrst_n(xrst_n),
        .sel_mux0(sel_mux0),
        .sel_mux1(sel_mux1),
        .sel_mux2(sel_mux2),
        .sel_rosc(sel_rosc),
        .clk_div(clk_div),
        .clk(clk),
        .rst_n(rst_n),
        .por_n(por_n)
);

    // xclk0 generator
    // 25 MHz
    always #20 xclk0 = !(xclk0 & ~xclk0_stop);

    // xclk1 generator
    // 10 MHz
    always #50 xclk1 = !(xclk1 & ~xclk1_stop);

    // External Reset Generator
    event ext_rst;
    always @(ext_rst) begin
        xrst_n = 1'b0;
        #(1000+$urandom & 12'hFFF);
        xrst_n = 1'b1;
    end
        
    always@(posedge clk or negedge rst_n)
        if(!rst_n) begin
            sel_mux0 = 0;
            sel_rosc = 0;
            sel_mux1 = 0;
            sel_mux2 = 0;
            clk_div = 2'b00;
        end


    initial begin
        $display("start of the test ... waiting for the POR");
        // wait for PoR
        wait(rst_n == 1);
        
        // 8MHz should start first
        #2500;

        $display("switching to xclk");
        // switch to xclk
        @(posedge clk);
        sel_mux1 = 1;
        sel_mux0 = 1;
        #2500;

        $display("switching to rosc");
        // switch to rosc
        @(posedge clk);
        sel_mux0 = 0;     // back to 8mhz
        sel_mux2 = 0;       // select rosc
        sel_rosc = 2'b11;    // sel rosc freq
        #250;
        @(posedge clk);
        sel_mux0 = 1;     // sel rosc 
        #2500;

        $display("change the divider");
        // change the divider
        @(posedge clk);
        clk_div = 2'd1;
        #4000;
        @(posedge clk);
        clk_div = 2'd2;
        #4000;
        @(posedge clk);
        clk_div = 2'd3;
        #4000;
        
        $display("An external Reset");
        // An external Reset; should bring back the 8MHz
        -> ext_rst;

        #10_000;
        $display("switching back to xclk");
        // switch to xclk
        @(posedge clk);
        sel_mux1 <= 1;
        sel_mux0 <= 1;
        #2000;
        $display("stop the xclk");
        // stop the xclk
        xclk0_stop =  1;
        #10_000;
        $display("demonstrate switching between xclocks");
        // demonstrate switching between xclocks
        @(posedge clk);
        xclk0_stop =  0;
        xclk1_stop =  0;
        sel_mux1 = 1;
        @(posedge clk);
        sel_mux0 = 1;
        #4_000;
        @(posedge clk);
        sel_mux2 = 1;
        #4_000;
        $display("stop both external clocks");
        // stop both external clocks 
        @(posedge clk);
        xclk0_stop =  1;
        xclk1_stop =  1;
        #20_000;

        $finish;

    end
endmodule