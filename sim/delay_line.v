// sim/delay_line.v
// SIM-ONLY wrapper that injects tiny random skews per stage to emulate process variation.
// This is used to create "virtual chips" with different SEEDs.

`timescale 1ns/1ps

module delay_line #(
  parameter integer N = 64,
  parameter integer SEED = 1
)(
  input  wire              launch,
  input  wire [N-1:0]      challenge,
  output wire              response
);

  wire [N:0] up_path;
  wire [N:0] dn_path;

  assign up_path[0] = launch;
  assign dn_path[0] = launch;

  integer k;
  reg [15:0] skew_up   [0:N-1];
  reg [15:0] skew_down [0:N-1];

  initial begin
    integer state;
    state = SEED;
    for (k = 0; k < N; k = k + 1) begin
      skew_up[k]   = $urandom(state) % 5;   // 0..4 ps
      skew_down[k] = $urandom(state) % 5;   // 0..4 ps
      state = state + 32'h9e3779b9;
    end
  end

  genvar i;
  generate
    for (i = 0; i < N; i = i + 1) begin : stage
      wire sel = challenge[i];
      assign #(0.001*skew_up[i])   up_path[i+1] = sel ? dn_path[i] : up_path[i];
      assign #(0.001*skew_down[i]) dn_path[i+1] = sel ? up_path[i] : dn_path[i];
    end
  endgenerate

  // Decision element
  reg s, r, resp;
  assign response = resp;

  always @(*) begin
    s = up_path[N];
    r = dn_path[N];
  end

  always @(*) begin
    case ({s, r})
      2'b10: resp = 1'b1;
      2'b01: resp = 1'b0;
      default: resp = resp;
    endcase
  end

endmodule
