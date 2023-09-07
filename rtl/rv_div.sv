/***********************************************************************************
 * Copyright (C) 2023 National Research University of Electronic Technology (MIET),
 * Institute of Microdevices and Control Systems.
 * See LICENSE file for licensing details.
 *
 * This file is a part of miriscv core.
 *
 ***********************************************************************************/
import rv_pkg::XLEN;
import rv_mdu_pkg::*;

module rv_div
(
  // Clock, reset
  input  logic                clk_i,
  input  logic                arstn_i,

  // Div control
  input  logic                div_start_i,
  input  logic [XLEN-1:0]     port_a_i,
  input  logic [XLEN-1:0]     port_b_i,
  input  logic [MDU_OP_W-1:0] mdu_op_i,
  input  logic                zero_i,
  input  logic                kill_i,
  input  logic                keep_i,

  // Div results
  output logic [XLEN-1:0]     div_result_o,
  output logic [XLEN-1:0]     rem_result_o,
  output logic                div_stall_req_o
);


  ////////////////////////
  // Local declarations //
  ////////////////////////

  enum logic [2:0] {DIV_IDLE, DIV_FIRST, DIV_COMP, DIV_LAST,
                    DIV_SIGN_CHANGE, DIV_FINISH} d_state_ff, d_next_state;

  logic        [XLEN-1:0]         div_result_ff;
  logic signed [2*XLEN:0]         rem_result_ff;
  logic        [XLEN-1:0]         div_operand_a_ff;
  logic        [XLEN-1:0]         div_operand_b_ff;
  logic                           sign_inv_ff;
  logic        [$clog2(XLEN)-1:0] iter_ff;

  logic                           sign_a;
  logic                           sign_b;
  logic                           div_done;

  assign sign_a = port_a_i[XLEN-1];
  assign sign_b = port_b_i[XLEN-1];

  assign div_done = (d_state_ff == DIV_FINISH);
  assign div_stall_req_o = (div_start_i && !div_done);


  /////////////////////////
  // Next state decision //
  /////////////////////////

  always_ff @(posedge clk_i) begin
    if (~arstn_i) begin
      d_state_ff <= DIV_IDLE;
    end
    else begin
      if (kill_i)
        d_state_ff <= DIV_IDLE;
      else
        d_state_ff <= d_next_state;
    end
  end

  always_comb begin
    case (d_state_ff)

      DIV_IDLE: begin
        if (div_start_i)
          d_next_state = DIV_FIRST;
        else
          d_next_state = DIV_IDLE;
      end

      DIV_FIRST: begin
        if (zero_i)
          d_next_state = DIV_FINISH;
        else
          d_next_state = DIV_COMP;
      end

      DIV_COMP: begin
        if (iter_ff == 'd1)
          d_next_state = DIV_LAST;
        else
          d_next_state = DIV_COMP;
      end

      DIV_LAST: begin
        if (sign_inv_ff) begin
          d_next_state = DIV_SIGN_CHANGE;
        end
        else begin
          d_next_state = DIV_FINISH;
        end
      end

      DIV_SIGN_CHANGE: begin
        d_next_state = DIV_FINISH;
      end

      DIV_FINISH: begin
        if (~keep_i)
          d_next_state = DIV_IDLE;
        else
          d_next_state = DIV_FINISH;
      end

      default: begin
        d_next_state = DIV_IDLE;
      end

    endcase
  end


  ////////////////////////////
  // Division state machine //
  ////////////////////////////

  generate
      always_ff @(posedge clk_i) begin
        if (~arstn_i) begin
          div_result_ff    <= {XLEN{1'b0}};
          rem_result_ff    <= {(2*XLEN+1){1'b0}};
          div_operand_a_ff <= {(XLEN){1'b0}};
          div_operand_b_ff <= {(XLEN){1'b0}};
          sign_inv_ff      <= 1'b0;
          iter_ff          <= {($clog2(XLEN)){1'b0}};
        end
        else begin
          case (d_state_ff)

            DIV_IDLE: begin
              case (mdu_op_i)
                MDU_DIV,
                MDU_REM:  begin
                  div_operand_a_ff <= sign_a ? (~port_a_i + 'd1) : port_a_i;
                  div_operand_b_ff <= sign_b ? (~port_b_i + 'd1) : port_b_i;
                end
                MDU_DIVU,
                MDU_REMU: begin
                  div_operand_a_ff <= port_a_i;
                  div_operand_b_ff <= port_b_i;
                end
                default: ;
              endcase

              case (mdu_op_i)
                MDU_DIV: sign_inv_ff <= (sign_a ^ sign_b);
                MDU_REM: sign_inv_ff <= sign_a;
                default: sign_inv_ff <= 1'b0;
              endcase
            end

            DIV_FIRST: begin
              iter_ff <= XLEN - 'd1;
              if (zero_i) begin
                div_result_ff <= '1;
                rem_result_ff[2*XLEN-1:XLEN] <= port_a_i;
              end
              else begin
                div_result_ff <= {{(XLEN-1){~sign_inv_ff}}, 1'b1};
                rem_result_ff[2*XLEN:XLEN] <= div_operand_a_ff[XLEN-1] - div_operand_b_ff[XLEN-1:0];
                rem_result_ff[XLEN-1:0] <= {div_operand_a_ff[XLEN-2:0], 1'b0};
              end
            end

            DIV_COMP: begin
              iter_ff <= iter_ff - 'd1;
              div_result_ff[iter_ff] <= !rem_result_ff[2*XLEN];
              rem_result_ff[XLEN-1:0] <= {rem_result_ff[XLEN-2:0], 1'b0};
              if (rem_result_ff[2*XLEN]) begin
                rem_result_ff[2*XLEN:XLEN] <= rem_result_ff[2*XLEN-1:XLEN-1] + div_operand_b_ff[XLEN-1:0];
              end
              else begin
                rem_result_ff[2*XLEN:XLEN] <= rem_result_ff[2*XLEN-1:XLEN-1] - div_operand_b_ff[XLEN-1:0];
              end
            end

            DIV_LAST: begin
              div_result_ff[0] <= !rem_result_ff[2*XLEN];
              if (rem_result_ff[2*XLEN]) begin
                rem_result_ff[2*XLEN:XLEN] <= rem_result_ff[2*XLEN:XLEN] + div_operand_b_ff[XLEN-1:0];
              end
            end

            DIV_SIGN_CHANGE: begin
              rem_result_ff[2*XLEN:XLEN] <= ~rem_result_ff[2*XLEN:XLEN] + 'd1;
              div_result_ff <= ~div_result_ff + 'd1;
            end

            default: ;
          endcase
        end
      end
  endgenerate

  assign div_result_o = div_result_ff;
  assign rem_result_o = rem_result_ff[2*XLEN-1:XLEN];

  //initial begin
  //  if ((DIV_IMPLEMENTATION != "XILINX_7_SERIES") &&
  //       (DIV_IMPLEMENTATION != "GENERIC")) begin
  //    $error("Illegal parameter 'DIV_IMPLEMENTATION' in module 'mrv1f_div': %s", DIV_IMPLEMENTATION);
  //  end
  //end

endmodule