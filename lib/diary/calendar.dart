import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/screens/diary_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  Calendar({required this.key, required this.collectionPath}) : super(key: key);
  final collectionPath;
  final GlobalKey<CalendarState> key;

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  Future getMonthEvent({focusedDay}) async {
    if (focusedDay == null) focusedDay = _focusedDay;
    // 해당 월의 첫번째 날
    DateTime firstDayOfMonth = DateTime(focusedDay.year, focusedDay.month, 1);

    // 해당 월의 마지막 날
    DateTime lastDayOfMonth = (focusedDay.month < 12)
        ? DateTime(focusedDay.year, focusedDay.month + 1, 0)
        : DateTime(focusedDay.year + 1, 1, 0).subtract(Duration(days: 1));

    String formattedStartDate = DateFormat('yyyyMMdd').format(firstDayOfMonth);
    String formattedEndDate = DateFormat('yyyyMMdd').format(lastDayOfMonth);

    final snapshot = await FirebaseFirestore.instance
        .collection(widget.collectionPath!)
        .where('date', isGreaterThanOrEqualTo: formattedStartDate)
        .where('date', isLessThanOrEqualTo: formattedEndDate)
        .get();

    setState(() {
      _events.clear();
      for (var doc in snapshot.docs) {
        _events[DateTime.utc(
            int.parse(doc['date'].substring(0, 4)),
            int.parse(doc['date'].substring(4, 6)),
            int.parse(doc['date'].substring(6, 8)))] = ['event'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          TableCalendar(
            daysOfWeekHeight: 24.h,
            onCalendarCreated: (pageController) {
              getMonthEvent(focusedDay: _today);
            },
            availableGestures: AvailableGestures
                .horizontalSwipe, // 횡스크롤만 가능하도록 하여 부모의 종스크롤은 유지
            rowHeight: 40.h,
            availableCalendarFormats: {
              CalendarFormat.month: 'Month',
            },
            firstDay: _today.subtract(Duration(days: 365)),
            lastDay: _today.add(Duration(days: 365)),
            // firstDay: DateTime.utc(2010, 10, 16),
            // lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) async {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              if (_events.containsKey(selectedDay)) {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DiaryListScreen(
                        date: DateFormat('yyyyMMdd').format(selectedDay)),
                  ),
                );
                getMonthEvent(focusedDay: _focusedDay);
              }
            },
            onPageChanged: (focusedDay) async {
              await getMonthEvent(focusedDay: focusedDay);
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return _events[day] ?? [];
            },
            calendarStyle: CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
