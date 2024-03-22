`timescale 1ns/1ps

`define check_equal(exp, val) \
    if (exp !== val) begin \
        $error("[%0t] Error %m is not matched (exp: %h, val: %h)", $time, exp, val); \
        $finish; \
    end

module tb_uart ();

    localparam L_CLK_PRD = 20; // 50MHz
    localparam L_RST_PRD = 100;
    localparam L_BAUD_RATE = 115200;

    logic sys_clk;
    logic sys_rst_n;
    logic uart_rx;
    logic uart_tx;

    top DUT (.*);

    initial begin: run_testcases
        check_init_stat();
        check_loopback_char();
        check_loopback_str();
        $finish;
    end

    initial begin: gen_clk
        sys_clk = 'b0;
        forever #(L_CLK_PRD/2) sys_clk = ~sys_clk;
    end

    task check_init_stat;
        $display("[%0t] Start %m", $time);
        setup();
        `check_equal('b1, uart_tx);
        $display("[%0t] End %m", $time);
    endtask

    task check_loopback_char;
        $display("[%0t] Start %m", $time);
        setup();
        send_data("A", uart_rx);
        check_rcv_data("A", uart_tx);
        $display("[%0t] End %m", $time);
    endtask

    task check_loopback_str;
        const string str = "Hello, world!";

        $display("[%0t] Start %m", $time);
        setup();
        foreach(str[i]) begin
            send_data(str[i], uart_rx);
            check_rcv_data(str[i], uart_tx);
        end
        $display("[%0t] End %m", $time);
    endtask

    task setup;
        uart_rx = 'b0;
        sys_rst_n = 'b1;
        #(L_RST_PRD) sys_rst_n = 'b0;
        #(L_RST_PRD) sys_rst_n = 'b1;
    endtask

    task automatic send_data(logic [7:0] data, ref logic uart_rx);
        const logic [9:0] stream = {1'b1, data, 1'b0};

        for (int i = 0; i < $size(stream); i++) begin
            uart_rx = stream[i];
            #(1_000_000_000 / L_BAUD_RATE);
        end
    endtask //automatic

    task automatic check_rcv_data(logic [7:0] exp, ref logic uart_tx);
        const logic [9:0] stream = {1'b1, exp, 1'b0};

        for (int i = 0; i < $size(stream); i++) begin
            #(1000_000_000 / L_BAUD_RATE / 2);
            `check_equal(stream[i], uart_tx);
            #(1000_000_000 / L_BAUD_RATE / 2);
        end
    endtask //automatic

endmodule
