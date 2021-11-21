//`timescale 1ns

module tb_fir_unfolded ();

   wire CLK_i;
   wire RST_n_i;
   wire [10:0] DINK0_i;
   wire [10:0] DINK1_i;
   wire [10:0] DINK2_i;
   wire VIN_i;
   wire [10:0] H0_i;
   wire [10:0] H1_i;
   wire [10:0] H2_i;
   wire [10:0] H3_i;
   wire [10:0] H4_i;
   wire [10:0] H5_i;
   wire [10:0] H6_i;
   wire [10:0] H7_i;
   wire [10:0] H8_i;
   wire [10:0] DOUTK0_i;
   wire [10:0] DOUTK1_i;
   wire [10:0] DOUTK2_i;
   wire VOUT_i;
   wire END_SIM_i;

   clk_gen CG(.END_SIM(END_SIM_i),
  	      .CLK(CLK_i),
	      .RST_n(RST_n_i));

   data_maker_unfolded SM(.CLK(CLK_i),
	         .RST_n(RST_n_i),
		 .VOUT(VIN_i),
		 .DOUTK0(DINK0_i),
		 .DOUTK1(DINK1_i),
		 .DOUTK2(DINK2_i),
		 .H0(H0_i),
		 .H1(H1_i),
		 .H2(H2_i),
		 .H3(H3_i),
		 .H4(H4_i),
		 .H5(H5_i),
		 .H6(H6_i),
		 .H7(H7_i),
		 .H8(H8_i),
		 .END_SIM(END_SIM_i));

   myfir_unfolded UUT(.CLK(CLK_i),
	     .RST_n(RST_n_i),
	     .DINK0(DINK0_i),
		 .DINK1(DINK1_i),
		 .DINK2(DINK2_i),
             .VIN(VIN_i),
	     .H0(H0_i),
		 .H1(H1_i),
		 .H2(H2_i),
		 .H3(H3_i),
		 .H4(H4_i),
		 .H5(H5_i),
		 .H6(H6_i),
		 .H7(H7_i),
		 .H8(H8_i),
             .DOUTK0(DOUTK0_i),
             .DOUTK1(DOUTK1_i),
             .DOUTK2(DOUTK2_i),
             .VOUT(VOUT_i));

   data_sink_unfolded DS(.CLK(CLK_i),
		.RST_n(RST_n_i),
		.VIN(VOUT_i),
		.DINK0(DOUTK0_i),
		.DINK1(DOUTK1_i),
		.DINK2(DOUTK2_i));   

endmodule

		   
