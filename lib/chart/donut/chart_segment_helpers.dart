import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:quiver/iterables.dart';

import '../chart_model.dart';
import 'chart_segment_data.dart';

// 하위 값들 표시 코드

List<ArcData> computeArcs(List<AbstractCategory> categories) =>
    enumerate(categories).fold<List<ArcData>>(
      <ArcData>[],
      (previousValue, category) {
        final elementSweepAngle = //차트의 각 섹션 각도 계산
            category.value.total /
                categories.total *
                2 *
                math.pi; // 차트의 현재 섹션의 데이터 합계(category.value.total, 해당 섹션의 크기를 나타냄) / 모든 섹션의 데이터 합계(categories.total, 전체 파이차트의 크기 나타냄)
        // * 2 * math.pi : 파이는 180도 임으로, * 2 * math.pi는 360도를 나타냄
        if (previousValue.isEmpty) {
          return [
            ArcData(
              //위의 elementSweepAngle을 이용하여 각 섹션의 ArcData를 생성
              title: category.value.title,
              subtitle:
                  '${category.value.total.toStringAsFixed(2)}%', //기차트에서 가장큰 순 비율 섹션 단위 표현 (2nd) (1st)
              startAngle: -math.pi /
                  2, //이때, startAngle은 이전 섹션의 끝 각도에 elementSweepAngle을 더한 값으로 설정되어 파이 차트의 섹션들이 연속되게 배치됨.
              sweepAngle: elementSweepAngle,
              color: category.value.color,
            )
          ];
        }

        final previousElement = previousValue.last;
        return previousValue
          ..add(
            ArcData(
              title: category.value.title,
              subtitle:
                  '${category.value.total.toStringAsFixed(2)}%', //차트에서 가장큰 비율 제외한 나머지 비율 섹션 일괄 단위 표현 (2nd, 3nd, 4th)
              startAngle:
                  previousElement.startAngle + previousElement.sweepAngle,
              sweepAngle: elementSweepAngle,
              color: category.value.color,
            ),
          );
      },
    );

// List<SegmentData> computeSegments(List<AbstractCategory> categories) =>
//     enumerate(categories).fold<List<SegmentData>>(
//       <SegmentData>[],
//       (previousValue, category) {
//         final elementWidth =
//             FractionalOffset(category.value.total / categories.total, 0);

//         if (previousValue.isEmpty) {
//           return [
//             SegmentData(
//               title: category.value.title,
//               subtitle: '${category.value.total.toStringAsFixed(2)}%',// 찾아봐야함.
//               start: const FractionalOffset(0, 0),
//               width: elementWidth,
//               color: category.value.color,
//             )
//           ];
//         }

//         final previousElement = previousValue.last;
//         return previousValue
//           ..add(
//             SegmentData(
//               title: category.value.title,
//               subtitle: '${category.value.total.toStringAsFixed(2)}%',//찾아봐야함.
//               start: FractionalOffset(
//                 previousElement.start.dx + previousElement.width.dx,
//                 0,
//               ),
//               width: elementWidth,
//               color: category.value.color,
//             ),
//           );
//       },
//     );

List<Animation> computeArcIntervals({
  required Animation<double> anim,
  required List<AbstractCategory> categories,
}) {
  final intervalValues = <List<double>>[];
  final intervals = <Animation>[];

  for (final category in enumerate(categories)) {
    if (category.index == 0) {
      final end = category.value.total / categories.total;
      final interval = CurvedAnimation(parent: anim, curve: Interval(0, end));
      intervals.add(interval);
      intervalValues.add([0, end]);
      continue;
    }

    final end = category.value.total / categories.total;
    final previousInterval = intervalValues.last;
    final newEnd = (previousInterval.last + end) > 1.0
        ? 1.0
        : (previousInterval.last + end);
    final interval = CurvedAnimation(
      parent: anim,
      curve: Interval(previousInterval.last, newEnd),
    );
    intervals.add(interval);
    intervalValues.add([previousInterval.last, newEnd]);
  }

  return intervals;
}
