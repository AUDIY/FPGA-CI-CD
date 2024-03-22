module ctrl #(
    parameter P_CSR_ADDR = 4'h0
)(
    input  logic        sys_clk  ,
    input  logic        sys_rst_n,
    output logic [13:0] csr_a    ,
    output logic        csr_we   ,
    output logic [31:0] csr_di   ,
    input  logic [31:0] csr_do   ,
    input  logic        rx_irq   ,
    input  logic        tx_irq
);

    localparam L_ADDR_DATA = {P_CSR_ADDR, 8'h00, 2'b00};

    enum logic [1:0] {S_IDLE, S_READ, S_WRITE} stat;

    assign csr_a  = L_ADDR_DATA;
    assign csr_di = csr_do     ; // loopback

    always_ff @( posedge sys_clk or negedge sys_rst_n ) begin : genblk_ff1
        if (!sys_rst_n) begin
            stat <= S_IDLE;
        end else begin
            case (stat)
                S_IDLE: begin
                    if (rx_irq) stat <= S_READ;
                end 
                S_READ: begin
                    stat <= S_WRITE;
                end
                S_WRITE: begin
                    if (tx_irq) stat <= S_IDLE;
                end
                default: begin
                    stat <= S_IDLE;
                end 
            endcase
        end
    end

    always_ff @( posedge sys_clk or negedge sys_rst_n ) begin : genblk_ff2
        if (!sys_rst_n) begin
            csr_we <= 'b0;
        end else begin
            if (stat == S_READ) begin
                csr_we <= 'b1;
            end else begin
                csr_we <= 'b0;
            end
        end
    end

endmodule
