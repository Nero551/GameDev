#include<iostream> 
using namespace std;

void insert(int arr[], int n){
    for (int i =0; i < n; i++){
        int key = arr[i];
        int j = i -1;
        while (j >= 0 && arr[j] > key) {
            arr[j+1] = arr[j];
            j--;
        }
        arr[j+1] = key;
    }
}

void print(int arr[], int n)
{
    for (int i = 0; i < n; i++)
    {
        cout << arr[i] << " ";
    }
    cout << endl;
}
int main()
{
    int arr[] = {2, 5, 1, 8, 27, 175};
    int n = sizeof(arr) / sizeof(arr[0]);
    print(arr, n);
    insert(arr,n);
    print(arr, n);
}