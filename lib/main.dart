import 'dart:async';
import 'dart:ui' as prefix0;

import 'package:chip8/BinaryImageDecoder.dart';
import 'package:chip8/chip8/chip8.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Chip8 chip8 = Chip8();
  Image screenImage = new Image.memory(
    BinaryImageDecoder.createImage(
        List.generate(SCREEN_SIZE, (i) => false, growable: false)),
    gaplessPlayback: true,
    filterQuality: FilterQuality.none,
    scale: 0.1,
  );

  Timer _timer;
  @override
  void initState() {
    loadRom();

    super.initState();
  }

  _newTimer([int t = 10]) {
    this?._timer?.cancel();
    this._timer = new Timer.periodic(new Duration(milliseconds: t), (_) {
      setState(() {
        screenImage = new Image.memory(
          BinaryImageDecoder.createImage(this.chip8.memory.vram.vram),
          gaplessPlayback: true,
          filterQuality: FilterQuality.none,
          scale: 0.1,
        );
      });
    });
  }

  loadRom() {
    if (_timer != null) _timer.cancel();
    final data = rootBundle.load('assets/roms/TETRIS.ch8').then((item) {
      var rom = item.buffer.asUint8List();

      this.chip8.loadRom(rom);
      this.chip8.start();
      _timer = new Timer.periodic(new Duration(milliseconds: 10), (_) {
        setState(() {
          screenImage = new Image.memory(
            BinaryImageDecoder.createImage(this.chip8.memory.vram.vram),
            gaplessPlayback: true,
            filterQuality: FilterQuality.none,
            scale: 0.1,
          );
        });
      });
      setState(() {
        screenImage = new Image.memory(
          BinaryImageDecoder.createImage(this.chip8.memory.vram.vram),
          gaplessPlayback: true,
          filterQuality: FilterQuality.none,
          scale: 0.1,
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          screenImage,
          
          Expanded(
              child: GridView.count(
                
                  crossAxisCount: 4,
                  children: List.generate(16, (i) {
                    return new GestureDetector(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey, border: Border.all()),
                        child: Center(child: Text('$i')),
                      ),
                      onTapDown: (_) {
                        this._pressKey(i);
                      },
                      onTapUp: (_) {
                        this._releaseKey(i);
                      },
                    );
                  })))
        ],
      )),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _pressKey(int key) {
    this.chip8.pressKey(key);
  }

  _releaseKey(int key) {
    this.chip8.releaseKey(key);
  }

  _generateButtonList() {
    return Expanded(
        child: GridView.count(
            crossAxisCount: 4,
            children: List.generate(16, (i) {
              return new GestureDetector(
                child: RaisedButton(onPressed: () {}, child: Text("${i}")),
                onTapDown: this._pressKey(i),
                onTapUp: this._releaseKey(i),
              );
            })));
  }
}
