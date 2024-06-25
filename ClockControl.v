`timescale 1ns / 1ps

module ClockTest(
	input clk,
	input rst,
	input btn,
	output reg [6:0] seg,  
	output reg [3:0] an,
	output reg buttons_pressed, 
	output reg buttons_released 
);

	wire is_divisible; // % ���� ���(���� �������� ��/����)
	
   reg [7:0] counter; // ��ư ī��Ʈ ����
   reg [35:0] cnt;	// Ŭ�� ī��Ʈ ����
   
	// ��ư ���� ����
   wire buttons_out;
	reg buttons_out_prev;
	
	//Seven-Segment
   reg [6:0] segments [15:0]; // 0 ~ F ������ ����
	reg [3:0] ones; // AN0
   reg [3:0] tens; // AN1
	reg [3:0] s_ones; // AN2
	reg [3:0] s_tens; // AN3
   reg [16:0] refresh_counter; // Seven-Segment�� �ǽð� ������ ���� ī����
   reg refresh_flag;	// Seven-Segment�� ������ ��ġ (AN0 ~ AN3) 
   reg [7:0] clk_display; // AN2 �� AN3�� ��Ÿ�� ����(1�� Ÿ�̸� �� ���)
	
   initial begin
      segments[0] = 7'b1000000;  // 0
      segments[1] = 7'b1111001;  // 1
      segments[2] = 7'b0100100;  // 2
      segments[3] = 7'b0110000;  // 3
      segments[4] = 7'b0011001;  // 4
      segments[5] = 7'b0010010;  // 5
      segments[6] = 7'b0000010;  // 6
      segments[7] = 7'b1111000;  // 7
      segments[8] = 7'b0000000;  // 8
      segments[9] = 7'b0010000;  // 9
      segments[10] = 7'b0001000; // 10
      segments[11] = 7'b0000011; // 11
      segments[12] = 7'b1000110; // 12
      segments[13] = 7'b0100001; // 13
      segments[14] = 7'b0000110; // 14
      segments[15] = 7'b0001110; // 15
   end
   
   
   initial begin
      cnt = 0;
      counter = 0;
      ones = 0;
      tens = 0;
      refresh_counter = 0;
      refresh_flag = 0;
      clk_display = 0;
   end
   
	//��ư ��ٿ��
   button_debounce debounce (
		.clk(clk),
		.rst(rst),
		.button_in(btn),
		.button_out(buttons_out)
   );
   
	//%��� : 1�ʾ� ��� �ϱ� ���� 20_000_000 ������ ����
   operatorremainder remainder (
        .n(cnt),
        .is_multiple(is_divisible)
    );
   
   
   always @ (posedge clk or posedge rst) begin
      if (rst) begin // �ʱ�ȭ
         cnt <= 0;
         counter <= 0;
			ones <= 0;
			tens <= 0;
			s_ones <= 0;
			s_tens <= 0;
			clk_display <= 0;
			buttons_out_prev <= 0;
			buttons_pressed <= 0;
			buttons_released <= 0;
      end else begin
			// 20_000_000 * 60 = 1_200_000_000 : 1�� Ŭ�� ����
			// 1���� ������ �ڵ����� Seven-Segment�� ǥ�õǴ� ���÷��� ������ ��� �ʱ�ȭ
			if(cnt == 1_200_000_000 -1) begin 
				cnt <= 0;
				ones <= 0;
				tens <= 0;
				s_ones <= 0;
				s_tens <= 0;
				clk_display <= 0;
			end else begin
			// 1�� ������ �ǽð� ��� : cnt(���� Ÿ�̸ӿ��� Ŭ����) % 20_000_000
			if (is_divisible) begin 
				if(clk_display == 60) begin
					s_ones <= 0;
					s_tens <= 0;
				end else begin
					clk_display <= clk_display+1;
					if(s_ones == 9) begin
						s_ones <= 0;
						s_tens <= s_tens + 1;
					end else begin
						s_ones <= s_ones + 1;
					end
				end
				
				
			end
			
			// ��ư ���� ����
			buttons_out_prev <= buttons_out;
			buttons_pressed <= (buttons_out & ~buttons_out_prev);	 // ��ư ��������
			buttons_released <= (~buttons_out & buttons_out_prev); // ��ư�� ������
			
			//��ư �������� �̺�Ʈ ó��
			if (buttons_pressed) begin
				if (ones == 9) begin
					ones <= 0;
					if (tens == 9) begin
						tens <= 0;
					end else begin
						tens <= tens + 1;
					end
				end else begin
				ones <= ones + 1;
				end
			end
			cnt <= cnt + 1;
         end   
      end
   end
   
	// Ŭ�� ī���� 250_000 ���� Seven-Segment ���÷��� �� ȭ�� ���ư��鼭 ����
	always @(posedge clk) begin
		refresh_counter <= refresh_counter + 1;
		if (refresh_counter == 250000) begin   
			refresh_counter <= 0;
			refresh_flag <= ~refresh_flag;
		end
	end
	
	always @(posedge clk) begin
		case (refresh_counter[16:15])
			2'b00: begin
				seg <= segments[ones];
				an <= 4'b1110; 
			end
			2'b01: begin
				seg <= segments[tens];
				an <= 4'b1101; 
			end
				2'b10: begin
				seg <= segments[s_ones];
				an <= 4'b1011; 
			end
				2'b11: begin
				seg <= segments[s_tens];
				an <= 4'b0111; 
			end
		endcase
end
	
endmodule