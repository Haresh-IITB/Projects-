module half_adder ( input a, input b , output S , output cout) ;

    xor (S,a,b) ; 
    and (cout,a,b) ;

endmodule 

module full_adder (input a , input b , input cin , output S , output cout) ;

    wire S_temp1 , c_temp , ctemp2;

    half_adder ha0(.a(a),   
                    .b(b),
                    .S(S_temp1) ,
                    .cout(c_temp)) ;
    half_adder ha1(.a(S_temp1),
                    .b(cin),
                    .S(S),
                    .cout(c_temp2)) ;
        
    or (cout ,c_temp , c_temp2) ;

endmodule 

module rca_Nbit #(parameter N = 32) (a, b, cin, S, cout);
    
    input [N-1:0] a ;
    input [N-1:0] b ;
    input cin ;
    output [N-1:0] S ;
    output cout ;
    wire[N:0] carry ;
    assign carry[0] = cin ;

    generate 
        genvar i;
        for(i = 0 ; i<N ; i = i+1) begin
            full_adder fa0(.a(a[i]) , .b(b[i]) , .cin(carry[i]) , .S(S[i]) , .cout(carry[i+1]) ) ;
        end
    endgenerate

    assign cout = carry[N] ; 

endmodule

module twos_complement #(parameter N=16) (X,X_comp) ; 
    input[N-1:0] X ; 
    output[N-1:0] X_comp ; 
    output [N-1:0] ans ; 
    output carry ;
    generate
        genvar i ;

        for (i=0; i<N ; i=i+1) begin 
            not (ans[i],X[i]) ;
        end 

    endgenerate

    rca_Nbit #(.N(N)) r1 (.a(ans) , .b({N{1'b0}}) , .cin(1'b1) , .S(X_comp)  , .cout(carry) ) ;  

endmodule


module subtractor #(parameter N = 16 ) (a,b,cin,sub) ; 
    input[N-1:0] a , b ;
    input cin ;
    output cout ; // If 1 then we are good else , b>a . 
    output [N-1:0] sub ;

    wire [N-1:0] bComplement ;

    twos_complement #(.N(N)) com(.X(b) , .X_comp(bComplement) ) ;
    rca_Nbit #(.N(N)) Nbit (.a(a) , .b(bComplement) , .cin(1'b0) , .S(sub) , .cout(cout)) ; 

endmodule


module multiplier (a,b,mul) ; 
    input a , b ;
    output mul ; 

    and (mul , a ,b)  ;

endmodule 

module karatsuba_2 #(parameter N = 2) (X, Y, Z); 
    
    input[1:0] X , Y ; 
    output[3:0] Z ;

    wire a , b , c , d ;

    assign a = X[1] ; 
    assign b = X[0] ; 
    assign c = Y[1] ; 
    assign d = Y[0] ; 
    
    wire ac , bd ;
    wire sumab , sumcd , carryab , carrycd ;
    wire sum_ac_bd , carry_ac_bd;
    // ac bd calculated 
    multiplier mone(.a(a) , .b(c) , .mul(ac)) ; 
    multiplier mtwo(.a(b) , .b(d) , .mul(bd)) ;
    
    // a+b 
    rca_Nbit #(.N(N/2)) tempsumone (.a(a) , .b(b) , .cin(1'b0) , .cout(carryab) , .S(sumab)) ;
    // c+d 
    rca_Nbit #(.N(N/2)) tempsumtwo (.a(c) , .b(d) , .cin(1'b0) , .cout(carrycd) , .S(sumcd)) ;

    // ac+bd
    rca_Nbit #(.N(N/2)) tempsumthree (.a(ac) , .b(bd) , .cin(1'b0) , .cout(carry_ac_bd) , .S(sum_ac_bd)) ; 

    wire temp_one , temp_two , temp_three , temp_four ;

    multiplier mthree(.a(sumab) , .b(sumcd) , .mul(temp_one)) ;
    multiplier mfour(.a(carryab) , .b(sumcd) , .mul(temp_two)) ;
    multiplier mfive(.a(carrycd) , .b(sumab) , .mul(temp_three)) ;
    multiplier msix (.a(carryab) , .b(carrycd) , .mul(temp_four)) ;

    output [3:0] ac_pad ;
    output [2:0] ad_bc ;


    wire ctone , cttwo ;    

    rca_Nbit #(.N(2*N-1)) r1 (.a({1'b0,temp_two,temp_one}) , .b({temp_four,temp_three,1'b0}) , .cin(1'b0) , .cout(ctone) , .S(ad_bc)) ;

    output[2:0] t_three ;
    subtractor #(.N(2*N-1)) s1 (.a({ad_bc}) , .b({1'b0,carry_ac_bd,sum_ac_bd}) , .cin(1'b0) , .sub(t_three)) ;

    
    rca_Nbit #(.N(2*N)) r2 (.a({1'b0,ac,2'b00}) , .b({t_three ,1'b0}) , .cin(bd) , .cout(cttwo) , .S(Z)) ;

endmodule

module karatsuba_4 #(parameter N = 4) (X,Y,Z,a,b,c,d) ;
    input [N-1:0] X ,Y ;
    output [2*N-1:0] Z ;

    output [N/2-1:0] a ,b ,c ,d ;

    assign a = X[N-1:N/2] ;
    assign c = Y[N-1:N/2] ;
    assign d = Y[N/2-1:0] ;
    assign b = X[N/2-1:0] ;

    output[N-1:0] ac , bd ;

    karatsuba_2 #(.N(N/2)) kone(.X(a) , .Y(c) , .Z(ac)) ;
    karatsuba_2 #(.N(N/2)) ktwo(.X(b) , .Y(d) , .Z(bd)) ;

    output [N/2-1:0] sumab , sumcd ;
    output [N-1:0] sum_ac_bd ; 
    output carryab , carrycd , carry_ac_bd ; 

    rca_Nbit #(.N(N/2)) tempsumone (.a(a) , .b(b) , .cin(1'b0) , .cout(carryab) , .S(sumab)) ;
    // c+d 
    rca_Nbit #(.N(N/2)) tempsumtwo (.a(c) , .b(d) , .cin(1'b0) , .cout(carrycd) , .S(sumcd)) ;

    // ac+bd
    rca_Nbit #(.N(N)) tempsumthree (.a(ac) , .b(bd) , .cin(1'b0) , .cout(carry_ac_bd) , .S(sum_ac_bd)) ; 

    output[N-1:0] t1 , t2  , t3 ;
    output t4 ;

    karatsuba_2 #(.N(N/2)) kthree(.X(sumab), .Y(sumcd) , .Z(t1)) ; 

    //karatsuba_2 #(.N(N/2)) kfour(.X({1'b0,carryab}), .Y(sumcd) , .Z(t2)) ; 
    // ({N/2-1}(1'b0))
    // karatsuba_2 #(.N(N/2)) kfive(.X(sumab), .Y({1'b0,carrycd}) , .Z(t3) )  ; 
    // karatsuba_2 #(.N(N/2)) ksix(.X({1'b0,carryab}), .Y({1'b0,carrycd}) , .Z(t4) )  ; 
    and and_u0[N-1:0]  (t2 , {4{carryab}} , {2'b00,sumcd}) ;
    and and_u1[N-1:0]  (t3 , {4{carrycd}} , {2'b00,sumab}) ;
    and and_u2  (t4 , {carryab} , {carrycd}) ;
    

    output [2*N-1:0] p1 , p2 , p3 , p4 , p5 ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rone(.a({4'b0000,t1}) , .b({2'b00,t2,2'b00}) , .cin(1'b0)  , .S(p1) , .cout()) ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rtwo(.a({3'b000,t4,4'b0000}) , .b({2'b00,t3,2'b00}) , .cin(1'b0)  , .S(p2) , .cout()) ;

    rca_Nbit #(.N(2*N)) rthree(.a(p1) , .b(p2) , .cin(1'b0) , .S(p3) , .cout()) ;
    // 4'b0000 -> N{1'b0}
    subtractor #(.N(2*N)) rfour(.a(p3) , .b({4'b0000, sum_ac_bd}) , .cin(1'b0) , .sub(p4)) ; 
    // 4'b0000-> N{1'b0}
    // (3*N/2) - 1 : 0 , N/2
    rca_Nbit #(.N(2*N)) rfive(.a({ac,4'b0000}) , .b({p4[5:0],2'b00}), .cin(1'b0) , .cout() , .S(p5)) ;
    // N1'b0
    rca_Nbit #(.N(2*N)) rsix(.a({4'b0000,bd}) , .b(p5), .cin(1'b0) , .cout() , .S(Z)) ;

endmodule

module karatsuba_8 #(parameter N = 8) (X,Y,Z,a,b,c,d) ;
    input [N-1:0] X ,Y ;
    output [2*N-1:0] Z ;

    output [N/2-1:0] a ,b ,c ,d ;

    assign a = X[N-1:N/2] ;
    assign c = Y[N-1:N/2] ;
    assign d = Y[N/2-1:0] ;
    assign b = X[N/2-1:0] ;

    output[N-1:0] ac , bd ;

    karatsuba_4 #(.N(N/2)) kone(.X(a) , .Y(c) , .Z(ac)) ;
    karatsuba_4 #(.N(N/2)) ktwo(.X(b) , .Y(d) , .Z(bd)) ;

    output [N/2-1:0] sumab , sumcd ;
    output [N-1:0] sum_ac_bd ; 
    output carryab , carrycd , carry_ac_bd ; 

    rca_Nbit #(.N(N/2)) tempsumone (.a(a) , .b(b) , .cin(1'b0) , .cout(carryab) , .S(sumab)) ;
    // c+d 
    rca_Nbit #(.N(N/2)) tempsumtwo (.a(c) , .b(d) , .cin(1'b0) , .cout(carrycd) , .S(sumcd)) ;

    // ac+bd
    rca_Nbit #(.N(N)) tempsumthree (.a(ac) , .b(bd) , .cin(1'b0) , .cout(carry_ac_bd) , .S(sum_ac_bd)) ; 

    output[N-1:0] t1 , t2  , t3 ;
    output t4 ;

    karatsuba_4 #(.N(N/2)) kthree(.X(sumab), .Y(sumcd) , .Z(t1)) ; 

    //karatsuba_2 #(.N(N/2)) kfour(.X({1'b0,carryab}), .Y(sumcd) , .Z(t2)) ; 
    // ({N/2-1}(1'b0))
    // karatsuba_2 #(.N(N/2)) kfive(.X(sumab), .Y({1'b0,carrycd}) , .Z(t3) )  ; 
    // karatsuba_2 #(.N(N/2)) ksix(.X({1'b0,carryab}), .Y({1'b0,carrycd}) , .Z(t4) )  ; 
    and and_u0[N-1:0]  (t2 , {8{carryab}} , {4'b0000,sumcd}) ;
    and and_u1[N-1:0]  (t3 , {8{carrycd}} , {4'b0000,sumab}) ;
    and and_u2  (t4 , {carryab} , {carrycd}) ;
    

    output [2*N-1:0] p1 , p2 , p3 , p4 , p5 ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rone(.a({8'b00000000,t1}) , .b({4'b0000,t2,4'b0000}) , .cin(1'b0)  , .S(p1) , .cout()) ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rtwo(.a({7'b0000000,t4,8'b00000000}) , .b({4'b0000,t3,4'b0000}) , .cin(1'b0)  , .S(p2) , .cout()) ;

    rca_Nbit #(.N(2*N)) rthree(.a(p1) , .b(p2) , .cin(1'b0) , .S(p3) , .cout()) ;
    // 8'b0000 -> N{1'b0}
    subtractor #(.N(2*N)) rfour(.a(p3) , .b({8'b00000000, sum_ac_bd}) , .cin(1'b0) , .sub(p4)) ; 
    // 8'b0000-> N{1'b0}
    // (3*N/2) - 1 : 0 , N/2
    rca_Nbit #(.N(2*N)) rfive(.a({ac,8'b00000000}) , .b({p4[11:0],4'b0000}), .cin(1'b0) , .cout() , .S(p5)) ;
    // N1'b0
    rca_Nbit #(.N(2*N)) rsix(.a({8'b00000000,bd}) , .b(p5), .cin(1'b0) , .cout() , .S(Z)) ;

endmodule



module karatsuba_16 #(parameter N = 16) (X,Y,Z,a,b,c,d) ;
    input [N-1:0] X ,Y ;
    output [2*N-1:0] Z ;

    output [N/2-1:0] a ,b ,c ,d ;

    assign a = X[N-1:N/2] ;
    assign c = Y[N-1:N/2] ;
    assign d = Y[N/2-1:0] ;
    assign b = X[N/2-1:0] ;

    output[N-1:0] ac , bd ;

    karatsuba_8 #(.N(N/2)) kone(.X(a) , .Y(c) , .Z(ac)) ;
    karatsuba_8 #(.N(N/2)) ktwo(.X(b) , .Y(d) , .Z(bd)) ;

    output [N/2-1:0] sumab , sumcd ;
    output [N-1:0] sum_ac_bd ; 
    output carryab , carrycd , carry_ac_bd ; 

    rca_Nbit #(.N(N/2)) tempsumone (.a(a) , .b(b) , .cin(1'b0) , .cout(carryab) , .S(sumab)) ;
    // c+d 
    rca_Nbit #(.N(N/2)) tempsumtwo (.a(c) , .b(d) , .cin(1'b0) , .cout(carrycd) , .S(sumcd)) ;

    // ac+bd
    rca_Nbit #(.N(N)) tempsumthree (.a(ac) , .b(bd) , .cin(1'b0) , .cout(carry_ac_bd) , .S(sum_ac_bd)) ; 

    output[N-1:0] t1 , t2  , t3 ;
    output t4 ;

    karatsuba_8 #(.N(N/2)) kthree(.X(sumab), .Y(sumcd) , .Z(t1)) ; 

    //karatsuba_8 #(.N(N/2)) kfour(.X({1'b0,carryab}), .Y(sumcd) , .Z(t2)) ; 
    // ({N/2-1}(1'b0))
    // karatsuba_8 #(.N(N/2)) kfive(.X(sumab), .Y({1'b0,carrycd}) , .Z(t3) )  ; 
    // karatsuba_8 #(.N(N/2)) ksix(.X({1'b0,carryab}), .Y({1'b0,carrycd}) , .Z(t4) )  ; 
    and and_u0[N-1:0]  (t2 , {16{carryab}} , {8'b00000000,sumcd}) ;
    and and_u1[N-1:0]  (t3 , {16{carrycd}} , {8'b00000000,sumab}) ;
    and and_u2  (t4 , {carryab} , {carrycd}) ;
    

    output [2*N-1:0] p1 , p2 , p3 , p4 , p5 ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rone(.a({16'b0000000000000000,t1}) , .b({8'b00000000,t2,8'b00000000}) , .cin(1'b0)  , .S(p1) , .cout()) ;
    // (N){1'b0} , (N/2){1'b0} ,(N/2){1'b0} 
    rca_Nbit #(.N(2*N)) rtwo(.a({15'b000000000000000,t4,16'b0000000000000000}) , .b({8'b00000000,t3,8'b00000000}) , .cin(1'b0)  , .S(p2) , .cout()) ;

    rca_Nbit #(.N(2*N)) rthree(.a(p1) , .b(p2) , .cin(1'b0) , .S(p3) , .cout()) ;
    // 16'b000000000000 -> N{1'b0}
    subtractor #(.N(2*N)) rfour(.a(p3) , .b({16'b0000000000000000, sum_ac_bd}) , .cin(1'b0) , .sub(p4)) ; 
    // 16'b000000000000-> N{1'b0}
    // (3*N/2) - 1 : 0 , N/2
    rca_Nbit #(.N(2*N)) rfive(.a({ac,16'b0000000000000000}) , .b({p4[23:0],8'b00000000}), .cin(1'b0) , .cout() , .S(p5)) ;
    // N1'b0
    rca_Nbit #(.N(2*N)) rsix(.a({16'b0000000000000000,bd}) , .b(p5), .cin(1'b0) , .cout() , .S(Z)) ;

endmodule