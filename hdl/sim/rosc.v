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

    reg clk2=0, clk8=0, clk16=0;
    
    integer period2, period8 = 127, period16;

    always #period2 clk2 = (!clk2 & en_2mhz);
    always #period8 clk8 = !clk8;
    always #period16 clk16 = (!clk16 & en_16mhz);
    
    always @(*) begin
        case(trim_2mhz)
            2'b00 : period2 = 55;
            2'b01 : period2 = 52;
            2'b10 : period2 = 51;
            2'b11 : period2 = 49;
        endcase
    end

    always @(*) begin
        case(trim_16mhz)
            2'b00 : period2 = 64;
            2'b01 : period2 = 63;
            2'b10 : period2 = 62;
            2'b11 : period2 = 62;
        endcase
    end

endmodule