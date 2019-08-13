import 'dart:typed_data';

const SCREEN_WIDTH = 64;
const SCREEN_HEIGHT = 32;
const SCREEN_SIZE = SCREEN_WIDTH * SCREEN_HEIGHT;
const BASE = 0x200;
class Chip8{
  Memory memory;
  int pc = 0x200;


  
  Chip8(){
    this.memory = new Memory();

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
    this.vram = List.generate(SCREEN_SIZE, (i)=> false,growable: false);
  }

  _setPixel(Point coord, bool value){
    this.vram[coord.y*64+coord.x] = value;
  }
  bool getPixel(Point coord){
    return this.vram[coord.y*64+coord.x];
  }

  
}

class Point{
  int x, y;
  Point({this.x,this.y});
}