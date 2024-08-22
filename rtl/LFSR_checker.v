`timescale 1ns / 1ps
module LFSR_checker
#(
    parameter LFSR_WIDTH = 8
)   
(   
    output                      o_lock                                                                                                      ,
    input  [LFSR_WIDTH - 1 : 0] i_LFSR                                                                                                      ,
    input                       i_reset                                                                                                     ,
    input                       clk                                     
);                                      

    localparam VALID_WIDTH   = $clog2(5)                                                                                                    ;
    localparam INVALID_WIDTH = $clog2(3)                                                                                                    ;

    localparam [1 : 0]                                      
        STATE_RESET       = 3'd0                                                                                                            ,
        STATE_CHECK       = 3'd1                                                                                                            ,
        STATE_LOCKED      = 3'd2                                                                                                            ,
        STATE_UNLOCKED    = 3'd3                                                                                                            ;

    reg [LFSR_WIDTH    - 1 : 0] expected_LFSR                                                                                               ;     
    reg [2                 : 0] state                                                                                                       ;
    reg [2                 : 0] state_next                                                                                                  ;
    reg [VALID_WIDTH   - 1 : 0] valid_cnt                                                                                                   ;               
    reg [VALID_WIDTH   - 1 : 0] valid_cnt_next                                                                                              ;         
    reg [INVALID_WIDTH - 1 : 0] invalid_cnt                                                                                                 ;
    reg [INVALID_WIDTH - 1 : 0] invalid_cnt_next                                                                                            ;
    reg                         lock                                                                                                        ;    
    reg                         lock_next                                                                                                   ;
    reg                         valid                                                                                                       ;
    wire                        feedback                                                                                                    ;
                                                                          

    always @(*) begin                                       
        case(state)                                         
            STATE_UNLOCKED: begin                                       
                lock_next            = 1'b0                                                                                                 ;
                valid_cnt_next       = valid_cnt                                                                                            ;
                invalid_cnt_next     = invalid_cnt                                                                                          ;
                valid           = valid                                                                                                     ;
                state_next           = STATE_RESET                                                                                          ; 
            end                                     
            STATE_RESET: begin                                      
                lock_next            = lock                                                                                                 ;
                valid_cnt_next       = {VALID_WIDTH{1'b0}}                                                                                  ;
                invalid_cnt_next     = {INVALID_WIDTH{1'b0}}                                                                                ;
                valid                = valid                                                                                                ;             
                state_next           = STATE_CHECK                                                                                          ;                     
            end                                     
            STATE_CHECK: begin                                      
                lock_next            = lock                                                                                                 ;
                if(i_LFSR == expected_LFSR) begin   
                    valid_cnt_next   = valid_cnt + 1'b1                                                                                     ;
                    invalid_cnt_next = invalid_cnt                                                                                          ;
                    valid            = 1'b1                                                                                                 ;
                    state_next       = (invalid_cnt > 'd0) ? STATE_RESET : (valid_cnt_next == 'd5) ? STATE_LOCKED : STATE_CHECK             ;
                end
                else begin
                    valid_cnt_next   = valid_cnt                                                                                            ;                 
                    invalid_cnt_next = invalid_cnt + 1'B1                                                                                   ;
                    valid            = 1'b0                                                                                                 ;
                    state_next       = (valid_cnt > 'd0) ? STATE_RESET : (invalid_cnt_next == 'd3) ? STATE_UNLOCKED : STATE_CHECK           ;  
                end
            end
            STATE_LOCKED: begin
                lock_next            = 1'b1                                                                                                 ;
                valid_cnt_next       = valid_cnt                                                                                            ;
                invalid_cnt_next     = invalid_cnt                                                                                          ;
                valid                = valid                                                                                                ;
                state_next           = STATE_RESET                                                                                          ;
            end                                     
            default: begin                                      
                lock_next            = lock                                                                                                 ;
                valid_cnt_next       = valid_cnt                                                                                            ;
                invalid_cnt_next     = invalid_cnt                                                                                          ;
                valid                = valid                                                                                                ;
                state_next           = state                                                                                                ;
                
            end
        endcase
    end

    always @(posedge clk) begin
        if(i_reset) begin       
            lock                        <= 1'b0                                                                                             ;
            valid_cnt                   <= {VALID_WIDTH{1'b0}}                                                                              ;
            invalid_cnt                 <= {INVALID_WIDTH{1'b0}}                                                                            ;
            state                       <= STATE_UNLOCKED                                                                                   ;
            expected_LFSR               <= {LFSR_WIDTH{1'b0}}                                                                               ;
        end                                     
        else begin                                      
            lock                        <= lock_next                                                                                        ;
            valid_cnt                   <= valid_cnt_next                                                                                   ;
            invalid_cnt                 <= invalid_cnt_next                                                                                 ;
            state                       <= state_next                                                                                       ;
            if(valid) begin
                expected_LFSR[0]        <= feedback                                                                                         ;
                expected_LFSR[1]        <= expected_LFSR[0]                                                                                 ;
                expected_LFSR[2]        <= expected_LFSR[1] ^ feedback                                                                      ;
                expected_LFSR[3]        <= expected_LFSR[2]                                                                                 ;
                expected_LFSR[4]        <= expected_LFSR[3]                                                                                 ;
                expected_LFSR[5]        <= expected_LFSR[4] ^ feedback                                                                      ;
                expected_LFSR[6]        <= expected_LFSR[5] ^ feedback                                                                      ;
                expected_LFSR[7]        <= expected_LFSR[6]                                                                                 ;
            end
            else begin
                expected_LFSR[0]        <= i_LFSR[7]                                                                                        ;
                expected_LFSR[1]        <= i_LFSR[0]                                                                                        ;
                expected_LFSR[2]        <= i_LFSR[1] ^ feedback                                                                             ;
                expected_LFSR[3]        <= i_LFSR[2]                                                                                        ;
                expected_LFSR[4]        <= i_LFSR[3]                                                                                        ;
                expected_LFSR[5]        <= i_LFSR[4] ^ feedback                                                                             ;
                expected_LFSR[6]        <= i_LFSR[5] ^ feedback                                                                             ;
                expected_LFSR[7]        <= i_LFSR[6]                                                                                        ;
            end
        end                             
    end

    assign o_lock   = lock                                                                                                                  ;
    assign feedback = (valid) ? expected_LFSR[7]  : i_LFSR[7]                                                                               ;                                                

endmodule