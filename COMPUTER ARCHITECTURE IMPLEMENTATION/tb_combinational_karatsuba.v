`timescale 1ns/1ps

module tb_combinational_karatsuba;

parameter N = 16;

// declare your signals as reg or wire
reg  [N-1:0] X , Y ;
wire [2*N-1:0] Z  ;

initial begin
// write the stimuli conditions
    repeat(10) begin
        X = $random ;
        Y = $random ;
        #100 $monitor("The value of , X = %d  ,Y = %d , Z = %d " , X , Y ,  Z) ;
    end
end

karatsuba_16 #(.N(N)) dut (.X(X), .Y(Y), .Z(Z));

initial begin
    $dumpfile("combinational_karatsuba.vcd");
    $dumpvars(0, tb_combinational_karatsuba);
end

endmodule
