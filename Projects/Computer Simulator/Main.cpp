#include <iostream>

struct Byte {
  bool Bits[8];

  Byte() {
    for (int i = 0; i < 8; i++) {
      Bits[i] = false;
    }
  }
};

int main() {

  Byte byte;
  byte.Bits[5] = true;
  for (int i = 0; i < 8; i++) {
    std::cout << byte.Bits[i];
  }
  return 0;
}