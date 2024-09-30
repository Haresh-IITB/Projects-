#include<bits/stdc++.h>
using namespace std;

int binarySearch(int * arr , int len , int start , int end , int val){
    
    int result ; 
    
    if(len == 0) {
        result = -1 ;
        return result ;
    }
    
    int mid = (start+end)/2 ;
    
    if(arr[mid] == val) {
        result = mid ;
        return result ;
    }
    
    else if (arr[mid]<val) {
        start = mid ;
        int len = len/2 ; 
        return binarySearch(arr,len,start,end,val);
    }
    
    else {
        end = mid ;
        int len = len/2 ; 
        return binarySearch(arr,len,start,end,val);
    }

}

int main(){
    int len = 9 , start = 0 , end = len ;
    int arr[len] = {1,2,3,4,5,6,7,8,9} ;
    for(int i = 0 ; i<15 ; i++) {
        int val = i ;
        cout << i <<" "<< binarySearch(arr,len,start,end,val) << endl ;  
    }
    return 0 ;
}