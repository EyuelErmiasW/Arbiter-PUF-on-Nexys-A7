// rtl/uart_tx.v
// UART transmitter. Parameterized by clock and baud.
// Sends 1 start bit (0), 8 data bits (LSB first), 1 stop bit (1).

module uart_tx #(
  parameter integer CLK_HZ = 100_000_000,
  parameter integer BAUD   = 115200
)(
  input  wire clk,
  input  wire rstn,
  input  wire start,
  input  wire [7:0] data,
  output reg  tx,
  output reg  busy
);
  localparam integer DIV = CLK_HZ / BAUD;

  reg [15:0] divcnt;
  reg [3:0]  bitcnt;
  reg [9:0]  shreg;

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      tx     <= 1'b1;
      busy   <= 1'b0;
      divcnt <= 0;
      bitcnt <= 0;
      shreg  <= 10'h3FF;
    end else begin
      if (!busy) begin
        if (start) begin
          // frame: start(0), 8 data bits, stop(1)
          shreg  <= {1'b1, data, 1'b0};
          busy   <= 1'b1;
          divcnt <= 0;
          bitcnt <= 0;
        end
      end else begin
        if (divcnt == DIV - 1) begin
          divcnt <= 0;
          tx     <= shreg[0];
          shreg  <= {1'b1, shreg[9:1]};
          bitcnt <= bitcnt + 1'b1;
          if (bitcnt == 10) begin
            busy <= 1'b0;
            tx   <= 1'b1;
          end
        end else begin
          divcnt <= divcnt + 1'b1;
        end
      end
    end
  end

endmodule
