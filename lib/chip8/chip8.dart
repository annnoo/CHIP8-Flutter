import 'dart:math';
import 'dart:typed_data';

import 'package:chip8/chip8/util/OpcodeUtil.dart';

import 'Stack.dart';

const SCREEN_WIDTH = 64;
const SCREEN_HEIGHT = 32;
const SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;
const BASE = 0x200;

typedef OPCODE_FUNTION = Function(int);

class Chip8 {
  Memory memory;
  int _pc = 0x200;
  int _idx = 0;
  Stack _stack;

  Uint8List _V = new Uint8List(16); //Registers
  final _rand = new Random();
  Map<int, void Function(int)> _opCodes;
  Map<int, void Function(int)> _EtcOpCodes;
  Set<int> _keys = new Set<int>();

  Chip8() {
    this.memory = new Memory();

    _opCodes = <int, OPCODE_FUNTION>{
      0x0: _0x0_CLEAR_OR_RETURN,
      0x1: _0x1_JUMP,
      0x00E0: _0x00E0_CLEAR,
      0x2: _0X2_CALL_SUBROUTINE,
      0x3: _0x3_SKIP_IF_NN,
      0x4: _0x4_SKIP_IF_NN,
      0x5: _0x5_SKIP_IF_XY,
      0x6: _0x6_SET_X_TO_NN,
      0x7: _0x7_ADD_NN_TO_X,
      0xD: _0xD_DRAW_SPRITE,
      0xE: _0xE_KEY_SKIP,
      0xF: _0xF_ETC,
    };

    _EtcOpCodes = <int, OPCODE_FUNTION>{
      0x07: _0xFX07_SET_DELAY_TO_X,
      0x0A: _0xFX0A_WAIT_FOR_KEY,
      0x15: _0xFX15,
      0x18: _0xFX18,
      0x1E: _0xFX1E_ADD_X_TO_I,
      0x29: _0xFX29_SET_I_SPRITE,
      0x33: _0xFX33,
      0x55: _0xFX55_STORE_MEMORY,
      0x65: _0xFX65_FILL_V,
    };
    print(_opCodes.keys.toString());
  }
  _0xFX07_SET_DELAY_TO_X(int opcode) {}

  _0xFX0A_WAIT_FOR_KEY(int opcode) {
    int x = OpcodeUtil.X(opcode);
    if(this._keys.length != 0){
      this._V[x] = _keys.first;
    }
    else {
      // Jump back 
      this._pc -=2;
    }
  }
  _0xFX15(int opcode) {}
  _0xFX18(int opcode) {}
  _0xFX33(int opcode) {}

  _0x0_CLEAR_OR_RETURN(int opcode) {
    int nn = OpcodeUtil.NN(opcode);
    if (nn == 0xE0) {
      this._0x00E0_CLEAR(opcode);
    } else if (nn == 0xEE) {
      this._stack.pop();
    }
  }

  loadRom(Uint8List rom) {
    print("load");
    for (var i = 0; i < rom.length; i++) {
      this.memory.setMemory(BASE + i, rom[i]);
    }

    for (var i = 0; i < this.memory.memory.lengthInBytes; i++) {
      print(this.memory.getMemory(i));
    }
  }

_printV(){
  var str = "";
  

  for (var i = 0; i < this._V.length; i++) {
    str+= i.toString();
    str += ":";
    str+=this._V[i].toRadixString(16);
    str+=" | ";


  }
  print(str);
}
  tick() {

    this._printV();

    if (_pc >= 4096) {
      _pc = 0x200;
    }
    var opcode =
        memory.memory.getUint8(_pc++) << 8 | memory.memory.getUint8(_pc++);

    final maskedOpcode = OpcodeUtil.START(opcode);
    print(opcode.toRadixString(16) + " | " + maskedOpcode.toRadixString(16));
    print(_pc);
    if (_opCodes.containsKey(maskedOpcode)) {
      _opCodes[maskedOpcode](opcode);
    } else {
      print("not implemented");
    }
  }

  _0x1_JUMP(int opcode) {
    _pc = OpcodeUtil.NNN(opcode) - 2;
  }

  _0x00E0_CLEAR(int opcode) {
    this.memory.vram.reset();
  }

  _0x00EE_RETURN(int opcode) {
    this._pc = this._stack.pop();
  }

  _0X2_CALL_SUBROUTINE(int opcode) {
    this._stack.push(this._pc);
    this._pc = OpcodeUtil.NNN(opcode);
  }

  _0x3_SKIP_IF_NN(int opcode) {
    if (this._V[OpcodeUtil.X(opcode)] == OpcodeUtil.NN(opcode)) {
      //Skip next instruction
      this._pc += 2;
    }
  }

  _0x4_SKIP_IF_NN(int opcode) {
    if (this._V[OpcodeUtil.X(opcode)] != OpcodeUtil.NN(opcode)) {
      //Skip next instruction
      this._pc += 2;
    }
  }

  _0x5_SKIP_IF_XY(int opcode) {
    if (this._V[OpcodeUtil.X(opcode)] == this._V[OpcodeUtil.Y(opcode)]) {
      //Skip next instruction
      this._pc += 2;
    }
  }

  _0x6_SET_X_TO_NN(int opcode) {
    this._V[OpcodeUtil.X(opcode)] = OpcodeUtil.NN(opcode);
  }

  _0x7_ADD_NN_TO_X(int opcode) {
    this._V[OpcodeUtil.X(opcode)] += OpcodeUtil.NN(opcode);
  }

  _0x8XY0_SET_X_TO_Y(int opcode) {
    this._V[OpcodeUtil.X(opcode)] = this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY1_SET_X_TO_OR_Y(int opcode) {
    this._V[OpcodeUtil.X(opcode)] |= this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY2_SET_X_TO_AND_Y(int opcode) {
    this._V[OpcodeUtil.X(opcode)] &= this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY3_SET_X_TO_XOR_Y(int opcode) {
    this._V[OpcodeUtil.X(opcode)] ^= this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY4_ADD_X_TO_Y_CARRY(int opcode) {
    int sum = this._V[OpcodeUtil.X(opcode)] + this._V[OpcodeUtil.Y(opcode)];
    // Sum bigger than 0xFF (256) --> Carry
    if (sum > 0xFF) {
      this._V[0xF] = 1;
    } else {
      this._V[0xF] = 0;
    }
    this._V[OpcodeUtil.X(opcode)] += this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY5_SUB_Y_FROM_X_CARRY(int opcode) {
    // Sum bigger than 0xFF (256) --> Carry
    if (this._V[OpcodeUtil.X(opcode)] > this._V[OpcodeUtil.Y(opcode)]) {
      this._V[0xF] = 1;
    } else {
      this._V[0xF] = 0;
    }

    this._V[OpcodeUtil.X(opcode)] -= this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XY6_SHIFTR_X_CARRY(int opcode) {
    // Bitmask for last bit
    if (this._V[OpcodeUtil.X(opcode)] & 0x01 != 0) {
      this._V[0xF] = 1;
    } else {
      this._V[0xF] = 0;
    }

    this._V[OpcodeUtil.X(opcode)] = this._V[OpcodeUtil.X(opcode)] >> 1;
  }

  _0x8XY7_SET_X_TO_Y_MINUS_X_CARRY(int opcode) {
    // Bitmask for last bit
    if (this._V[OpcodeUtil.X(opcode)] < this._V[OpcodeUtil.Y(opcode)]) {
      this._V[0xF] = 1;
    } else {
      this._V[0xF] = 0;
    }

    this._V[OpcodeUtil.X(opcode)] =
        this._V[OpcodeUtil.X(opcode)] - this._V[OpcodeUtil.Y(opcode)];
  }

  _0x8XYE_SHIFTL_X_CARRY(int opcode) {
    // Bitmask for checking first bits
    if (this._V[OpcodeUtil.X(opcode)] & 0xF != 0) {
      this._V[0xF] = 1;
    } else {
      this._V[0xF] = 0;
    }

    this._V[OpcodeUtil.X(opcode)] = this._V[OpcodeUtil.X(opcode)] << 1;
  }

  _0xA_SET_I_(int opcode) {
    this._idx = OpcodeUtil.NNN(opcode);
  }

  _0xB_JUMP_TO_NNN_PLUS_V0(int opcode) {
    this._pc = OpcodeUtil.NNN(opcode) + this._V[0];
  }

  _0xD_DRAW_SPRITE(int opcode) {
    int width = 8;
    int height = OpcodeUtil.N(opcode);

    int Vx = this._V[OpcodeUtil.X(opcode)];
    int Vy = this._V[OpcodeUtil.Y(opcode)];

    this._V[0xF] = 0;
    for (int i = 0; i < height; i++) {
      int sprite = this.memory.getMemory(this._idx + i);
      for (int j = 0; j < width; j++) {
        Point coord =
            Point(x: (Vx + j) % SCREEN_WIDTH, y: (Vy + i) % SCREEN_HEIGHT);
        bool currentPixel = this.memory.vram.getPixel(coord);
//buggy, delete
          this.memory.setPixel(coord, true);

        if (sprite & (0x80 >> j) != 0) {
          this.memory.setPixel(coord, true);
          if (currentPixel) {
            this._V[0xF] = 1;
          }
        }
      }
    }

    this.memory.vram.vram.forEach((i) {
      if (i) print(i);
    });
  }

  _0xC_SET_X_RANDOM(int opcode) {
    this._V[OpcodeUtil.N(opcode)] =
        this._rand.nextInt(256) & OpcodeUtil.NN(opcode);
  }

  _0xEX9E_SKIP_IF_KEY_PRESSED(int opcode) {
    int x = OpcodeUtil.X(opcode);

    if (this._keys.contains(this._V[x])) this._pc += 2;
  }

  _0xEXA1_SKIP_IF_KEY_NOT_PRESSED(int opcode) {
    int x = OpcodeUtil.X(opcode);

    if (!this._keys.contains(this._V[x])) this._pc += 2;
  }

  _0xE_KEY_SKIP(int opcode) {
    int nn = OpcodeUtil.NN(opcode);
    if (nn == 0x9e) {
      _0xEX9E_SKIP_IF_KEY_PRESSED(opcode);
    } else if (nn == 0xA1) {
      _0xEXA1_SKIP_IF_KEY_NOT_PRESSED(opcode);
    }
  }

  _0xF_ETC(int opcode) {
    int nn = OpcodeUtil.NN(opcode);
    if (this._EtcOpCodes.containsKey(nn)) {
      this._EtcOpCodes[nn](opcode);
    } else {
      print("F Not Implemented");
    }
  }

  _0xFX1E_ADD_X_TO_I(int opcode) {
    this._idx = this._V[OpcodeUtil.X(opcode)];
  }

  _0xFX29_SET_I_SPRITE(int opcode) {
    int x = OpcodeUtil.X(opcode);
    this._idx = this._V[x] * 5;
  }

  _0xFX55_STORE_MEMORY(int opcode) {
    int x = OpcodeUtil.X(opcode);
    for (int i = 0; i < x; i++) {
      this.memory.setMemory(this._idx + i, this._V[i]);
    }
  }

  _0xFX65_FILL_V(int opcode) {
    int x = OpcodeUtil.X(opcode);
    for (int i = 0; i < x; i++) {
      this._V[i] = this.memory.getMemory(_idx + i);
    }
  }
}

class Memory {
  ByteData memory;
  VRAM vram = VRAM();

  Memory() {
    this.memory = ByteData.view(Uint8List(4096).buffer);
  }

  setPixel(Point coord, bool value) {
    this.vram.setPixel(coord, value);
    print(this.vram);
  }

  get screen {
    return this.vram;
  }

  setMemory(int offset, int data) {
    this.memory.setInt8(offset, data);
  }

  getMemory(int pos) {
    return this.memory.getUint8(pos);
  }
}

class VRAM {
  List<bool> vram;
  VRAM() {
    this.reset();
  }

  setPixel(Point coord, bool value) {
    this.vram[coord.y * 64 + coord.x] = value;
  }

  bool getPixel(Point coord) {
    return this.vram[coord.y * 64 + coord.x];
  }

  void reset() {
    this.vram = List.generate(SCREEN_SIZE, (i) => false, growable: false);
  }
}

class Point {
  int x, y;
  Point({this.x, this.y});
}
