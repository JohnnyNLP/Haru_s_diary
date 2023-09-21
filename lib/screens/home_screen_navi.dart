import 'package:flutter/material.dart';

class HomeScreenNavi extends StatefulWidget {
  @override
  State<HomeScreenNavi> createState() => _HomeScreenNaviState();
}

class _HomeScreenNaviState extends State<HomeScreenNavi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  Color backgroundColor = Colors.indigo; // 초기 배경색

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
        // 배경색을 선택된 탭에 따라 변경
        switch (_selectedIndex) {
          case 0:
            backgroundColor = Colors.indigo;
            break;
          case 1:
            backgroundColor = const Color.fromARGB(255, 170, 140, 70);
            break;
          case 2:
            backgroundColor = Colors.blueGrey;
            break;
          case 3:
            backgroundColor = Colors.blueGrey;
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
      appBar: AppBar(
        title: Text("Test Title"),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Container(
          color: backgroundColor, // TabBar의 배경색
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Colors.black,
            controller: _tabController,
            tabs: <Widget>[
              Tab(icon: Icon(_selectedIndex == 0 ? Icons.person : Icons.person_outlined)),
              Tab(icon: Icon(_selectedIndex == 1 ? Icons.chat : Icons.chat_outlined)),
              Tab(icon: Icon(_selectedIndex == 2 ? Icons.book : Icons.book_outlined)),
              Tab(icon: Icon(_selectedIndex == 3 ? Icons.settings : Icons.settings_outlined)),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? tabContainer(context, Colors.indigo, "Friends Tab")
          : _selectedIndex == 1
              ? tabContainer(context, const Color.fromARGB(255, 170, 140, 70), "Chats Tab")
              : tabContainer(context, Colors.blueGrey, "Settings Tab"),
    );
  }

  Container tabContainer(BuildContext context, Color tabColor, String tabText) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: tabColor,
      child: Center(
        child: Text(
          tabText,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}