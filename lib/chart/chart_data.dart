import 'package:flutter/material.dart';

import 'chart_model.dart';

final categories = [
  Category(
    title: "기쁨", //기쁨 1
    color: Color.fromARGB(255, 248, 234, 110),
    subCategories: [
      SubCategory(
          title: '기쁨',
          operations: [40], // 다 더한 값이 나옴  특징: 숫자를 몇개를 넣던 다 더해줌
          color: Color.fromARGB(255, 247, 231, 87)),
    ],
  ),
  Category(
    title: "기대",// 기대 2
    color: Color.fromARGB(255, 73, 178, 223),
    subCategories: [
      SubCategory(
        title: '기대',
        operations: [30], //
        color: Color.fromARGB(255, 59, 173, 221)),
    ],
  ),
  // Category(
  //   color: Color.fromARGB(255, 247, 158, 42),
  //   title: "열정", // 열정 3
  //   subCategories: [
  //     SubCategory(
  //         title: '열정',
  //         operations: [20], //
  //         color: Color.fromARGB(255, 250, 149, 17)),
  //   ],
  // ),
  Category(
    color: Color.fromARGB(255, 247, 124, 124),
    title: "애정", // 애정 4
    subCategories: [
      SubCategory(
          title: '애정',
          operations: [20], //
          color: Color.fromARGB(255, 240, 96, 96)),
    ],
  ),
  // Category(
  //   color: Color.fromARGB(255, 57, 105, 138),
  //   title: "슬픔", // 슬픔 5
  //   subCategories: [
  //     SubCategory(
  //         title: '슬픔',
  //         operations: [20], //
  //         color: Color.fromARGB(255, 94, 127, 150)),
  //   ],
  // ),
  // Category(
  //   color: Color.fromARGB(255, 245, 96, 70),
  //   title: "분노", // 분노 6
  //   subCategories: [
  //     SubCategory(
  //         title: '분노',
  //         operations: [20], //
  //         color: Color.fromARGB(255, 241, 128, 108)),
  //   ],
  // ),
  // Category(
  //   color: Color.fromARGB(255, 194, 61, 194),
  //   title: "우울", // 우울 7
  //   subCategories: [
  //     SubCategory(
  //         title: '우울',
  //         operations: [20], //
  //         color: Color.fromARGB(255, 211, 103, 211)),
  //   ],
  // ),
  // Category(
  //   color: Color.fromARGB(255, 216, 74, 74),
  //   title: "스트레스", // 스트레스 8
  //   subCategories: [
  //     SubCategory(
  //         title: '스트레스',
  //         operations: [20], //
  //         color: Color.fromARGB(255, 233, 104, 104)),
  //   ],
  // ),
  Category(
    color: Color.fromARGB(255, 115, 214, 168),
    title: "기타", // 기타
    subCategories: [
      SubCategory(
          title: '분노',
          operations: [2], //
          color: Color.fromARGB(255, 82, 212, 151)), //Colors.teal.shade200)
      SubCategory(
          title: '애정',
          operations: [4], //
          color: Color.fromARGB(255, 36, 211, 129)), //Colors.teal.shade100)
      SubCategory(
          title: '스트레스',
          operations: [2], //
          color: Color.fromARGB(255, 121, 233, 181)), //Colors.teal.shade600)
      SubCategory(
          title: '열정',
          operations: [2], //
          color: Color.fromARGB(255, 37, 224, 137)), //Colors.teal.shade800)
    ],
  ),
];
