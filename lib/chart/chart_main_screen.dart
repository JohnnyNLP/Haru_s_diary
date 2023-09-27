import 'package:flutter/material.dart';

import 'chart_category_screen.dart';
import 'chart_data.dart';

ValueNotifier<Brightness> brightness = ValueNotifier(Brightness.dark);

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('감정분석',
            style: TextStyle(
              color: Color.fromARGB(255, 236, 224, 224), // 앱바 타이틀 텍스트 색상 변경
              fontSize: 20, // 텍스트 크기 설정
              fontWeight: FontWeight.bold, // 텍스트 굵기 설정
            )),
        actions: [
          if (brightness.value != Brightness.light)
            IconButton(
              onPressed: () => brightness.value = Brightness.light,
              icon: const Icon(Icons.light_mode_outlined,
                  color: Color.fromARGB(
                      255, 243, 159, 33)), // 낮모드: 앱바 아이콘 버튼 색상 변경
            ),
          if (brightness.value != Brightness.dark)
            IconButton(
              onPressed: () => brightness.value = Brightness.dark,
              icon: const Icon(Icons.dark_mode_rounded,
                  color: Color.fromRGBO(250, 227, 95, 1)), // 밤모드: 아이콘 버튼 색상 변경
            )
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
                horizontal: 110.0, vertical: 100.0), // 좌우 여백 조절
            title: Row(
              children: [
                Icon(
                  Icons.layers_outlined,
                  color: Color.fromARGB(255, 243, 87, 66),
                ),
                SizedBox(width: 25.0), // 아이콘과 텍스트 사이의 간격 조절
                Text(
                  '분석하기',
                  style: TextStyle(
                    color: Color.fromARGB(255, 85, 79, 79),
                    fontSize: 30,
                  ),
                ),
              ],
            ),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => CategoryScreen(categories: categories),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
