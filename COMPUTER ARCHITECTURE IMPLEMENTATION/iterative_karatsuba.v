/* 32-bit simple karatsuba multiplier */

/*32-bit Karatsuba multipliction using a single 16-bit module*/

module iterative_karatsuba_32_16 (clk, rst, enable, A, B, C) ; 
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    
    input enable;
    wire [1:0] sel_x;
    wire [1:0] sel_y;
    
    wire [1:0] sel_z;
    wire [1:0] sel_T;
    wire done;
    wire en_z;
    wire en_T;
    
    output [32:0] h1;
    output [32:0] h2;
    output [63:0] g1; 
    output [63:0] g2;
    
    assign C = g2;
    
    reg_with_enable #(.N(63)) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2) );  // Fill in the proper size of the register
    
    reg_with_enable #(.N(32)) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2) );  // Fill in the proper size of the register
         
    iterative_karatsuba_datapath dp(.clk(clk), .rst(rst), .X(A), .Y(B), .Z(g2), .T(h2), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1));
    
    iterative_karatsuba_control control(.clk(clk),.rst(rst), .enable(enable), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done));
    
endmodule

module iterative_karatsuba_datapath(clk, rst, X, Y, T, Z, sel_x, sel_y, en_z, sel_z, en_T, sel_T, done, W1, W2);
    input clk;
    input rst;
    input [31:0] X;    // input X
    input [31:0] Y;    // Input Y
    input [32:0] T;    // input which sums X_h*Y_h and X_l*Y_l (its also a feedback through the register)
    input [63:0] Z;    // input which calculates the final outcome (its also a feedback through the register)
    output [63:0] W1;  // Signals going to the registers as input
    output reg [32:0] W2;  // signals hoing to the registers as input
    // here what's the final value of W1 gets stored in Z , when en_z is turned on
    // Same goes for W2 it's value os stored in T when register en_t is enabled  . 

    input [1:0] sel_x;  // control signal 
    input [1:0] sel_y;  // control signal 
    input en_z;         // control signal 
    input [1:0] sel_z;  // control signal 
    input en_T;         // control signal 
    input [1:0] sel_T;  // control signal 
    
    input done;         // Final done signal
    
    //-------------------------------------------------------------------------------------------------
    
    // Write your datapath here
    wire[15:0] a ,b ;
    wire [31:0] c ; 
    reg [63:0] XY_HL ; 

    reg [15:0] a1 , b1 , a2 , b2; 
    wire [15:0] c1 , c2 ;
    reg[15:0] Xl_Xh  , Yh_Yl ;
    
    reg[31:0] Xlh_Yhl ; 
    reg[32:0] XhYh_XlYl ; 
    wire[31:0] T_next ; 


    reg[31:0] i , j  ;
    reg[32:0] d , e ;
    wire[32:0] resde_add ;
    wire[32:0] resde_sub ;

    wire [63:0] g , h; 

    wire sign_xlxh , sign_yhyl  , T_carry ;
    reg sign_net ; 

    subtract_Nbit #(.N(16)) subone (.a(a1) , .b(b1) , .cin(1'b0) ,.S(c1) , .ov() , .cout_sub(sign_xlxh)) ;

    subtract_Nbit #(.N(16)) subtwo (.a(a2) , .b(b2) , .cin(1'b0) ,.S(c2) , .ov() , .cout_sub(sign_yhyl)) ;
    
    always @(*) begin 
        a1 = (sel_x == 2'b01) ? X[15:0] : 16'b0000000000000000 ;  
        b1 = (sel_x == 2'b01) ? X[31:16] : 16'b0000000000000000 ;  
        a2 = (sel_x == 2'b01) ? Y[31:16] : 16'b0000000000000000 ;  
        b2 = (sel_x == 2'b01) ? Y[15:0] : 16'b0000000000000000 ; 
        case (sel_x)
            2'b01 : sign_net = sign_xlxh^sign_yhyl ;
        endcase
    end 

    always @(*) begin 
        case(sel_x)
            2'b01 :
                begin
                    Xl_Xh = c1 ;
                    Yh_Yl = c2 ;
                end 
        endcase 
    end 
    
    mult_16 multiplier (.X(a) , .Y(b) , .Z(c)) ;
    
    assign a = (sel_x == 2'b10) ? X[31:16] : (sel_x == 2'b01)? X[15:0] : (sel_x == 2'b11) ? Xl_Xh : 16'b0000000000000000 ;
    
    assign b = (sel_x == 2'b10) ? Y[31:16] : (sel_x == 2'b01)? Y[15:0] : (sel_x == 2'b11) ? Yh_Yl : 16'b0000000000000000 ;

    always @(*) begin 
        case (sel_x)
            2'b10 : 
                begin 
                    XY_HL[63:32] = c ;
                end 
            2'b01 : 
                begin 
                    XY_HL[31:0] = c ;
                end 
            2'b11 : 
                begin 
                    Xlh_Yhl = c ;
                end 
        endcase
    end

    always @(*) begin
        i = (sel_T == 2'b01) ? XY_HL[63:32] : 32'b00000000000000000000000000000000; 
        j = (sel_T == 2'b01) ? XY_HL[31:0] : 32'b00000000000000000000000000000000 ; 
        case(sel_T)
            2'b01 :
                begin 
                    XhYh_XlYl = {T_carry,T_next};
                end
        endcase
    end 

    adder_Nbit #(.N(32)) addone (.a(i) , .b(j) , .cin(1'b0) , .S(T_next) , .cout(T_carry)) ; 
    // Till above S3 

    adder_Nbit #(.N(33)) add1 (.a(d) , .b(e)  , .cin(1'b0) , .S(resde_add), .cout()) ; 

    subtract_Nbit #(.N(33)) subthree (.a(e) , .b(d) , .cin(1'b0) ,.S(resde_sub) , .ov() , .cout_sub()) ;
    
    always @(*) begin    
        d = (sel_y == 2'b10) ? {1'b0,Xlh_Yhl} :33'b00000000000000000000000000000000  ;
        e = (sel_y == 2'b10) ? XhYh_XlYl : 33'b00000000000000000000000000000000 ;
        W2 = (sign_net == 1'b1 && sel_y == 2'b10) ? {1'b0,resde_sub} : (sel_y == 2'b10 && sign_net == 1'b0) ? resde_add  : 33'b000000000000000000000000000000000; 
    end

    adder_Nbit #(.N(64)) addfinal (.a(g) , .b(h) , .cin(1'b0), .S(W1)) ;

    assign g = (sel_z == 2'b11) ? XY_HL : 64'b0000000000000000000000000000000000000000000000000000000000000000 ;
    assign h = (sel_z == 2'b11) ? {15'b000000000000000 ,W2,16'b0000000000000000} : 64'b0000000000000000000000000000000000000000000000000000000000000000  ;
 
    //--------------------------------------------------------

endmodule


module iterative_karatsuba_control(clk,rst, enable, sel_x, sel_y, sel_z, sel_T, en_z, en_T, done);
    input clk;
    input rst;
    input enable;
    
    output reg [1:0] sel_x;
    output reg [1:0] sel_y;
    
    output reg [1:0] sel_z;
    output reg [1:0] sel_T;    
    
    output reg en_z;
    output reg en_T;
    
    output reg done;
    
    reg [5:0] state, nxt_state;
    parameter S0 = 6'b000001;   // initial state
   // <define the rest of the states here>
    parameter S1 = 6'b000010 ;
    parameter S2 = 6'b000011 ;
    parameter S3 = 6'b000100 ;
    parameter S4 = 6'b000101 ;    
    always @(posedge clk) begin
        if (rst) begin
            state <= S0 ;
        end
        else if (enable) begin
            state <= nxt_state ;
        end
    end
    

    always@(*) begin
        case(state) 
            S0 :
                begin 
                    en_z = 0 ;
                    done = 0 ; 
                    sel_x = 2'b10 ;
                    nxt_state <= S1 ;
                end 
            S1 : 
                begin 
                    sel_x = 2'b01 ; 
                    nxt_state <= S2 ;
                end
            S2 :
                begin 
                    sel_x = 2'b11 ;
                    sel_T = 2'b01 ; 
                    nxt_state <= S3 ;
                end 
            S3 : 
                begin 
                    sel_y = 2'b10 ; 
                    nxt_state <= S4 ;
                end  
            S4 :
                begin
                    sel_z = 2'b11 ; 
                    en_z <= 1 ; 
                    done <= 1 ;    
                end
            default: 
                begin 
                    state <= S0 ;
                end            
        endcase
        
    end

endmodule


// Enable registers -> when en is set to 1 then set the value of the register
module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O );
    input [N:0] X;
    input clk;
    input rst;
    input en;
    output [N:0] O;
    
    reg [N:0] R;
    
    always@(posedge clk) begin
        if (rst) begin
            R <= {N{1'b0}};
        end
        if (en) begin
            R <= X;
        end
    end

    assign O = R;
endmodule







/*-------------------Supporting Modules--------------------*/
/*------------- Iterative Karatsuba: 32-bit Karatsuba using a single 16-bit Module*/

module mult_16(X, Y, Z);
input [15:0] X;
input [15:0] Y;
output [31:0] Z;

assign Z = X*Y;

endmodule


module mult_17(X, Y, Z);
input [16:0] X;
input [16:0] Y;
output [33:0] Z;

assign Z = X*Y;

endmodule

module full_adder(a, b, cin, S, cout);
input a;
input b;
input cin;
output S;
output cout;

assign S = a ^ b ^ cin;
assign cout = (a&b) ^ (b&cin) ^ (a&cin);

endmodule


module check_subtract (A, B, C);
 input [7:0] A;
 input [7:0] B;
 output [8:0] C;
 
 assign C = A - B; 
endmodule



/* N-bit RCA adder (Unsigned) */
module adder_Nbit #(parameter N = 32) (a, b, cin, S, cout);
input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output cout;

wire [N:0] cr;  

assign cr[0] = cin;


generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin
        full_adder addi (.a(a[i]), .b(b[i]), .cin(cr[i]), .S(S[i]), .cout(cr[i+1]));
    end
endgenerate    


assign cout = cr[N];

endmodule


module Not_Nbit #(parameter N = 32) (a,c);
input [N-1:0] a;
output [N-1:0] c;

generate
genvar i;
for (i = 0; i < N; i = i+1) begin
    assign c[i] = ~a[i];
end
endgenerate 

endmodule


/* 2's Complement (N-bit) */
module Complement2_Nbit #(parameter N = 32) (a, c, cout_comp);

input [N-1:0] a;
output [N-1:0] c;
output cout_comp;

wire [N-1:0] b;
wire ccomp;

Not_Nbit #(.N(N)) compl(.a(a),.c(b));
adder_Nbit #(.N(N)) addc(.a(b), .b({ {N-1{1'b0}} ,1'b1 }), .cin(1'b0), .S(c), .cout(ccomp));

assign cout_comp = ccomp;

endmodule


/* N-bit Subtract (Unsigned) */
module subtract_Nbit #(parameter N = 32) (a, b, cin, S, ov, cout_sub);

input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S , S_temp , S_comp;
output ov;
output cout_sub;

wire [N-1:0] minusb;
wire cout;
wire ccomp;

Complement2_Nbit #(.N(N)) compl(.a(b),.c(minusb), .cout_comp(ccomp));
adder_Nbit #(.N(N)) addc(.a(a), .b(minusb), .cin(1'b0), .S(S_temp), .cout(cout));

Complement2_Nbit #(.N(N)) comp2(.a(S_temp) , .c(S_comp) , .cout_comp()) ; 

assign ov = (~(a[N-1] ^ minusb[N-1])) & (a[N-1] ^ S_temp[N-1]);

assign cout_sub = cout | ccomp;

assign S = (cout_sub == 1'b0) ? S_comp : S_temp; 

endmodule



/* n-bit Left-shift */

module Left_barrel_Nbit #(parameter N = 32)(a, n, c);

input [N-1:0] a;
input [$clog2(N)-1:0] n;
output [N-1:0] c;


generate
genvar i;
for (i = 0; i < $clog2(N); i = i + 1 ) begin: stage
    localparam integer t = 2**i;
    wire [N-1:0] si;
    if (i == 0) 
    begin 
        assign si = n[i]? {a[N-t:0], {t{1'b0}}} : a;
    end    
    else begin 
        assign si = n[i]? {stage[i-1].si[N-t:0], {t{1'b0}}} : stage[i-1].si;
    end
end
endgenerate

assign c = stage[$clog2(N)-1].si;

endmodule