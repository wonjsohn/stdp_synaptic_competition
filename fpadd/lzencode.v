// leading zero encoder for floating point adder

assign normalshift =
		sum[25] ? 0 :
		sum[24] ? 1 :
		sum[23] ? 2 :
		sum[22] ? 3 :
		sum[21] ? 4 :
		sum[20] ? 5 :
		sum[19] ? 6 :
		sum[18] ? 7 :
		sum[17] ? 8 :
		sum[16] ? 9 :
		sum[15] ? 10 :
		sum[14] ? 11 :
		sum[13] ? 12 :
		sum[12] ? 13 :
		sum[11] ? 14 :
		sum[10] ? 15 :
		sum[9] ? 16 :
		sum[8] ? 17 :
		sum[7] ? 18 :
		sum[6] ? 19 :
		sum[5] ? 20 :
		sum[4] ? 21 :
		sum[3] ? 22 :
		sum[2] ? 23 :
		sum[1] ? 24 : 25;