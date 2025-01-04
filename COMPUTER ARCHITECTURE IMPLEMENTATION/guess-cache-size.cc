#include <iostream>
#include <chrono> // Include the chrono library
// #include <cstdlib> // Include cstdlib for rand() and srand()
#include <ctime> // Include ctime for time()

using namespace std;

double measure_time(int guess_size) {
    const int arr_size = 64 * 1024 * 1024;
    char* arr = new char[arr_size];
    for (int i = 0; i < arr_size; i++) arr[i] = 'a';
    double total_elapsed_time = 0 ;
    // Access the array using random indices
    for(int j = 0 ; j<5 ; j++){
        auto start_time = chrono::high_resolution_clock::now(); // Start timing
        for (int i = 0; i < arr_size; i++) {
            int index = (97*i)% guess_size; // Generate a random index using rand()
            arr[index] = arr[index] + 1;
        }
        auto stop_time = chrono::high_resolution_clock::now(); // Stop timing
        double elapsed_time = chrono::duration<double, micro>(stop_time - start_time).count();
        total_elapsed_time += elapsed_time ; 
    }


    // Calculate elapsed time in microseconds

    delete[] arr;

    return total_elapsed_time/5.0;
}

int main() {
    // srand(static_cast<unsigned>(time(nullptr)));
    const int arr_size = 64 * 1024 * 1024;

    double last_time = 0;
    // Chek start from 128 kb
    for (int guess_size = 1024*128; guess_size <= arr_size; guess_size *= 2) {
        double avg_time = measure_time(guess_size);
        cout << "Guess Size: " << guess_size / 1024 << "kB | Average Access Time: " << avg_time << " microseconds" << endl;
        last_time = avg_time; // Update the last time for comparison
    }

    return 0;
}
