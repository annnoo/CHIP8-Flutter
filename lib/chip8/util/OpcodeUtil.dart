class OpcodeUtil {
  
  static int N(int opcode) {
    return opcode & 0x000F;
  }

  static NN(int opcode) {
    return opcode & 0x00FF;
  }

  static NNN(int opcode){
    return opcode & 0x0FFF; // bitmask to get last 3
  }

  static X(int opcode){
    return opcode & 0x0F00 >> 8;
  }

  static Y(int opcode) {
    return opcode & 0x00F0 >> 4;
  }

  static START(int opcode){
    return opcode >> 12;

  }

  


}