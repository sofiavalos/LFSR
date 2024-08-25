`timescale 1ns/1ps
module LFSR_checker_tb;

    parameter LFSR_WIDTH = 8                                                                    ;

    wire                      o_lock                                                            ;
    reg  [LFSR_WIDTH - 1 : 0] i_seed                                                            ;
    wire [LFSR_WIDTH - 1 : 0] LFSR                                                              ;
    reg                       i_valid                                                           ;  
    reg                       i_reset                                                           ;  
    reg                       i_soft_reset                                                      ;               
    reg                       clk                                                               ;
    
    integer i                                                                                   ;
    integer random                                                                              ;

    always #50  clk =~ clk                                                                      ;

    initial begin   
        i_reset           = 1'b1                                                                ;
        i_soft_reset      = 1'b0                                                                ;
        i_valid           = 1'b0                                                                ;
        i_seed            = {LFSR_WIDTH{1'b0}}                                                  ;
        clk               = 1'b0                                                                ;
        // Inicializa monitor o_lock
        $monitor("time = %0d | o_lock = %0d", $time, o_lock)                                    ;
        #1000                                                                                   ;
        @(posedge clk)                                                                          ;
        i_reset           = 1'b0                                                                ;
        i_seed            = {LFSR_WIDTH{1'b1}}                                                  ;
        i_soft_reset      = 1'b1                                                                ;
        #1000                                                                                   ;
        @(posedge clk)                                                                          ;
        i_soft_reset      = 1'b0                                                                ;
    end

    `define TEST5

    `ifdef TEST1 
        initial begin
            #2000																				;
            @(posedge clk)																		;
            i_valid           = 1'b1                                                            ;
            #25600                                                                              ;  
            @(posedge clk)																		;
            if(o_lock)
                $display("Test passed")                                                         ;
            else
                $display("Test failed")                                                         ;
            $finish                                                                             ;                              
        end

    `elsif TEST2
        initial begin
            #2000																				;
            @(posedge clk)																		;
            for(i = 0; i < 50; i = i + 1) begin
                // 4 datos validos y 1 invalido
                i_valid        = 1'b1                                                           ;
                #400                                                                            ;  
                @(posedge clk)                                                                  ;
                i_valid        = 1'b0                                                           ;
                #100                                                                            ;
                @(posedge clk)                                                                  ;
                if(o_lock) begin
                    $display("Test failed")                                                     ;
                    $finish                                                                     ;    
                end
            end
            $display("Test passed")                                                             ;
            $finish                                                                             ;
        end

    `elsif TEST3
        initial begin
            #2000                                                                               ;
            @(posedge clk)                                                                      ;
            i_valid           = 1'b1                                                            ;
            #3000                                                                               ;
            @(posedge clk)                                                                      ;
            for(i = 0; i < 50; i = i + 1) begin
                // 2 datos invalidos y 1 valido
                i_valid        = 1'b0                                                           ;
                #200                                                                            ;
                @(posedge clk)                                                                  ;
                i_valid        = 1'b1                                                           ; 
                #200                                                                            ;
                @(posedge clk)                                                                  ; 
                if(!o_lock) begin
                    $display("Test failed")                                                     ;
                    $finish                                                                     ;
                end
            end
            $display("Test passed")                                                             ;
            $finish                                                                             ;
        end

    `elsif TEST4
        initial begin
            #2000                                                                               ;
            @(posedge clk)                                                                      ;
            for(i = 0; i < 50; i = i + 1) begin
                // 5 datos validos y 3 invalidos
                i_valid        = 1'b1                                                           ;
                #800                                                                            ;
                @(posedge clk)                                                                  ;
                i_valid        = 1'b0                                                           ; 
                #600                                                                            ;
                @(posedge clk)                                                                  ; 
            end
            $finish                                                                             ;
        end
    `elsif TEST5
        initial begin
            #2000                                                                               ;
            @(posedge clk)                                                                      ;
            i_valid           = 1'b1                                                            ;
            for(i = 0; i < 50; i = i + 1) begin
                random = $urandom($time) % 2500                                                 ;
                #random                                                                         ;
                @(posedge clk)                                                                  ;
                i_valid           = 1'b1                                                        ;
                #1000                                                                           ;
                @(posedge clk)                                                                  ;
                if(!o_lock) begin
                    $display("Test failed")                                                     ;
                    $finish                                                                     ;
                end
            end
            $display("Test passed")                                                             ;
            $finish                                                                             ;
        end
    `endif

    LSFR_top
    #(
        .LFSR_WIDTH     (LFSR_WIDTH     )                                                 
    )
    u_LSFR_top
    (
        .o_LFSR         (LFSR           )                                                       ,
        .o_lock         (o_lock         )                                                       ,
        .i_seed         (i_seed         )                                                       ,
        .i_valid        (i_valid        )                                                       ,
        .i_reset        (i_reset        )                                                       ,
        .i_soft_reset   (i_soft_reset   )                                                       ,
        .clk            (clk            )                                  
    );
       
endmodule