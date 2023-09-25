import 'package:basics/int_basics.dart';
import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../chart_model.dart';
import 'chart_notification.dart';
import 'chart_segment_data.dart';
import 'chart_segment_helpers.dart';
import 'chart_segment_paint.dart';

const donutDuration = Duration(seconds: 1);

class ChartView extends StatelessWidget {
  final List<Animation> intervals;
  final List<ArcData> segments;
  final Animation<double> animation;

  final int? selectedIndex;
  final double transitionProgress;

  final ValueChanged<int> onSelection;

  final ValueNotifier<ShowTooltip?> tooltipData = ValueNotifier(null);

  ChartView({
    super.key,
    required this.animation,
    required List<AbstractCategory> categories,
    required this.transitionProgress,
    required this.onSelection,
    this.selectedIndex,
  })  : segments = computeArcs(categories),
        intervals = computeArcIntervals(
          anim: animation,
          categories: categories,
        );

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DonutNotification>(
      onNotification: (notification) {
        tooltipData.value = notification is ShowTooltip ? notification : null;
        return false;
      },

      // 차트 크기 조절 - 문제점 있음
      // child: AnimatedBuilder(
      //   animation: animation,
      //   builder: (context, _) => Transform.scale(
      //   scale: 0.8, // 원하는 크기로 조절할 수 있는 scale 값을 설정
      //   child: Stack( 

      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => FittedBox(
          fit: BoxFit.fill , //차트 크기 조절시 수정해 볼 수 있는 코드: BoxFit.contain 
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              ...enumerate(segments).map(
                (segment) {
                  final opacity = segment.index == selectedIndex
                      ? 0.0
                      : 1 - transitionProgress;
                  return Opacity(
                    opacity: opacity,
                    child: DonutSegment(
                      key: const Key('donut'),
                      data: segment.value,
                      progress: intervals[segment.index].value,
                      transitionProgress:
                          segment.index == selectedIndex ? 1 : 0,
                      onSelection: () => onSelection(segment.index),
                    ),
                  );
                },
              ).toList(),
              // si une category est sélectionnée
              // on n'affiche que le segment sélectionné
              if (selectedIndex != null) //
                DonutSegment(
                  key: const Key('donut-solo'),
                  data: segments.length > selectedIndex!
                      ? segments[selectedIndex!]
                      : segments.first,
                  transitionProgress: transitionProgress,
                  progress: intervals.length > selectedIndex!
                      ? intervals[selectedIndex!].value
                      : intervals.first.value,
                  onSelection: () {},
                ),
              ValueListenableBuilder<ShowTooltip?>(
                valueListenable: tooltipData,
                builder: (context, value, _) => value != null && !value.isEmpty
                    ? _SegmentTooltip(key: ValueKey(value), value)
                    : const SizedBox.shrink(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentTooltip extends StatelessWidget {
  final ShowTooltip _data;

  String get title => _data.title;

  String get subtitle => _data.subtitle;

  Color get color => _data.color;

  Offset get position => _data.position;

  const _SegmentTooltip(this._data, {super.key});

  @override
  Widget build(BuildContext context) => Positioned(
        left: position.dx - 40,
        top: position.dy - 52,
        child: IgnorePointer(
          ignoring: true,
          child: AnimatedContainer(
            duration: 300.milliseconds,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HSLColor.fromColor(color)
                        .withLightness(.45)
                        .withSaturation(.3)
                        .toColor(),
                    HSLColor.fromColor(color)
                        .withLightness(.3)
                        .withSaturation(.3)
                        .toColor(),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: const [
                  BoxShadow( //각 차트 section클릭시 잠깐 뜨는 Box color
                      blurRadius: 2, spreadRadius: 0.2, color: Color.fromARGB(115, 49, 170, 144))
                ],
                borderRadius: BorderRadius.circular(6)),
            padding: const EdgeInsets.all(8),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan( //각 차트 section클릭시 잠깐 뜨는 감정이름 color 및 값 color
                    text: '$title\n',
                    style: const TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: subtitle,
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
