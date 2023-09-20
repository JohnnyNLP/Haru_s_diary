import 'package:flutter/material.dart';

class HomeScreenNavi extends StatefulWidget {
  @override
  State<HomeScreenNavi> createState() => _HomeScreenNaviState();
}

class _HomeScreenNaviState extends State<HomeScreenNavi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(
        () => setState(() => _selectedIndex = _tabController.index));
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
        child: TabBar(
          indicatorColor: Colors.transparent,
          labelColor: Colors.black,
          controller: _tabController,
          tabs: <Widget>[
            Tab(
              icon: Icon( //
                _selectedIndex == 0 ? Icons.person : Icons.person_outlined,
              ),
            ),
            Tab(
              icon: Icon(
                _selectedIndex == 1 ? Icons.chat : Icons.chat_outlined,
              ),
              // text: "Chats",
            ),
            Tab(
              icon: Icon(
                _selectedIndex == 2 ? Icons.settings : Icons.settings_outlined,
              ),
              // text: "Settings",
            ),
          ],
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