#include <iostream>

/*
In this exercise, we will implement heap as discussed in the class.
We need to implement the following functions.


ONLY THIS FILE MUST BE MODIFIED FOR SUBMISSION

You may edit main.cpp for writing more test cases.
But your code must continue to work with the original main.cpp


THERE IS ONLY ONE TEST CASE ONLY FOR YOUR UNDERSTANDING.

-- You may need to generate more random tests to get your tests right
-- Print will not work until you have a good printing function
*/


#include "heap.h"


int Heap::parent(int i) {
  int res = (i-1)/2 >= 0 ? (i-1)/2 : -1 ; 
  return res ; // dummy return
}

int Heap::left(int i) {
  int res = (2*i+1 >= int(sz)) ? -1 : (2*i+1) ; 
  return res; // dummy return
}

int Heap::right(int i) {
  int res = (2*i+2 >= int(sz))? -1 : (2*i+2) ; 
  return res; //dummy
}

int Heap::max() {
  if(sz == 0) return -1 ;
  return store[0] ; //dummy
}

void Heap::swap(int i, int j) {
  if(i<0 || j<0) return ;
  int temp = store[j] ;
  store[j] = store[i] ;
  store[i] = temp ; 
  swap_count++ ;
}

void Heap::insert(int v) {
  Heap::append(v) ;
  int index = sz-1 , parent_This = parent(index) ;   
  while(parent_This >= 0 && store[parent_This] < store[index]) {
    swap(parent_This,index) ;
    index = parent_This ;
    parent_This = parent(index) ; 
  }

  // Dummy return 
  return ; 
} 

void Heap::heapify(int i) {
  int parent = i , leftChild = left(parent) , rightChild = right(parent) ; 
  
  // Base Cases of recursion
  // In this case it is already heapified

  // The heapify is completed 
  if(parent < 0) return ;
  
  if(leftChild == -1) return ; 

  // In this case consider only leftChild for Heapification , Also We know in an heap we need to fill a height first then move onto the next hegiht so this could be only possible when (2*i+1) is leaf 
  if(rightChild == -1) {
    if(store[i] < store[leftChild]) swap(i,leftChild) ; 
    return ; 
  }

  // Now the actual heapify ;-p

 int maxIndex = (store[rightChild] > store[parent] && store[rightChild] > store[leftChild]) ? rightChild :
                 (store[leftChild] > store[parent] && store[leftChild] > store[rightChild]) ? leftChild : 
                 parent ;  
  
  if(maxIndex == parent) return ;

  swap(parent , maxIndex);

  // Tail recursion 
  heapify(maxIndex) ; 

}

void Heap::deleteMax() {
  if(sz<=0) return ;
  swap(0 , sz-1) ;
  sz -- ;
  heapify(0) ; 
}

void Heap::buildHeap() {
  // The given vector is T , we need to make heap of this , so heapify from last
  for(int i = sz-1 ; i>=0 ; i--) heapify(i) ; 
}

void Heap::heapSort() {
  // First Building the Heap 
  buildHeap() ;
  const int size = sz ;
  for(int i = 0 ; i<size ; i++) { 
    deleteMax() ;
  }
  sz = size ;
}


