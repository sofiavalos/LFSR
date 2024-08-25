`timescale 1ns / 1ps

module LSFR_generator
#(
    parameter LFSR_WIDTH = 8                                                   
)
(
    output [LFSR_WIDTH - 1 : 0] o_LFSR                                         ,
    input  [LFSR_WIDTH - 1 : 0] i_seed                                         ,
    input                       i_valid                                        ,
    input                       i_reset                                        ,
    input                       i_soft_reset                                   ,
    input                       clk                                            
);
    
    wire                       feedback                                        ;
    reg  [LFSR_WIDTH - 1 : 1]  system_seed                                     ;
    reg  [LFSR_WIDTH - 1 : 0]  LFSR                                            ;

    always @(posedge clk or posedge i_reset) begin
        if(i_reset) begin
        system_seed <= {{LFSR_WIDTH {1'b1}}}                                   ;                                     
        LFSR        <= system_seed                                             ;
        end                                                                 
        else if(i_soft_reset) begin
        system_seed <= system_seed                                             ;
        LFSR        <= i_seed                                                  ;
        end
        else if(i_valid) begin
        system_seed <= system_seed                                             ;
        LFSR[0]     <= feedback                                                ;
        LFSR[1]     <= LFSR[0]                                                 ;                
        LFSR[2]     <= LFSR[1] ^ feedback                                      ;
        LFSR[3]     <= LFSR[2]                                                 ;           
        LFSR[4]     <= LFSR[3]                                                 ;           
        LFSR[5]     <= LFSR[4] ^ feedback                                      ;
        LFSR[6]     <= LFSR[5] ^ feedback                                      ;
        LFSR[7]     <= LFSR[6]                                                 ;
        end           
        else begin
        system_seed <= system_seed                                             ;
        LFSR        <=  LFSR                                                   ; 
        end      
    end

    assign o_LFSR   = LFSR                                                     ;
    assign feedback = LFSR[7]                                                  ;
endmodule


