`timescale 1ns/1ps

module uart_top_tb;
  localparam CLK_HZ       = 50_000_000;
  localparam BIT_RATE     = 1_000_000;
  localparam PAYLOAD_BITS = 8;
  localparam STOP_BITS    = 1;
  localparam CLK_PERIOD   = 20;

  reg clk;
  reg rst_n;
  reg tx_start;
  reg [PAYLOAD_BITS-1:0] tx_data;
  wire uart_tx_out;
  wire tx_busy;
  wire [PAYLOAD_BITS-1:0] rx_data;
  wire rx_valid;
  wire uart_rx_in;

  assign uart_rx_in = uart_tx_out;

  uart_top#(
    .CLK_HZ(CLK_HZ),
    .BIT_RATE(BIT_RATE),
    .PAYLOAD_BITS(PAYLOAD_BITS),
    .STOP_BITS(STOP_BITS)
  ) dut (
    .clk(clk),
    .rst_n(rst_n),
    .uart_rx_in(uart_rx_in),
    .tx_start(tx_start),
    .tx_data(tx_data),
    .uart_tx_out(uart_tx_out),
    .tx_busy(tx_busy),
    .rx_data(rx_data),
    .rx_valid(rx_valid)
  );

  always #(CLK_PERIOD/2) clk = ~clk;

  initial begin
    $dumpfile("uart_top_tb.vcd");
    $dumpvars(0, uart_top_tb);

    clk = 0;
    rst_n = 0;
    tx_start = 0;
    tx_data = 0;

    #(10*CLK_PERIOD);
    rst_n = 1;
    $display("[%0t] Reset deasserted", $time);

    #(10*CLK_PERIOD);
    tx_data = 8'hA5;
    tx_start = 1;
    $display("[%0t] TX Start: Sending 0x%0h", $time, tx_data);
    #(CLK_PERIOD);
    tx_start = 0;

    wait (rx_valid);
    $display("[%0t] RX Received: 0x%0h", $time, rx_data);

    if (rx_data == tx_data)
      $display("[%0t] TEST PASSED ✅", $time);
    else
      $display("[%0t] TEST FAILED ❌ (Expected: 0x%0h, Got: 0x%0h)", $time, tx_data, rx_data);

    #(10*CLK_PERIOD);
    $finish;
  end
endmodule

