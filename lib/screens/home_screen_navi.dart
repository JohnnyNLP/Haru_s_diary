import 'package:flutter/material.dart';
import 'collection_choice_screen.dart'; // Assuming the import is necessary for your overall code

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
      appBar: AppBar(
        title: Text("Test Title"),
      ),
      bottomNavigationBar: SizedBox(
        height: 80,
        child: Container(
          color: backgroundColor,
          child: TabBar(
            indicatorColor: Colors.transparent,
            labelColor: Colors.black,
            controller: _tabController,
            tabs: <Widget>[
              Tab(icon: _selectedIndex == 0 ? Icon(Icons.person) : Icon(Icons.person_outlined)),
              Tab(icon: _selectedIndex == 1 ? Icon(Icons.chat) : Icon(Icons.chat_outlined)),
              Tab(icon: _selectedIndex == 2 ? Icon(Icons.book) : Icon(Icons.book_outlined)),
              Tab(icon: _selectedIndex == 3 ? Icon(Icons.settings) : Icon(Icons.settings_outlined)),
            ],
          ),
        ),
      ),
      body: _selectedIndex == 0
          ? tabContainer(context, Colors.indigo, "Friends Tab")
          : _selectedIndex == 1
              ? tabContainer(context, const Color.fromARGB(255, 170, 140, 70), "Chats Tab")
              : _selectedIndex == 2
                  ? CollectionChoiceScreen() // 수정된 부분
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