// hw/top.v
// Nexys A7 top. Generates challenges via LFSR, queries the PUF K times per challenge,
// majority-votes the response, and streams CSV over UART:
// "C,<16-hex-digits>,R,<0-or-1>\n"

module top #(
  parameter integer N = 64,
  parameter integer CLK_HZ = 100_000_000,
  parameter integer BAUD   = 115200,
  parameter integer K      = 5               // repeats per challenge for majority vote
)(
  input  wire clk,         // 100 MHz system clock
  input  wire btn_start,   // active high start button
  input  wire rstn,        // active low reset
  output wire uart_tx_o,   // UART TX pin to PC
  output wire [7:0] leds
);

  // Simple sync and edge detect for start button
  reg [2:0] btn_sync;
  always @(posedge clk or negedge rstn) begin
    if (!rstn) btn_sync <= 3'b000;
    else       btn_sync <= {btn_sync[1:0], btn_start};
  end
  wire start_pulse = (btn_sync[2:1] == 2'b01);

  // LFSR generates challenges when we need a new one
  reg lfsr_en;
  wire [N-1:0] chal;
  lfsr #(.W(N)) u_lfsr (
    .clk(clk),
    .rstn(rstn),
    .enable(lfsr_en),
    .state(chal)
  );

  // PUF core
  reg launch;
  wire puf_bit;
  arbiter_puf #(.N(N)) u_puf (
    .launch(launch),
    .challenge(chal),
    .response(puf_bit)
  );

  // Majority vote logic
  reg [7:0] k_cnt;
  reg [7:0] ones_cnt;
  reg voted_bit;
  reg collecting;

  // UART
  reg        uart_start;
  reg [7:0]  uart_data;
  wire       uart_busy;
  uart_tx #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) u_uart (
    .clk(clk),
    .rstn(rstn),
    .start(uart_start),
    .data(uart_data),
    .tx(uart_tx_o),
    .busy(uart_busy)
  );

  // Hex printing helper
  function [7:0] nybble_to_hex;
    input [3:0] nyb;
    begin
      nybble_to_hex = (nyb < 10) ? (8'h30 + nyb) : (8'h41 + (nyb - 10));
    end
  endfunction

  // Simple FSM to control flow
  localparam S_IDLE   = 0;
  localparam S_LAUNCH = 1;
  localparam S_WAIT   = 2;
  localparam S_COUNT  = 3;
  localparam S_VOTE   = 4;
  localparam S_PRINT  = 5;

  reg [2:0] state;

  // UART print sub-FSM
  reg [7:0] print_idx;
  reg [3:0] nyb_idx;

  // LED status
  assign leds = {7'b0, voted_bit};

  always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
      state      <= S_IDLE;
      lfsr_en    <= 1'b0;
      launch     <= 1'b0;
      collecting <= 1'b0;
      k_cnt      <= 0;
      ones_cnt   <= 0;
      voted_bit  <= 1'b0;
      uart_start <= 1'b0;
      uart_data  <= 8'h00;
      print_idx  <= 0;
      nyb_idx    <= 0;
    end else begin
      uart_start <= 1'b0; // default
      launch     <= 1'b0; // default

      case (state)
        S_IDLE: begin
          if (start_pulse) begin
            // advance challenge and start collection
            lfsr_en    <= 1'b1;
            collecting <= 1'b1;
            k_cnt      <= 0;
            ones_cnt   <= 0;
            state      <= S_LAUNCH;
          end
        end

        S_LAUNCH: begin
          lfsr_en <= 1'b0; // freeze challenge for K repeats
          launch  <= 1'b1; // single pulse
          state   <= S_WAIT;
        end

        S_WAIT: begin
          // let paths settle for a few cycles
          k_cnt    <= k_cnt;
          state    <= S_COUNT;
        end

        S_COUNT: begin
          ones_cnt <= ones_cnt + puf_bit;
          k_cnt    <= k_cnt + 1'b1;
          if (k_cnt == K - 1) begin
            state <= S_VOTE;
          end else begin
            launch <= 1'b1; // next repeat
            state  <= S_WAIT;
          end
        end

        S_VOTE: begin
          voted_bit <= (ones_cnt >= ((K+1)/2));
          // go print line: C,<hex>,R,<bit>\n
          print_idx <= 0;
          nyb_idx   <= 0;
          state     <= S_PRINT;
        end

        S_PRINT: begin
          if (!uart_busy) begin
            case (print_idx)
              0: begin uart_data <= "C"; uart_start <= 1'b1; print_idx <= 1; end
              1: begin uart_data <= ","; uart_start <= 1'b1; print_idx <= 2; end
              // 16 hex nybbles for 64-bit challenge, MSB first
              2: begin
                   uart_data  <= nybble_to_hex(chal[63:60]);
                   uart_start <= 1'b1;
                   print_idx  <= 3;
                 end
              3: begin uart_data <= nybble_to_hex(chal[59:56]); uart_start <= 1'b1; print_idx <= 4; end
              4: begin uart_data <= nybble_to_hex(chal[55:52]); uart_start <= 1'b1; print_idx <= 5; end
              5: begin uart_data <= nybble_to_hex(chal[51:48]); uart_start <= 1'b1; print_idx <= 6; end
              6: begin uart_data <= nybble_to_hex(chal[47:44]); uart_start <= 1'b1; print_idx <= 7; end
              7: begin uart_data <= nybble_to_hex(chal[43:40]); uart_start <= 1'b1; print_idx <= 8; end
              8: begin uart_data <= nybble_to_hex(chal[39:36]); uart_start <= 1'b1; print_idx <= 9; end
              9: begin uart_data <= nybble_to_hex(chal[35:32]); uart_start <= 1'b1; print_idx <= 10; end
              10: begin uart_data <= nybble_to_hex(chal[31:28]); uart_start <= 1'b1; print_idx <= 11; end
              11: begin uart_data <= nybble_to_hex(chal[27:24]); uart_start <= 1'b1; print_idx <= 12; end
              12: begin uart_data <= nybble_to_hex(chal[23:20]); uart_start <= 1'b1; print_idx <= 13; end
              13: begin uart_data <= nybble_to_hex(chal[19:16]); uart_start <= 1'b1; print_idx <= 14; end
              14: begin uart_data <= nybble_to_hex(chal[15:12]); uart_start <= 1'b1; print_idx <= 15; end
              15: begin uart_data <= nybble_to_hex(chal[11:8]);  uart_start <= 1'b1; print_idx <= 16; end
              16: begin uart_data <= nybble_to_hex(chal[7:4]);   uart_start <= 1'b1; print_idx <= 17; end
              17: begin uart_data <= nybble_to_hex(chal[3:0]);   uart_start <= 1'b1; print_idx <= 18; end
              18: begin uart_data <= ","; uart_start <= 1'b1; print_idx <= 19; end
              19: begin uart_data <= "R"; uart_start <= 1'b1; print_idx <= 20; end
              20: begin uart_data <= ","; uart_start <= 1'b1; print_idx <= 21; end
              21: begin uart_data <= (voted_bit ? "1" : "0"); uart_start <= 1'b1; print_idx <= 22; end
              22: begin uart_data <= "\n"; uart_start <= 1'b1; print_idx <= 23; end
              default: begin
                // back to idle for next challenge
                state   <= S_IDLE;
              end
            endcase
          end
        end

      endcase
    end
  end

endmodule
