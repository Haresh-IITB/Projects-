#include<iostream>
using namespace std ;

// Declare 3 static 2D array  , type double (A,B,C)
// use #define for size 
// A = 0 ; B = 2*I ; C = first row 0 , 1 .... size - 1 and rest rows = 0 
// A[i][j] += B[i][k]*C[k][j]

#define SIZE 500


int main(){
    // Declaring A ,B , C 
    double A[SIZE][SIZE] ; 
    double B[SIZE][SIZE] ; 
    double C[SIZE][SIZE] ;
    double D[SIZE][SIZE] ; 

    // Now Initialise A , B ,C  
    for(int i = 0 ; i<SIZE ; i++){
        for(int j = 0 ; j<SIZE ; j++){
            A[i][j] = 0 ; 
            if(i == j) B[i][j] = 2 ;
            else B[i][j] = 0 ;
            if(i == 0) C[i][j] = j ; 
            else C[i][j] = 0 ;
        }
    } 

    // Making D = C transpose 
    for(int i = 0 ; i<SIZE ; i++){
        for (int j = 0 ; j<SIZE ; j++) D[j][i] = C[i][j] ;  
    }

    // A = B*C 
    // D = (CT)
    // DT = C 
    // A = B*DT 
    // Using the fact that C is n*n matrix

    // Now multiplying 
    for(int i = 0 ; i<SIZE ; i++) {
        for(int j = 0 ; j<SIZE ; j++){
            for(int k = 0 ; k<SIZE ; k++){
                A[i][j] += B[i][k]*D[j][k] ; 
            }
        }
    }

    return 0 ; 
}