import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fx_helper/extensions/num_extensions.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

/// Create a countdown widget
///
/// examples:
/// ```
///     CountdownWidget(
///       endTime: DateTime.now().add(Duration(seconds: 30)),
///       onEnded: () {
///         SnackbarHelper.showSnackBar(
///           SnackbarState.warning,
///           "UI Update",
///         );
///       },
///     ),
/// ```

class CountdownWidget extends StatefulWidget {
  final DateTime? endTime;
  final void Function()? onEnded;
  final Widget Function(String timeStr, bool isEnded)? builder;

  const CountdownWidget({super.key, required this.endTime, this.onEnded, this.builder});

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  Timer? timer;
  late String timeStr = "00:00:00";
  bool isEnded = false;
  DateTime? lastEndTime;

  void _initTime() {
    isEnded = false;
    Duration d = DateTime.now().difference(widget.endTime ?? DateTime.now());
    if (d.isNegative) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        Duration d = DateTime.now().difference(widget.endTime ?? DateTime.now());
        print(d);
        if (d.isNegative) {
          timeStr = DateTime.now().timeUntil(until: widget.endTime);
        } else {
          isEnded = true;
          timeStr = "ended";
          if (widget.onEnded != null) {
            widget.onEnded!();
          }
          setState(() {});
          timer.cancel();
        }
        setState(() {});
      });
    } else {
      isEnded = true;
      timeStr = "ended";
    }
  }

  @override
  void didUpdateWidget(covariant CountdownWidget oldWidget) {
    if (lastEndTime != widget.endTime) {
      _initTime();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    lastEndTime = widget.endTime;
    _initTime();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("build( isEnded: $isEnded | timeStr: $timeStr | timer: ${timer?.isActive})");
    if (widget.builder != null) {
      return widget.builder!(timeStr, isEnded);
    }
    return Text(
      timeStr,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
      style: textStyleTiny(context).copyWith(color: Colors.black, fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    print("disposed");
    timer?.cancel();

    super.dispose();
  }
}
