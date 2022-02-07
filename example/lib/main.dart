import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:painter/painter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Painter Example',
      home: ExamplePage(),
    );
  }
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({Key? key}) : super(key: key);

  @override
  _ExamplePageState createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  bool _finished = false;
  PainterController _controller = _newController();

  @override
  void initState() {
    super.initState();
  }

  static PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.green;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        IconButton(
          icon: const Icon(Icons.content_copy),
          tooltip: 'New Painting',
          onPressed: () => setState(() {
            _finished = false;
            _controller = _newController();
          }),
        ),
      ];
    } else {
      actions = <Widget>[
        IconButton(
          icon: const Icon(
            Icons.undo,
          ),
          tooltip: 'Undo',
          onPressed: () {
            if (_controller.isEmpty) {
              showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) =>
                      const Text('Nothing to undo'));
            } else {
              _controller.undo();
            }
          },
        ),
        IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _controller.clear),
        IconButton(
          icon: const Icon(Icons.check),
          onPressed: () => _show(_controller.finish(), context),
        ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painter Example'),
        actions: actions,
        bottom: PreferredSize(
          child: DrawBar(controller: _controller),
          preferredSize: Size(MediaQuery.of(context).size.width, 30.0),
        ),
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Painter(_controller),
        ),
      ),
    );
  }

  void _show(PictureDetails picture, BuildContext context) {
    setState(() {
      _finished = true;
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('View your image'),
            ),
            body: Container(
              alignment: Alignment.center,
              child: FutureBuilder<Uint8List>(
                future: picture.toPNG(),
                builder:
                    (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return Image.memory(snapshot.data!);
                      }
                    default:
                      return const FractionallySizedBox(
                        widthFactor: 0.1,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: CircularProgressIndicator(),
                        ),
                        alignment: Alignment.center,
                      );
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class DrawBar extends StatelessWidget {
  const DrawBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final PainterController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Slider(
                value: controller.thickness,
                onChanged: (double value) => setState(() {
                  controller.thickness = value;
                }),
                min: 1.0,
                max: 20.0,
                activeColor: Colors.white,
              );
            },
          ),
        ),
        StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return RotatedBox(
              quarterTurns: controller.eraseMode ? 2 : 0,
              child: IconButton(
                icon: const Icon(Icons.create),
                tooltip:
                    (controller.eraseMode ? 'Disable' : 'Enable') + ' eraser',
                onPressed: () {
                  setState(() {
                    controller.eraseMode = !controller.eraseMode;
                  });
                },
              ),
            );
          },
        ),
        ColorPickerButton(controller: controller, background: false),
        ColorPickerButton(controller: controller, background: true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  const ColorPickerButton({
    Key? key,
    required this.controller,
    required this.background,
  }) : super(key: key);

  final PainterController controller;
  final bool background;

  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_iconData, color: _color),
      tooltip:
          widget.background ? 'Change background color' : 'Change draw color',
      onPressed: _pickColor,
    );
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Pick color'),
            ),
            body: Container(
              alignment: Alignment.center,
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (Color c) => pickerColor = c,
              ),
            ),
          );
        },
      ),
    )
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget.background
      ? widget.controller.backgroundColor
      : widget.controller.drawColor;

  IconData get _iconData =>
      widget.background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    if (widget.background) {
      widget.controller.backgroundColor = color;
    } else {
      widget.controller.drawColor = color;
    }
  }
}
