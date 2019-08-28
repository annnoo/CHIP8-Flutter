import 'dart:collection';

class Stack {
  Queue stackQueue = new Queue<int>();

  int pop(){
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