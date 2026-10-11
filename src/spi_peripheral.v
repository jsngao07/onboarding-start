module spi_peripheral(
    input wire clk,
    input wire rst_n,
    input wire COPI,
    input wire SCLK,
    input wire nCS,
    output reg [7:0] en_reg_out_7_0,
    output reg [7:0] en_reg_out_15_8,
    output reg [7:0] en_reg_pwm_7_0,
    output reg [7:0] en_reg_pwm_15_8,
    output reg [7:0] pwm_duty_cycle
);

reg [15:0] spi_shift_reg;
reg [4:0] bit_count;
reg COPI_s1, COPI_s2;
reg SCLK_s1, SCLK_s2, SCLK_s3;
reg nCS_s1, nCS_s2, nCS_s3;


localparam [6:0] max_address = 7'd4;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        COPI_s1 <= 1'b0; COPI_s2 <= 1'b0;
        SCLK_s1 <= 1'b0; SCLK_s2 <= 1'b0; SCLK_s3 <= 1'b0;
        nCS_s1 <= 1'b1; nCS_s2 <= 1'b1; nCS_s3 <= 1'b1;

    end else begin
        COPI_s1 <= COPI; COPI_s2 <= COPI_s1;
        SCLK_s1 <= SCLK; SCLK_s2 <= SCLK_s1; SCLK_s3 <= SCLK_s2;
        nCS_s1 <= nCS; nCS_s2 <= nCS_s1; nCS_s3 <= nCS_s2;
    end
end


wire SCLK_rising = SCLK_s2 & ~SCLK_s3;
wire nCS_rising = nCS_s2 & ~nCS_s3;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        spi_shift_reg <= 16'b0;
        bit_count <= 5'd0;
    end else begin
        if(nCS_rising) begin
            spi_shift_reg <= 16'b0;
            bit_count <= 5'd0;
        end else if(SCLK_rising && !nCS_s2) begin
            spi_shift_reg <= {spi_shift_reg[14:0], COPI_s2};
            if(bit_count != 5'd31) begin
                bit_count <= bit_count + 5'd1;
            end
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        en_reg_out_7_0 <= 8'b0;
        en_reg_out_15_8 <= 8'b0;
        en_reg_pwm_7_0 <= 8'b0;
        en_reg_pwm_15_8 <= 8'b0;
        pwm_duty_cycle <= 8'b0;
    end else begin
        if(nCS_rising && bit_count == 5'd16
        && spi_shift_reg[15]
        && spi_shift_reg[14:8] <= max_address) begin
            case(spi_shift_reg[14:8])
                7'd0: en_reg_out_7_0 <= spi_shift_reg[7:0];
                7'd1: en_reg_out_15_8 <= spi_shift_reg[7:0];
                7'd2: en_reg_pwm_7_0 <= spi_shift_reg[7:0];
                7'd3: en_reg_pwm_15_8 <= spi_shift_reg[7:0];
                7'd4: pwm_duty_cycle <= spi_shift_reg[7:0];
            default:;
            endcase
        end
    end
end
endmodule