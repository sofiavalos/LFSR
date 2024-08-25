`timescale 1ns / 1ps

    module LSFR_top
        #(
        parameter LFSR_WIDTH = 8                                                   
        )
        (
            output [LFSR_WIDTH - 1 : 0] o_LFSR                                         ,
            output                      o_lock                                         ,
            input  [LFSR_WIDTH - 1 : 0] i_seed                                         ,
            input                       i_valid                                        ,
            input                       i_reset                                        ,
            input                       i_soft_reset                                   ,
            input                       clk                                            
        );

    wire [LFSR_WIDTH - 1 : 0]       LFSR                                           ;

    LSFR_generator
    #(
        .LFSR_WIDTH     (LFSR_WIDTH     )                                                  
    )
    u_LFSR_generator
    (
        .i_seed         (i_seed         )                                           ,
        .o_LFSR         (LFSR           )                                           ,
        .i_valid        (i_valid        )                                           ,
        .i_reset        (i_reset        )                                           ,
        .i_soft_reset   (i_soft_reset   )                                           ,
        .clk            (clk            )                                  
    );

    LFSR_checker
    #(
        .LFSR_WIDTH     (LFSR_WIDTH     )
    ) 
    u_LFSR_checker  
    (   
        .o_lock         (o_lock         )                                           ,
        .i_LFSR         (LFSR           )                                           ,
        .i_reset        (i_reset        )                                           ,
        .clk            (clk            )                        
    );  

    assign o_LFSR = LFSR;

endmodule