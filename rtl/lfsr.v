// rtl/lfsr.v
// Simple maximal-length LFSR. Width default 64 bits.

module lfsr #(
  parameter integer W = 64
)(
  input  wire clk,
  input  wire rstn,
  input  wire enable,
  output reg  [W-1:0] state
);
  wire feedback;

  // Taps chosen for 64-bit LFSR (x^64 + x^63 + x^61 + x^60 + 1)
  assign feedback = state[63] ^ state[62] ^ state[60] ^ state[59];

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      // nonzero seed
      state <= {W{1'b1}};
    end else if (enable) begin
      state <= {state[W-2:0], feedback};
    end
  end
endmodule
