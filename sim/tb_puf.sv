`timescale 1ns/1ps
module tb_puf;

  // Keep parameters modest so sim is fast
  localparam integer N = 64;
  localparam integer NUM_CHAL = 512;
  localparam integer REPEATS  = 5;

  reg                 launch;
  reg  [N-1:0]        chal;
  wire                respA, respB;

  // Two distinct "chips" (different seeds => different per-stage delays)
  delay_line #(.N(N), .SEED(12345)) chipA (.launch(launch), .challenge(chal), .response(respA));
  delay_line #(.N(N), .SEED(98765)) chipB (.launch(launch), .challenge(chal), .response(respB));

  // Stats & storage
  integer i, t;
  integer onesA = 0, onesB = 0;
  integer diff  = 0;
  integer stable_hitsA = 0, stable_hitsB = 0;

  reg ansA   [0:NUM_CHAL-1];
  reg ansB   [0:NUM_CHAL-1];
  reg [63:0] chal_mem [0:NUM_CHAL-1];

  // CSV output
  integer fA, fB;

  // 64-bit LFSR for challenges: x^64 + x^63 + x^61 + x^60 + 1
  reg [63:0] lfsr;
  task next_chal;
    begin
      chal      = lfsr;
      lfsr      = {lfsr[62:0], lfsr[63]^lfsr[62]^lfsr[60]^lfsr[59]};
    end
  endtask

  task pulse;
    begin
      launch = 0; #1;
      launch = 1; #1;
      launch = 0; #1;
    end
  endtask

  initial begin
    $display("Starting PUF test...");
    fA = $fopen("chipA.csv", "w");
    fB = $fopen("chipB.csv", "w");
    $fwrite(fA, "challenge,response\n");
    $fwrite(fB, "challenge,response\n");

    launch = 0;
    lfsr   = 64'h1; // non-zero seed

    // First pass: baseline answers + uniformity + CSVs
    for (i = 0; i < NUM_CHAL; i = i + 1) begin
      next_chal();
      chal_mem[i] = chal;

      pulse(); #1;

      ansA[i] = respA;
      ansB[i] = respB;

      onesA = onesA + (respA ? 1 : 0);
      onesB = onesB + (respB ? 1 : 0);
      if (respA != respB) diff = diff + 1;

      $fwrite(fA, "%h,%0d\n", chal, respA);
      $fwrite(fB, "%h,%0d\n", chal, respB);
    end

    // Reliability: repeat same challenges REPEATS times
    for (i = 0; i < NUM_CHAL; i = i + 1) begin
      chal = chal_mem[i];
      for (t = 0; t < REPEATS; t = t + 1) begin
        pulse(); #1;
        if (respA == ansA[i]) stable_hitsA = stable_hitsA + 1;
        if (respB == ansB[i]) stable_hitsB = stable_hitsB + 1;
      end
    end

    // Print metrics (use real math without SV casts)
    real uniformA, uniformB, uniqueAB, reliabA, reliabB;
    uniformA = onesA / (1.0 * NUM_CHAL);
    uniformB = onesB / (1.0 * NUM_CHAL);
    uniqueAB = diff  / (1.0 * NUM_CHAL);
    reliabA  = stable_hitsA / (1.0 * NUM_CHAL * REPEATS);
    reliabB  = stable_hitsB / (1.0 * NUM_CHAL * REPEATS);

    $display("Uniformity A = %0.3f  Uniformity B = %0.3f", uniformA, uniformB);
    $display("Uniqueness A vs B (Hamming) = %0.3f", uniqueAB);
    $display("Reliability A = %0.3f  Reliability B = %0.3f", reliabA, reliabB);

    $fclose(fA);
    $fclose(fB);
    $finish;
  end

endmodule

