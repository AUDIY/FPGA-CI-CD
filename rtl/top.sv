module top(
    input  logic sys_clk  ,
    input  logic sys_rst_n,
    input  logic uart_rx  ,
    output logic uart_tx
);

    logic [13:0] csr_a  ;
    logic        csr_we ;
    logic [31:0] csr_di ;
    logic [31:0] csr_do ;
    logic        rx_irq ;
    logic        tx_irq ;

    uart #(
        .clk_freq(50_000_000)
    ) uart (
        .sys_rst(~sys_rst_n),
        .*
    );

    ctrl ctrl (.*);
        
endmodule
