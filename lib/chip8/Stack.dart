import 'dart:collection';

class Stack {
  Queue stackQueue = new Queue<int>();

  int pop(){
    if(this.stackQueue.length == 0) return 0;
    return stackQueue.removeLast();
  }  

  void push(int index){
    if(this.stackQueue.length >= 16){
      return;
    }
    this.stackQueue.addLast(index);
  }

  int sp(){
    return this.stackQueue.length;
  }

}