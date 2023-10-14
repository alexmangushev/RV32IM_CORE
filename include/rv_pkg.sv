/***********************************************************************************
 * Copyright (C) 2023 National Research University of Electronic Technology (MIET),
 * Institute of Microdevices and Control Systems.
 * See LICENSE file for licensing details.
 *
 * This file is a part of miriscv core.
 *
 ***********************************************************************************/

package  rv_pkg;

  parameter     XLEN       	    = 32;             // Data width, either 32 or 64 bit
  parameter     ILEN       	    = 32;             // Instruction width, 32 bit only
  parameter		  MEM_LEN		      = 20;	            // Memory width, 18 bit minimum
  parameter bit RV32M           = 1;              // whether design support M-extension or not
  parameter     ADDRESS_GATE    = 32'h000F_FFFF;  // Compare adress
  parameter     ADDRESS_DEC_LT  = 32'h0001_0094;  // Decrement for addresses which less then ADDRESS_GATE
  parameter     ADDRESS_DEC_GE  = 32'h7FEF_FDB0;  // Decrement for addresses which greater than or equal ADDRESS_GATE
  parameter     ADDRESS_PER     = 32'h8000_0000;  // Start my peripheral
  parameter     ADDRESS_HEX     = 32'h8000_0004;  // HEX indicator
  parameter     ADDRESS_KEY     = 32'h8000_0008;  // KEY button

endpackage :  rv_pkg