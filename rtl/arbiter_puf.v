// rtl/arbiter_puf.v
// Parameterized N-stage arbiter PUF.
// Challenge bits select cross or straight paths through MUX pairs.
// A simple SR latch makes the decision at the end.
// Note: On real hardware, consider majority voting across K samples per challenge.

`timescale 1ns/1ps

module arbiter_puf #(
  parameter integer N = 64
)(
  input  wire              launch,        // single-cycle pulse to launch a race
  input  wire [N-1:0]      challenge,     // challenge vector, MSB at stage N-1
  output reg               response       // 1-bit response
);

  // Keep routing intact where possible
  (* DONT_TOUCH = "TRUE" *) wire [N:0] up_path;
  (* DONT_TOUCH = "TRUE" *) wire [N:0] dn_path;

  // Launch both paths at the same time
  assign up_path[0] = launch;
  assign dn_path[0] = launch;

  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : stage
      wire sel = challenge[i];

      // Cross or straight depending on challenge bit
      assign up_path[i+1] = sel ? dn_path[i] : up_path[i];
      assign dn_path[i+1] = sel ? up_path[i] : dn_path[i];
    end
  endgenerate

  // Simple SR decision element
  reg s, r;
  always @(*) begin
    s = up_path[N];
    r = dn_path[N];
  end

  always @(*) begin
    case ({s, r})
      2'b10: response = 1'b1;
      2'b01: response = 1'b0;
      default: response = response; // hold on 00 or 11
    endcase
  end

endmodule
