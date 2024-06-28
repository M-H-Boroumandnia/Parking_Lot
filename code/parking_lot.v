module Parking_LOT(car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, in_out_time, clk, init, init_uni_car, init_car,
                    out_uni_parked_car, out_parked_car, out_uni_vacated_space, out_vacated_space, out_uni_is_vacated_space, out_is_vacated_space, out_ready);

    parameter MAX_CAP = 11'd700;                

    input unsigned [4:0] in_out_time;
    input unsigned [10:0] init_uni_car, init_car;
    input unsigned car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, clk, init;
    
    reg unsigned uni_is_vacated_space, is_vacated_space, ready;
    reg unsigned [10:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space;
    reg unsigned [2:0] current_state;

    output reg unsigned out_uni_is_vacated_space, out_is_vacated_space, out_ready;
    output reg unsigned [10:0] out_uni_parked_car, out_parked_car, out_uni_vacated_space, out_vacated_space;

    always @(posedge clk) begin

        if(current_state === 3'bx) begin
            ready <= 0;
            current_state <= 0;

            if(in_out_time < 5'd13 & in_out_time > 5'd8) begin
                vacated_space <= 11'd200;
            end
            else if(in_out_time >= 5'd13 || in_out_time < 5'd8) begin
                case (in_out_time)
                    5'd13 : vacated_space <= 11'd250;
                    5'd14 : vacated_space <= 11'd300;
                    5'd15 : vacated_space <= 11'd350; 
                    default: vacated_space <= 11'd500;                 
                endcase
            end
            uni_vacated_space <= 11'd500;
        end
        else if(current_state == 0) begin
            current_state <= 3'b1;

            if(init == 1) begin
                uni_is_vacated_space <= 1'b1;
                is_vacated_space <= 1'b1;

                if(init_uni_car <= uni_vacated_space) begin
                    uni_vacated_space <= uni_vacated_space - init_uni_car;
                    uni_parked_car <= init_uni_car;
                end
                else begin
                    uni_parked_car <= 0;
                end
            end
            else begin
                current_state <= 3'd3;

                if((parked_car + uni_vacated_space) > MAX_CAP & (MAX_CAP - uni_parked_car - parked_car) == 0) begin
                    uni_vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                    uni_is_vacated_space <= 0;
                end 
                else if((parked_car + uni_vacated_space) > MAX_CAP & (MAX_CAP - uni_parked_car - parked_car) != 0) begin
                    uni_vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                    uni_is_vacated_space <= 1'b1;
                end
                else if((parked_car + uni_vacated_space) <= MAX_CAP & (MAX_CAP - uni_parked_car - parked_car) == 0) begin
                    uni_vacated_space <= uni_vacated_space - uni_parked_car;
                    uni_is_vacated_space <= 0;
                end
                else if((parked_car + uni_vacated_space) <= MAX_CAP & (MAX_CAP - uni_parked_car - parked_car) != 0) begin
                    uni_vacated_space <= uni_vacated_space - uni_parked_car;
                    uni_is_vacated_space <= 1'b1;
                end

                if(vacated_space + uni_parked_car > MAX_CAP & MAX_CAP - uni_parked_car - parked_car == 0) begin
                    vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                    is_vacated_space <= 0;  
                end
                else if(vacated_space + uni_parked_car > MAX_CAP & MAX_CAP - uni_parked_car - parked_car != 0) begin
                    vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                    is_vacated_space <= 1'b1;  
                end
                else if(vacated_space + uni_parked_car <= MAX_CAP & (vacated_space - parked_car == 0)) begin
                    vacated_space <= vacated_space - parked_car;  
                    is_vacated_space <= 0;  
                end
                else if(vacated_space + uni_parked_car <= MAX_CAP & (vacated_space - parked_car == 0) != 0) begin
                    vacated_space <= vacated_space - parked_car;  
                    is_vacated_space <= 1'b1;  
                end     
            end        
        end
        else if(current_state == 1'b1) begin
            current_state <= 3'd2;

            if((vacated_space + uni_parked_car > MAX_CAP) & (init_car <= (MAX_CAP - uni_parked_car))) begin
                vacated_space <= MAX_CAP - uni_parked_car - init_car;
                parked_car <= init_car;
            end
            else if((vacated_space + uni_parked_car > MAX_CAP) & (init_car > (MAX_CAP - uni_parked_car))) begin
                vacated_space <= MAX_CAP - uni_parked_car;
                parked_car <= 0;
            end
            else if((vacated_space + uni_parked_car <= MAX_CAP) && (init_car <= (MAX_CAP - uni_parked_car))) begin
                vacated_space <= vacated_space - init_car;
                parked_car <= init_car;
            end
            else if((vacated_space + uni_parked_car <= MAX_CAP) && (init_car > (MAX_CAP - uni_parked_car))) begin
                vacated_space <= vacated_space - init_car;
                parked_car <= 0;
            end

        end
        else if(current_state == 3'd2) begin
            current_state <= 3'dx;
            ready <= 1'b1;

            if(uni_parked_car + parked_car + uni_vacated_space > MAX_CAP && (MAX_CAP - uni_parked_car - parked_car) == 0) begin
                uni_vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                uni_is_vacated_space <= 0;
            end 
            else if (uni_parked_car + parked_car + uni_vacated_space > MAX_CAP && (MAX_CAP - uni_parked_car - parked_car) != 0) begin
                uni_vacated_space <= MAX_CAP - uni_parked_car - parked_car;
                uni_is_vacated_space <= 1'b1;
            end
            else if (uni_parked_car + parked_car + uni_vacated_space <= MAX_CAP && (MAX_CAP - uni_parked_car - parked_car) == 0) begin
                uni_is_vacated_space <= 0;
            end
            else if (uni_parked_car + parked_car + uni_vacated_space <= MAX_CAP && (MAX_CAP - uni_parked_car - parked_car) != 0) begin
                uni_is_vacated_space <= 1'b1;
            end  

            if(vacated_space == 0) begin
                is_vacated_space <= 0;  
            end   
            else begin 
                is_vacated_space <= 1'b1;  
            end    
        end
        else if(current_state == 3'd3) begin
            current_state <= 3'd4;

            if(car_exited == 1'b1) begin
                if(is_uni_car_exited == 1'b1) begin

                    if(uni_parked_car != 0) begin
                        uni_parked_car <= uni_parked_car - 11'd1;
                        uni_vacated_space <= uni_vacated_space + 11'd1;
                        uni_is_vacated_space <= 1'b1;
                    end    
                end
                else if(parked_car != 0) begin

                    parked_car <= parked_car - 11'd1;
                    vacated_space <= vacated_space + 11'd1;
                    is_vacated_space <= 1'b1; 
                    if(uni_vacated_space + uni_parked_car < 11'd500) begin
                        uni_vacated_space <= uni_vacated_space + 11'd1;
                        uni_is_vacated_space <= 1'b1;
                    end    
                end
            end
        end
        else if(current_state == 3'd4) begin
            current_state <= 3'd5;

            if(car_entered == 1'b1) begin
                if(is_uni_car_entered == 1'b1) begin
                    if(uni_is_vacated_space ==1'b1) begin
                        uni_parked_car <= uni_parked_car + 11'd1;
                        uni_vacated_space <= uni_vacated_space - 11'd1;
                    end
                end
                else if(is_vacated_space == 1'b1) begin
                    parked_car <= parked_car + 11'd1;
                    vacated_space <= vacated_space - 11'd1;
                end
            end
        end
        else if(current_state == 3'd5) begin
            ready <= 1'b1;
            current_state <= 3'dx;

            if((uni_parked_car + parked_car + vacated_space > MAX_CAP) || (vacated_space == 0)) begin
                vacated_space <= 0;
                is_vacated_space <= 0;  
            end 
            else if(vacated_space != 0) begin
                is_vacated_space <= 1'b1;
            end

            if((uni_parked_car + parked_car + uni_vacated_space > MAX_CAP) || (uni_is_vacated_space == 0)) begin
                uni_vacated_space <= 0; 
                uni_is_vacated_space <= 0;  
            end 
            else begin
                uni_is_vacated_space <= 1'b1;
            end 

        end 

        out_ready <= ready;
        out_is_vacated_space <= is_vacated_space;
        out_uni_is_vacated_space <= uni_is_vacated_space;
        out_parked_car <= parked_car;
        out_uni_parked_car <= uni_parked_car;
        out_vacated_space <= vacated_space;
        out_uni_vacated_space <= uni_vacated_space;
    end

endmodule

module Parking_Lot_TB;

    reg [4:0] in_out_time;
    reg [10:0] init_uni_car, init_car;
    reg car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, init, clk;

    wire uni_is_vacated_space, is_vacated_space, ready;
    wire [10:0] uni_parked_car, parked_car, uni_vacated_space, vacated_space;

    Parking_LOT lot(car_entered, is_uni_car_entered, car_exited, is_uni_car_exited, in_out_time, clk, init, init_uni_car, init_car,
                    uni_parked_car, parked_car, uni_vacated_space, vacated_space, uni_is_vacated_space, is_vacated_space, ready);

    always #1 clk = ~clk;

    initial begin
        clk = 1'b1; init = 1'b0; car_entered = 1'b0; car_exited = 1'b0; in_out_time = 10;
        $monitor("(%03t) time : %d, init : %b ==> uni_is_vacated_space = %b, is_vacated_space = %b, uni_parked_car = %d, parked_car = %d, uni_vacated_space = %d, vacated_space = %d, ready = %b",
                $time, in_out_time, init, uni_is_vacated_space, is_vacated_space, uni_parked_car, parked_car, uni_vacated_space, vacated_space, ready);

        #8 in_out_time = 16; init = 1'b1; init_car = 11'd400; init_uni_car = 11'd100;
        #14 in_out_time = 13; init = 1'b0; car_entered = 1'b1;  is_uni_car_entered = 1'b1; car_exited = 1'b1; is_uni_car_exited = 1'b0;

        #202 $finish;
    end

endmodule