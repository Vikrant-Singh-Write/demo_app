import 'package:demo_application/drag_field.dart';
import 'package:flutter/material.dart';

class DragWidgetScreen extends StatefulWidget {
  const DragWidgetScreen({super.key});

  @override
  State<DragWidgetScreen> createState() => _DragWidgetScreenState();
}

class _DragWidgetScreenState extends State<DragWidgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag widget'),
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: const DragField(),
      ),
    );
  }
}
