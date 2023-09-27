// import 'package:flutter/material.dart';
// import 'collection_choice_screen.dart'; // Assuming the import is necessary for your overall code
// import 'chat_screen.dart';
// import 'chat_start_page.dart';

// class CustomBottomNavigationBar extends StatelessWidget {
//   final TabController _tabController;
//   final int _selectedIndex;

//   CustomBottomNavigationBar(this._tabController, this._selectedIndex);

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       child: Container(
//         color: Color.fromARGB(128, 217, 149, 81),
//         child: TabBar(
//           indicatorColor: Colors.transparent,
//           controller: _tabController,
//           labelColor: Colors.black,
//           tabs: <Widget>[
//             Tab(icon: _selectedIndex == 0 ? Icon(Icons.home) : Icon(Icons.home_outlined)),
//             Tab(icon: _selectedIndex == 1 ? Icon(Icons.chat_bubble) : Icon(Icons.chat_bubble_outlined)),
//             Tab(icon: _selectedIndex == 2 ? Icon(Icons.book) : Icon(Icons.book_outlined)),
//             Tab(icon: _selectedIndex == 3 ? Icon(Icons.settings) : Icon(Icons.settings_outlined)),
//           ],
//         ),
//       ),
//     );
//   }
// }