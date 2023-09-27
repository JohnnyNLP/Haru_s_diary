import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/chart/chart_main.dart';
import 'package:haru_diary/screens/diary_home_screen.dart';
import 'package:haru_diary/screens/tab_navigator.dart';
// import 'collection_choice_screen.dart'; // Assuming the import is necessary for your overall code
import 'chat_list_screen.dart';

class HomeScreenNavi extends StatefulWidget {
  @override
  State<HomeScreenNavi> createState() => _HomeScreenNaviState();
}

class _HomeScreenNaviState extends State<HomeScreenNavi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  Color backgroundColor = Colors.indigo; // 초기 배경색

  final _diaryTabNavKey = GlobalKey<NavigatorState>();
  final _chatTabNavKey = GlobalKey<NavigatorState>();
  final _collectionTabNavKey = GlobalKey<NavigatorState>();
  final _settingTabNavKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
        switch (_selectedIndex) {
          case 0:
            backgroundColor = const Color.fromARGB(255, 255, 255, 255);
            break;
          case 1:
            backgroundColor = const Color.fromARGB(255, 255, 255, 255);
            break;
          case 2:
            backgroundColor = const Color.fromARGB(255, 255, 255, 255);
            break;
          case 3:
            backgroundColor = const Color.fromARGB(255, 255, 255, 255);
            break;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SizedBox(
        height: 50.h,
        child: Container(
          color: backgroundColor = Color.fromARGB(128, 217, 149, 81),
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Colors.black,
            controller: _tabController,
            tabs: <Widget>[
              Tab(
                  icon: _selectedIndex == 0
                      ? Icon(Icons.auto_stories)
                      : Icon(Icons.auto_stories_outlined)),
              Tab(
                  icon: _selectedIndex == 1
                      ? Icon(Icons.chat_bubble)
                      : Icon(Icons.chat_bubble_outline)),
              Tab(
                  icon: _selectedIndex == 2
                      ? Icon(Icons.book)
                      : Icon(Icons.book_outlined)),
              Tab(
                  icon: _selectedIndex == 3
                      ? Icon(Icons.settings)
                      : Icon(Icons.settings_outlined)),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TabNavigator(navigatorKey: _diaryTabNavKey, child: DiaryHomeScreen()),
          TabNavigator(navigatorKey: _chatTabNavKey, child: ChatListScreen()),
          TabNavigator(navigatorKey: _collectionTabNavKey, child: ChartMain()),
          TabNavigator(
              navigatorKey: _settingTabNavKey,
              child: tabContainer(
                  context, const Color.fromARGB(0, 0, 0, 0), "Settings Tab")),
        ],
      ),
    );
  }

  Container tabContainer(BuildContext context, Color tabColor, String tabText) {
    return Container(
      width: MediaQuery.of(context).size.width.w,
      height: MediaQuery.of(context).size.height.h,
      color: tabColor,
      child: Center(
        child: Text(
          tabText,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
