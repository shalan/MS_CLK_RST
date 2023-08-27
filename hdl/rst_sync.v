/*
    Reset Synchronizer.

    Author: Mohamed Shalan (mshalan@aucegypt.edu)
*/
`timescale 			1ns/1ps
`default_nettype 	none

module rst_sync (
	input 	wire	clk,
	input 	wire	rst_n,
	output 	wire	srst_n
);
	(* keep *)
	reg [2:0] rst_sync;
	always @ (posedge clk or negedge rst_n) begin
		if(!rst_n) begin
			rst_sync[0] <= 1'b0;
			rst_sync[1] <= 1'b0;	
			rst_sync[2] <= 1'b0;	
		end 
		else begin
			rst_sync[0] <= 1'b1;
			rst_sync[1] <= rst_sync[0];
			rst_sync[2] <= rst_sync[1];			
		end
	end
	assign srst_n = rst_sync[2];
	
endmodule