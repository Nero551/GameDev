#include "Engine/Entity.h"
#include <iostream>
using namespace std;

float Addition(float a, float b) { return a + b; }

int main() {
  Entity entity;
  entity.Move();
  bool Running = true;
  while (Running) {
    cout << Addition(5.325f, 2.356) << endl;
    Running = false;
  }
  // Running = false;
  return 0;
}
