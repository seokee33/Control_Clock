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

	wire is_divisible; // % 연산 계산(나눠 떨어지는 참/거짓)
	
   reg [7:0] counter; // 버튼 카운트 숫자
   reg [35:0] cnt;	// 클럭 카운트 숫자
   
	// 버튼 제어 변수
   wire buttons_out;
	reg buttons_out_prev;
	
	//Seven-Segment
   reg [6:0] segments [15:0]; // 0 ~ F 까지의 숫자
	reg [3:0] ones; // AN0
   reg [3:0] tens; // AN1
	reg [3:0] s_ones; // AN2
	reg [3:0] s_tens; // AN3
   reg [16:0] refresh_counter; // Seven-Segment를 실시간 갱신을 위한 카운팅
   reg refresh_flag;	// Seven-Segment의 갱신한 위치 (AN0 ~ AN3) 
   reg [7:0] clk_display; // AN2 와 AN3에 나타낼 숫자(1분 타이머 초 계산)
	
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
   
	//버튼 디바운싱
   button_debounce debounce (
		.clk(clk),
		.rst(rst),
		.button_in(btn),
		.button_out(buttons_out)
   );
   
	//%계산 : 1초씩 계산 하기 위해 20_000_000 나머지 연산
   operatorremainder remainder (
        .n(cnt),
        .is_multiple(is_divisible)
    );
   
   
   always @ (posedge clk or posedge rst) begin
      if (rst) begin // 초기화
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
			// 20_000_000 * 60 = 1_200_000_000 : 1분 클럭 설정
			// 1분이 끝나면 자동으로 Seven-Segment에 표시되는 디스플레이 값들을 모두 초기화
			if(cnt == 1_200_000_000 -1) begin 
				cnt <= 0;
				ones <= 0;
				tens <= 0;
				s_ones <= 0;
				s_tens <= 0;
				clk_display <= 0;
			end else begin
			// 1초 단위로 실시간 계산 : cnt(현재 타이머에서 클럭수) % 20_000_000
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
			
			// 버튼 상태 제어
			buttons_out_prev <= buttons_out;
			buttons_pressed <= (buttons_out & ~buttons_out_prev);	 // 버튼 눌렀을때
			buttons_released <= (~buttons_out & buttons_out_prev); // 버튼을 땠을때
			
			//버튼 눌렀을때 이벤트 처리
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
   
	// 클럭 카운팅 250_000 마다 Seven-Segment 디스플레이 각 화면 돌아가면서 갱신
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