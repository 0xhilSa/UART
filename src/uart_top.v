module uart_top#(
  parameter CLK_HZ = 50_000_000,
  parameter BIT_RATE = 9600,
  parameter PAYLOAD_BITS = 8,
  parameter STOP_BITS = 1
)(
  input  wire clk,
  input  wire rst_n,
  input  wire uart_rx_in,
  input  wire tx_start,
  input  wire [PAYLOAD_BITS-1:0] tx_data,
  output wire uart_tx_out,
  output wire tx_busy,
  output wire [PAYLOAD_BITS-1:0] rx_data,
  output wire rx_valid
);
  localparam CLKS_PER_BIT = CLK_HZ / BIT_RATE;
  wire tx_done;

  uart_tx#(
    .CLKS_PER_BIT(CLKS_PER_BIT)
  )uart_tx_inst(
    .i_Clock(clk),
    .i_Tx_DV(tx_start),
    .i_Tx_Byte(tx_data),
    .o_Tx_Active(tx_busy),
    .o_Tx_Serial(uart_tx_out),
    .o_Tx_Done(tx_done)
  );

  uart_rx#(
    .CLKS_PER_BIT(CLKS_PER_BIT)
  )uart_rx_inst(
    .i_Clock(clk),
    .i_Rx_Serial(uart_rx_in),
    .o_Rx_DV(rx_valid),
    .o_Rx_Byte(rx_data)
  );
endmodule
