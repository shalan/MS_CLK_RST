/*
	Copyright 2020 Efabless Corp.

	Author: Mohamed Shalan (mshalan@efabless.com)
	
	Licensed under the Apache License, Version 2.0 (the "License"); 
	you may not use this file except in compliance with the License. 
	You may obtain a copy of the License at:
	http://www.apache.org/licenses/LICENSE-2.0
	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
*/

`timescale          1ns/1ns
`default_nettype    none

`define     SPICE

module ldly #(parameter COUNT=6) (
    input wire in,
    output wire out,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);

generate
    if(COUNT > 1) begin
        wire [COUNT-2:0]    links;
        wire [COUNT-1:0]    ins = {links, in};
        wire [COUNT-1:0]    outs;
        assign {out, links} = outs;
        (* keep *) sky130_fd_sc_hd__dlygate4sd3_1 dly_cells[COUNT-1:0] (
            .X(outs), 
            .A(ins),
            .VGND(VGND),
            .VNB(VNB),
            .VPB(VPB),
            .VPWR(VPWR)
    );
    end else 
        (* keep *) sky130_fd_sc_hd__dlygate4sd3_1 dly_cell (
            .X(out), 
            .A(in),
            .VGND(VGND),
            .VNB(VNB),
            .VPB(VPB),
            .VPWR(VPWR)
    );
endgenerate
endmodule

module dly #(parameter COUNT=2) (
    input wire in,
    output wire out,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);
    generate
        if(COUNT > 1) begin
            wire [COUNT-2:0]    links;
            wire [COUNT-1:0]    ins = {links, in};
            wire [COUNT-1:0]    outs;
            assign {out, links} = outs;
            (* keep *) sky130_mm_sc_hd_dlyPoly5ns dly_cells [COUNT-1:0] (
                .out(outs), 
                .in(ins),
                .VGND(VGND),
                .VNB(VNB),
                .VPB(VPB),
                .VPWR(VPWR)
                );
        end else 
            (* keep *) sky130_mm_sc_hd_dlyPoly5ns dly_cell (
                .out(out), 
                .in(in),
                .VGND(VGND),
                .VNB(VNB),
                .VPB(VPB),
                .VPWR(VPWR)
                );
    endgenerate
endmodule

module dly_line #(parameter COUNT=1, FCOUNT=1) (
    input wire in,
    output wire out,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);
    wire w;
    dly #(.COUNT(COUNT)) delay_0 (
        .in(in), 
        .out(w), 
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );
    
    ldly #(.COUNT(FCOUNT)) delay_1 (
        .in(w), 
        .out(out), 
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR));
    
endmodule

module dly_tt #(parameter COUNT=1, FCOUNT=8) (
    input wire in,
    output wire out,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);
    wire w;
    dly #(.COUNT(COUNT)) delay_0 (
        .in(in), 
        .out(w), 
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );
    
    ldly #(.COUNT(FCOUNT)) delay_1 (
        .in(w), 
        .out(out), 
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR));
    
endmodule

module dly_ff #(parameter COUNT=2, FCOUNT=9)(
    input wire in,
    output wire out,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);
    wire w;
    
    dly #(.COUNT(COUNT)) delay_0 (
        .in(in), 
        .out(w),
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );

    ldly #(.COUNT(FCOUNT)) delay_1 (
        .in(w), 
        .out(out),
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );
    
endmodule

module rosc_2mhz(
    input wire          en,
    input wire          fbi,
    input wire [1:0]    trim,
    output wire         fbo,
    output wire         clk,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);

    wire [5:0] w;
    wire [3:0] d;

    sky130_fd_sc_hd__nand2_1    stage_0 (.Y(w[0]), .A(en), .B(fbi), .VGND(VGND), .VNB(VNB), .VPB(VPB), .VPWR(VPWR));

    dly     #(.COUNT(21))       delay_0 (.in(w[0]), .out(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_1   stage_1 (.Y(w[2]), .A(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    dly     #(.COUNT(21))       delay_1 (.in(w[2]), .out(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4   stage_2 (.Y(w[4]), .A(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4   out_0   (.Y(w[5]), .A(w[4]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    sky130_fd_sc_hd__clkinv_16  out_1   (.Y(clk), .A(w[5]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));


    dly_line    #(.COUNT(1), .FCOUNT(4))    fb_dly_0 (.in(w[4]), .out(d[0]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(9), .FCOUNT(7))    fb_dly_1 (.in(w[4]), .out(d[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(12), .FCOUNT(1))   fb_dly_2 (.in(w[4]), .out(d[2]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(17), .FCOUNT(10))  fb_dly_3 (.in(w[4]), .out(d[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    (* keep *) sky130_fd_sc_hd__mux4_4 FB_MUX (.X(fbo), .A0(d[0]), .A1(d[1]), .A2(d[2]), .A3(d[3]), .S0(trim[0]), .S1(trim[1]),  .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

endmodule

module rosc_8mhz(
    input wire          fbi,
    output wire         fbo,
    output wire         clk,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);

    wire [5:0] w;

    sky130_fd_sc_hd__clkinv_1 stage_0 (.Y(w[0]), .A(fbi), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    dly #(.COUNT(6)) delay_0 (.in(w[0]), .out(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_1 stage_1 (.Y(w[2]), .A(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    dly #(.COUNT(7)) delay_1 (.in(w[2]), .out(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4 stage_2 (.Y(w[4]), .A(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4 out_0 (.Y(w[5]), .A(w[4]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    sky130_fd_sc_hd__clkinv_16 out_1 (.Y(clk), .A(w[5]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    assign fbo = w[4];

endmodule

module rosc_16mhz(
    input wire          en,
    input wire          fbi,
    input wire [1:0]    trim,
    output wire         fbo,
    output wire         clk,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);

    wire [5:0] w;
    wire [3:0] d;

    sky130_fd_sc_hd__nand2_1 stage_0 (.Y(w[0]), .A(en), .B(fbi), .VGND(VGND), .VNB(VNB), .VPB(VPB), .VPWR(VPWR));

    dly #(.COUNT(2)) delay_0 (.in(w[0]), .out(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_1 stage_1 (.Y(w[2]), .A(w[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    dly #(.COUNT(2)) delay_1 (.in(w[2]), .out(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4 stage_2 (.Y(w[4]), .A(w[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    sky130_fd_sc_hd__clkinv_4 out_0 (.Y(w[5]), .A(w[4]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    sky130_fd_sc_hd__clkinv_16 out_1 (.Y(clk), .A(w[5]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));


    dly_line    #(.COUNT(1), .FCOUNT(6))    fb_dly_0 (.in(w[4]), .out(d[0]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(2), .FCOUNT(8))    fb_dly_1 (.in(w[4]), .out(d[1]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(3), .FCOUNT(1))    fb_dly_2 (.in(w[4]), .out(d[2]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));
    dly_line    #(.COUNT(3), .FCOUNT(9))   fb_dly_3 (.in(w[4]), .out(d[3]), .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

    (* keep *) sky130_fd_sc_hd__mux4_4 FB_MUX (.X(fbo), .A0(d[0]), .A1(d[1]), .A2(d[2]), .A3(d[3]), .S0(trim[0]), .S1(trim[1]),  .VGND(VGND),.VNB(VNB),.VPB(VPB),.VPWR(VPWR));

endmodule

module rosc (
    input wire          en_16mhz,
    input wire          en_2mhz,
    input wire [1:0]    trim_16mhz,
    input wire [1:0]    trim_2mhz,
    output wire         clk_16mhz,
    output wire         clk_8mhz,
    output wire         clk_2mhz,
    input VGND,
    input VNB,
    input VPB,
    input VPWR
);

    wire fb_16mhz;
    wire fb_8mhz;
    wire fb_2mhz;

    rosc_16mhz ROSC_16MHZ (
        .en(en_16mhz),
        .fbi(fb_16mhz),
        .trim(trim_16mhz),
        .fbo(fb_16mhz),
        .clk(clk_16mhz),
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );

    rosc_2mhz ROSC_2MHZ (
        .en(en_2mhz),
        .fbi(fb_2mhz),
        .trim(trim_16mhz),
        .fbo(fb_2mhz),
        .clk(clk_2mhz),
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );

    rosc_8mhz ROSC_8MHZ (
        .fbi(fb_8mhz),
        .fbo(fb_8mhz),
        .clk(clk_8mhz),
        .VGND(VGND),
        .VNB(VNB),
        .VPB(VPB),
        .VPWR(VPWR)
    );

endmodule

`ifndef SPICE 
module sky130_mm_sc_hd_dlyPoly5ns( 
    input VPWR,
    input in,
    output out,
    input VGND,
    input VPB,
    input VNB
);  
assign #5 out = in;
endmodule
`endif 