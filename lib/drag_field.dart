import 'package:flutter/material.dart';

import 'drag_object.dart';

class DragField extends StatefulWidget {
  const DragField({super.key});
  @override
  State<DragField> createState() => _DragFieldState();
}

class _DragFieldState extends State<DragField> {
  final Map<GlobalKey, (ValueNotifier<Offset>, Widget)> _field = {};

  @override
  void initState() {
    super.initState();
    _field.addAll({
      GlobalKey(): (ValueNotifier(Offset.zero), _container(Colors.red)),
      GlobalKey(): (
        ValueNotifier(const Offset(110, 0)),
        _container(Colors.black)
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _field.entries
          .map((dragObject) => _buildDragObject(
              dragObject.key, dragObject.value.$1, dragObject.value.$2))
          .toList(),
    );
  }

  Widget _buildDragObject(
    GlobalKey gKey,
    ValueNotifier<Offset> position,
    Widget child,
  ) {
    return ValueListenableBuilder(
      valueListenable: position,
      builder: (BuildContext context, value, Widget? child) => Positioned(
        left: value.dx,
        top: value.dy,
        child: DragObject(
          key: gKey,
          positionUpdate: (pos) {
            var overlapsWith = _doesOverlapWithOtherObject(gKey, pos);
            if (overlapsWith != null) {
              var delta = pos - position.value;
              moveOtherObject(overlapsWith, delta);
            } else {
              position.value = pos;
            }
          },
          child: child!,
        ),
      ),
      child: child,
    );
  }

  GlobalKey? _doesOverlapWithOtherObject(GlobalKey key, Offset newPostion) {
    var fieldRenderBox = context.findRenderObject() as RenderBox;
    Rect getOtherBoundary(GlobalKey key) {
      return RenderBoxLayout(
              key.currentContext!.findRenderObject() as RenderBox)
          .boundary(fieldRenderBox);
    }

    var movingObjectBoundary =
        RenderBoxLayout(key.currentContext!.findRenderObject() as RenderBox)
            .boundaryForPosition(newPostion);
    List<GlobalKey> otherObjectBoundaries = [];
    for (var element in _field.entries) {
      if (element.key == key) continue;
      otherObjectBoundaries.add(element.key);
    }
    var doesOverlap = otherObjectBoundaries.findWhere(
        (other) => checkOverlap(getOtherBoundary(other), movingObjectBoundary));
    return doesOverlap;
  }

  bool checkOverlap(Rect a, Rect b) {
    final collide = (a.left < b.left + b.width &&
        a.left + a.width > b.left &&
        a.top < b.top + b.height &&
        a.top + a.height > b.top);

    return collide;
  }

  void moveOtherObject(GlobalKey key, Offset delta) {
    var state = key.currentState as DragObjectState;

    var otherPosition =
        RenderBoxLayout(key.currentContext!.findRenderObject() as RenderBox)
            .position();
    state.overheadOffset = Offset.zero;
    state.move(key.currentContext!, otherPosition + delta);
    state.overheadOffset = null;
  }

  Widget _container(Color color) {
    var widget = Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
    return widget;
    // var dragObjectKey = GlobalKey();
    // return (dragObjectKey, widget);
  }
}

extension ReplaceListElement<E> on List<E> {
  E? findWhere(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
