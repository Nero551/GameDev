#include "Engine/Entity.h"
#include <iostream>

float Addition(float a, float b) { return a + b; }

int main() {
  Entity entity;
  entity.Move();
  bool Running = true;

  // Main Loop
  while (Running) {
    std::cout << "Hello\n";
    std::cout << Addition(5.325f, 2.356) << std::endl;
    Running = false;
  }
  // Running = false;
  return 0;
}
