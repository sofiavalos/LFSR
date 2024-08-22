module LSFR_generator_tb;

    // Parameters   
    parameter  LFSR_WIDTH = 8                                                                   ;
    parameter  RESET = $clog2(250000)                                                           ;

    //Ports 
    wire [LFSR_WIDTH - 1 : 0] o_LFSR                                                            ;
    reg  [LFSR_WIDTH - 1 : 0] i_seed                                                            ;
    reg                  i_valid                                                                ;  
    reg                  i_reset                                                                ;  
    reg                  i_soft_reset                                                           ;               
    reg                  clk                                                                    ;
    reg  [RESET - 1 : 0] random_reset                                                           ;
    reg  [RESET - 1 : 0] random_soft_reset                                                      ;
    reg                  random_valid                                                           ;
    reg  [LFSR_WIDTH - 1 : 0] random_seed                                                       ;
    
    integer i;  

    
    always #50  clk =~ clk                                                                      ;
    
    initial begin   
        i_reset           = 1'b0                                                                ;
        i_soft_reset      = 1'b0                                                                ;
        i_valid           = 1'b0                                                                ;
        i_seed            = {LFSR_WIDTH{1'b0}}                                                  ;
        clk               = 1'b0                                                                ;
        random_reset      = {RESET{1'b0}}                                                       ;
        random_soft_reset = {RESET{1'b0}}                                                       ;
        random_valid      = 1'b0                                                                ;
        random_seed       = {LFSR_WIDTH{1'b0}}                                                  ;
    end 


    `define TEST2   

    `ifdef TEST1    
        initial begin   
            asyncronic_reset()                                                                  ;
            random_seed      = $urandom($time)                                                  ;
            set_seed(random_seed)                                                               ;
            syncronic_reset()                                                                   ;
            #100000                                                                             ;
            @(posedge clk)                                                                      ;
            random_seed      = $urandom($time)                                                  ;
            set_seed(random_seed)                                                               ;
            syncronic_reset()                                                                   ;
            #100000                                                                             ;
            $finish                                                                             ;
        end 

        always @(posedge clk) begin 
            random_valid        <= $urandom($time) %2                                           ;
            i_valid             <= random_valid                                                 ;
        end 

    `elsif TEST2    
        initial begin   
            asyncronic_reset()                                                                  ;
            i_valid              = 1'b1                                                         ;
            for(i = 0; i < 100; i = i + 1) begin    
                $display("Test %0d | Seed: %0d", i + 1'b1, random_seed)                         ;
                random_seed      = $urandom($time)                                              ;
                check_periodity(random_seed)                                                    ;
            end 
            $finish                                                                             ;
        end 

    `endif  

    task asyncronic_reset()                                                                     ;   
        begin   
            random_reset      <= 1000 + $urandom($time) %249000                                 ; 
            i_reset           <= 1'b1                                                           ;
            #random_reset                                                                       ;
            @(posedge clk)                                                                      ;
            i_reset           <= 1'b0                                                           ;
        end     
    endtask 

    task syncronic_reset()                                                                      ; 
        begin   
            random_soft_reset <= 1000 + $urandom($time) %249000                                 ; 
            i_soft_reset      <= 1'b1                                                           ;
            #random_soft_reset                                                                  ;
            @(posedge clk)                                                                      ;
            i_soft_reset      <= 1'b0                                                           ;
        end     
    endtask 

    task set_seed(input[LFSR_WIDTH - 1 : 0] seed)                                                    ; 
        begin   
            i_seed            <= seed                                                           ;
        end 
    endtask 

    task check_periodity(input[LFSR_WIDTH - 1 : 0] seed)                                             ;
        reg  [LFSR_WIDTH - 1 : 0] initial_value                                                      ;
        reg  [LFSR_WIDTH - 1 : 0] current_value                                                      ;
        integer combinations                                                                    ;

        begin
            set_seed(seed)                                                                      ;
            syncronic_reset()                                                                   ;        
            initial_value = seed                                                                ;
            @(posedge clk);
            combinations  = 'd0                                                                 ;
            while(1'b1) begin
                @(posedge clk);
                current_value = o_LFSR                                                          ;
                if(current_value == initial_value) begin
                    $display("Periodity reached after %0d combinations", combinations + 1'b1)   ;
                    disable check_periodity;
                end
                else begin
                    combinations = combinations + 'd1                                           ;
                end
            end
        end
    endtask

    LSFR_generator #  ( 
        .LFSR_WIDTH   (LFSR_WIDTH   )  
    )   
    dut               ( 
        .clk          (clk          )                                                           ,
        .i_seed       (i_seed       )                                                           ,
        .i_valid      (i_valid      )                                                           ,
        .i_reset      (i_reset      )                                                           ,
        .i_soft_reset (i_soft_reset )                                                           ,
        .o_LFSR       (o_LFSR       )   
    );  

endmodule