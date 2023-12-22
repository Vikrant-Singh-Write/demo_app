import 'package:flutter/material.dart';

class DragObject extends StatefulWidget {
  final Widget child;
  final void Function(Offset position) positionUpdate;
  const DragObject(
      {super.key, required this.child, required this.positionUpdate});

  @override
  State<DragObject> createState() => DragObjectState();
}

class DragObjectState extends State<DragObject> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanDown: (details) {
          overheadOffset = details.localPosition;
        },
        onPanEnd: (details) {
          overheadOffset = null;
        },
        onPanUpdate: (_) => move(context, _.globalPosition),
        child: widget.child);
  }

  Offset? overheadOffset;

  RenderBoxLayout? _parentRenderBoxLayout<T extends RenderBox>(
      BuildContext context) {
    var renderBox = context.findAncestorRenderObjectOfType<T>();
    return renderBox == null ? null : RenderBoxLayout(renderBox);
  }

  Offset _globalToParent(Offset object, Offset? parent) {
    return parent == null ? object : object - parent;
  }

  void move(BuildContext context, Offset globalPosition) {
    if (!_doesOverLapWithParentBoundary(context, globalPosition)) {
      _update(globalPosition);
    }
  }

  bool _doesOverLapWithParentBoundary(
      BuildContext context, Offset globalPosition) {
    var boundary = _parentRenderBoxLayout(context)?.boundary();
    var objectBoundary = _findObjectBoundary(context, globalPosition);
    if (objectBoundary == null || boundary == null) {
      return true;
    }
    var result = boundary.intersect(objectBoundary);
    return result != objectBoundary;
  }

  void _update(Offset globalPosition) {
    var objectPosition = _objectPostion(globalPosition);
    if (objectPosition != null) {
      var newPosition = _globalToParent(
          objectPosition, _parentRenderBoxLayout(context)?.position());
      widget.positionUpdate(newPosition);
    }
  }

  Offset? _objectPostion(Offset globalPosition) {
    if (overheadOffset == null) {
      return null;
    } else {
      return globalPosition - overheadOffset!;
    }
  }

  RenderBoxLayout _objectRenderBoxLayout(BuildContext context) {
    var renderBox = context.findRenderObject() as RenderBox;
    return RenderBoxLayout(renderBox);
  }

  Rect? _findObjectBoundary(BuildContext context, Offset globalPosition) {
    var layout = _objectRenderBoxLayout(context);
    var position = _objectPostion(globalPosition);
    return (position != null) ? layout.boundaryForPosition(position) : null;
  }
}

class RenderBoxLayout {
  final RenderBox renderBox;
  const RenderBoxLayout(this.renderBox);
  Size get size => renderBox.size;
  Offset position([RenderBox? parent]) =>
      renderBox.localToGlobal(Offset.zero, ancestor: parent);
  Rect boundary([RenderBox? parent]) => boundaryForPosition(position(parent));
  Rect boundaryForPosition(Offset position) =>
      Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
}
