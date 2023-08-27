module MS_CLK_RST_tb;

    reg         xclk = 0;
    reg         xrst_n = 1;
    reg         sel_n_8mhz;
    reg         sel_xclk;
    reg [1:0]   sel_rosc;
    reg [1:0]   clk_div;
    wire        clk;
    wire        rst_n;
    wire        por_n;

    reg         xclk_stop = 0;

    initial begin
        $dumpfile("MS_CLK_RST_tb.vcd");
        $dumpvars;
    end

    MS_CLK_RST MUV (
        .xclk(xclk),
        .xrst_n(xrst_n),
        .sel_n_8mhz(sel_n_8mhz),
        .sel_xclk(sel_xclk),
        .sel_rosc(sel_rosc),
        .clk_div(clk_div),
        .clk(clk),
        .rst_n(rst_n),
        .por_n(por_n)
);

    // xclk generator
    // 25 MHz
    always #20 xclk = !(xclk & ~xclk_stop);

    // External Reset Generator
    event ext_rst;
    always @(ext_rst) begin
        xrst_n = 1'b0;
        #(1000+$urandom & 12'hFFF);
        xrst_n = 1'b1;
    end
        
    always@(posedge clk or negedge rst_n)
        if(!rst_n) begin
            sel_n_8mhz = 0;
            sel_rosc = 0;
            sel_xclk = 0;
            clk_div = 2'b00;
        end


    initial begin
        // wait for PoR
        wait(rst_n == 1);
        
        // 8MHz should start first
        #2500;

        // switch to xclk
        @(posedge clk);
        sel_xclk = 1;
        sel_n_8mhz = 1;
        #2500;

        // switch to rosc
        @(posedge clk);
        sel_n_8mhz = 0;     // back to 8mhz
        sel_xclk = 0;       // select rosc
        sel_rosc = 2'b11;    // sel rosc freq
        #250;
        @(posedge clk);
        sel_n_8mhz = 1;     // sel rosc 
        #2500;

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
        
        // An external Reset; should bring back the 8MHz
        -> ext_rst;

        #10_000;
        
        // switch to xclk
        @(posedge clk);
        sel_xclk <= 1;
        sel_n_8mhz <= 1;

        #2000;
        // stop the xclk
        xclk_stop =  1;

        #100_000;
        
        $finish;

    end
endmodule