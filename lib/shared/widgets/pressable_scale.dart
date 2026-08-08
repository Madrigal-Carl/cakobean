import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

/// Wraps [child] with a subtle scale-down while a pointer is pressed down on
/// it. Keeps its own pointer state so an inner [InkWell] still owns the tap
/// and ripple — this only adds tactile feedback on top.
class PressableScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
