// import 'package:flutter/material.dart';
// import 'package:haru_diary/custom/custom_top_container.dart';
// import 'package:table_calendar/table_calendar.dart';
// import '/Custom/Custom_theme.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CalendarScreen(),
//     );
//   }
// }

// // 상태를 가지는 위젯 CalendarScreen을 선언
// class CalendarScreen extends StatefulWidget {
//   const CalendarScreen({Key? key}) : super(key: key);

//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }

// class _CalendarScreenState extends State<CalendarScreen> {
//   CalendarFormat _calendarFormat = CalendarFormat.month;
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   final scaffoldKey = GlobalKey<ScaffoldState>();

//   // 특정 날짜에 대한 이벤트를 저장
//   final Map<DateTime, List<String>> _events = {
//     DateTime.utc(2023, 9, 7): ['Event 1'],
//     DateTime.utc(2023, 9, 8): ['Event 2'],
//     DateTime.utc(2023, 9, 11): ['Event 3'],
//   };

// // 위젯의 초기화 로직을 넣을 수 있으며, 현재는 비어있음
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // 파이어베이스 연동
//     // 몇월 몇일 일기 있는지 없는지 T/F Boolean or list로 일기 있는지 없는지 목록 만들기
//     // backgroundColor: isTrue ? Color(0xFFF9DE7A) : Color(Colors.black),
//     // bool isTrue = true;
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // appbar에 자동생성되는 뒤로가기 버튼 제거 추가
//         backgroundColor: Color(0xFFF9DE7A),
//         title: Text(
//           'Calendar',
//           style: CustomTheme.of(context).headlineMedium.override(
//                 fontFamily: 'Outfit',
//                 color: Color(0xFF394249),
//                 fontSize: 22.sp,
//                 fontWeight: FontWeight.w600,
//               ),
//         ),
//       ),
//       body: SafeArea(
//         top: true,
//         child: Padding(
//           padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0.h),
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               CustomTopContainer(
//                 // top container 생성함
//                 sText: 'Back',
//                 sIcon: Icons.chevron_left_outlined,
//                 sOnPressed: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               Divider(
//                 thickness: 2,
//                 color: CustomTheme.of(context).alternate,
//               ),
//               Padding(
//                 padding: EdgeInsetsDirectional.fromSTEB(5.w, 20.h, 0.w, 0.h),
//                 child: Text(
//                   '켈린더로 일기를 확인하세요.',
//                   style: CustomTheme.of(context).bodyMedium.override(
//                         fontFamily: 'Readex Pro',
//                         color: Color(0xFF333C49),
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                 ),
//               ),
//               TableCalendar(
//                 firstDay: DateTime.utc(2010, 10, 16),
//                 lastDay: DateTime.utc(2030, 3, 14),
//                 focusedDay: _focusedDay,
//                 calendarFormat: _calendarFormat,
//                 selectedDayPredicate: (day) {
//                   return isSameDay(_selectedDay, day);
//                 },
//                 onDaySelected: (selectedDay, focusedDay) {
//                   setState(() {
//                     _selectedDay = selectedDay;
//                     _focusedDay = focusedDay;
//                   });
//                 },
//                 onPageChanged: (focusedDay) {
//                   _focusedDay = focusedDay;
//                 },
//                 eventLoader: (day) {
//                   return _events[day] ?? [];
//                 },
//                 calendarStyle: CalendarStyle(
//                   markerDecoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
