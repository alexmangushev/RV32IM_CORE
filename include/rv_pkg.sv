/***********************************************************************************
 * Copyright (C) 2023 National Research University of Electronic Technology (MIET),
 * Institute of Microdevices and Control Systems.
 * See LICENSE file for licensing details.
 *
 * This file is a part of miriscv core.
 *
 ***********************************************************************************/

package  rv_pkg;

  parameter     XLEN       	= 32;   // Data width, either 32 or 64 bit
  parameter     ILEN       	= 32;   // Instruction width, 32 bit only
  parameter		  MEM_LEN		= 18;	// Memory width, 18 bit minimum

endpackage :  rv_pkg