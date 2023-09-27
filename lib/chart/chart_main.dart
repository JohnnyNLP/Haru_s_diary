import 'package:flutter/material.dart';
import 'chart_main_screen.dart';

class ChartMain extends StatefulWidget {
  const ChartMain({Key? key}) : super(key: key);

  @override
  State<ChartMain> createState() => _ChartMainState();
}

class _ChartMainState extends State<ChartMain> {
  final backgroundColor = Color.fromARGB(255, 255, 255, 255);
  final darkBackgroundColor = Color.fromARGB(255, 255, 255, 255); //앱바 밑에 배경색
  final darkerBackgroundColor = Color.fromARGB(255, 240, 106, 102); //앱바 배경색
  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: brightness,
        builder: (context, value, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light().copyWith(
              appBarTheme: const AppBarTheme(
                backgroundColor:
                    Color.fromARGB(255, 158, 158, 155), //다크모드에서 앱바 배경색
                foregroundColor: Color.fromARGB(
                    255, 214, 24, 24), // 다크모드에서 앱바 text & 아이콘 color
              ),
              // backgroundColor: backgroundColor,
              scaffoldBackgroundColor: backgroundColor,
            ),
            darkTheme: ThemeData.dark().copyWith(
              appBarTheme: AppBarTheme(
                backgroundColor: darkerBackgroundColor,
                foregroundColor: Colors.blueGrey.shade300,
              ),
              // backgroundColor: darkBackgroundColor,
              scaffoldBackgroundColor: darkBackgroundColor,
            ),
            themeMode:
                value == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
            home: const MainScreen(),
          );
        },
      );
}
