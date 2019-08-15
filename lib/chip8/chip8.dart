import 'dart:typed_data';

const SCREEN_WIDTH = 64;
const SCREEN_HEIGHT = 32;
const SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;
const BASE = 0x200;
class Chip8{
  Memory memory;
  int _pc = 0x200;
  int _sp = 0;
  int _idx = 0;

  Uint8List _registers = new Uint8List(16);


  Map<int, void Function(int)> _opCodes;





  
  Chip8(){
    this.memory = new Memory();

     _opCodes = <int, void Function(int)>{
      0x1: _0x1_JUMP,
      
     
    };

  }

  loadRom(Uint8List rom){
   
    print("load");
    for (var i = 0; i < rom.length; i++) {
      this.memory.setMemory(BASE+i, rom[i]);
    }
    
    for(var i = 0; i< this.memory.memory.lengthInBytes; i++){
      print(this.memory.getMemory(i));
    }

  }

  tick(){
    if(_pc > 4096){
      _pc = 0x200;
    }
    var opcode =  memory.memory.getUint8(_pc++) << 8 | memory.memory.getUint8(_pc++);

    final maskedOpcode = opcode << 12;
    print(opcode.toString() +" | "+ maskedOpcode.toString());
    print(_pc);
    if(_opCodes.containsKey(maskedOpcode)){
      _opCodes[maskedOpcode](opcode);
    }
    else {
      print("not implemented");
    }


  }
  _0x1_JUMP(int opcode){
    _pc = _nnn(opcode) -2;
  }

  _nnn(int opcode){
    return opcode & 0x0FFF; // bitmask to get last 3 
  }
}

class Memory {
  ByteData memory;
  VRAM vram = VRAM();
  
  Memory(){
    this.memory = ByteData.view(Uint8List(4096).buffer);
 


  }

  setPixel(Point coord, bool value){
    
    this.vram._setPixel(coord, value);
    print(this.vram);
  }

  get screen{
    return this.vram;
  }

  setMemory(int offset, int data){
    this.memory.setInt8(offset,data);
  }

  getMemory(int pos){
    return this.memory.getUint8(pos);
  }
}

class VRAM {
  List<bool> vram;
  VRAM(){
    this._reset();
  }

  _setPixel(Point coord, bool value){
    this.vram[coord.y*64+coord.x] = value;
  }
  bool getPixel(Point coord){
    return this.vram[coord.y*64+coord.x];
  }
  void _reset(){
    this.vram = List.generate(SCREEN_SIZE, (i)=> false,growable: false);

  }

  
}

class Point{
  int x, y;
  Point({this.x,this.y});
}