// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:haru_diary/api/functions.dart';
// // import 'package:haru_diary/custom/custom_app_bar.dart';
// import 'package:haru_diary/screens/calendar_screen.dart';
// import 'package:haru_diary/screens/chat_list_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../provider/common_provider.dart';
// import '/custom/custom_top_container.dart';
// import '/custom/custom_icon_button.dart';
// import '/custom/custom_theme.dart';
// import '/custom/custom_widgets.dart';

// import 'diary_list_screen.dart';
// import 'home_screen_navi.dart'; // 홈 setting버튼 누르면 home_screen_navi 테스트 해보기 위해 추가

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//   final _authentication = FirebaseAuth.instance;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<CommonProvider>(context, listen: false).setUserPrefs();
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         key: scaffoldKey,
//         backgroundColor: Color(0xFFFAFAFA),
//         // appBar: CustomAppBar(text: 'Home'),
//         body: SafeArea(
//           top: true,
//           child: Padding(
//             padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 0.h),
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 CustomTopContainer(
//                   sIcon: Icons.logout,
//                   // sText: 'Logout',
//                   sOnPressed: () {
//                     _authentication.signOut();
//                   },
//                   eText: 'Edit Home',
//                   eIcon: Icons.keyboard_control,
//                 ),
//                 Divider(
//                   thickness: 2,
//                   color: CustomTheme.of(context).alternate,
//                 ),
//                 Align(
//                   alignment: AlignmentDirectional(-1, 0),
//                   child: Padding(
//                     padding:
//                         EdgeInsetsDirectional.fromSTEB(0.w, 10.h, 0.w, 10.h),
//                     child: Text(
//                       '<나의 하루>',
//                       style: CustomTheme.of(context).bodyMedium.override(
//                             fontFamily: 'Readex Pro',
//                             color: Color(0xFF394249),
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w600,
//                           ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.w, 0.h, 0.w, 10.h),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(8),
//                     child: Image.network(
//                       'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1286&q=80',
//                       width: 243.w,
//                       height: 234.h,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0.w, 0.h, 0.w, 10.h),
//                   child: Container(
//                     width: 100.w,
//                     height: 140.h,
//                     decoration: BoxDecoration(
//                       color: CustomTheme.of(context).secondaryBackground,
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.max,
//                       children: [
//                         Padding(
//                           padding: EdgeInsetsDirectional.fromSTEB(
//                               0.w, 10.h, 0.w, 10.h),
//                           child: FFButtonWidget(
//                             onPressed: () {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                 // builder: (context) => const ChatScreen(),
//                                 builder: (context) => const ChatListScreen(),
//                               ));
//                             },
//                             text: '대화 하기',
//                             options: FFButtonOptions(
//                               width: 290.w,
//                               height: 50.h,
//                               padding: EdgeInsetsDirectional.fromSTEB(
//                                   0.w, 0.h, 0.w, 0.h),
//                               iconPadding: EdgeInsetsDirectional.fromSTEB(
//                                   0.w, 0.h, 0.w, 0.h),
//                               color: Color(0xFFF9DE7A),
//                               textStyle:
//                                   CustomTheme.of(context).titleSmall.override(
//                                         fontFamily: 'Readex Pro',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                               elevation: 2,
//                               borderSide: BorderSide(
//                                 color: Colors.transparent,
//                                 width: 1.w,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsetsDirectional.fromSTEB(
//                               0.w, 10.h, 0.w, 10.h),
//                           child: FFButtonWidget(
//                             onPressed: () {
//                               print('Button pressed ...');

//                               // Navigator.of(context).push(MaterialPageRoute(
//                               //     builder: (context) => DiaryScreen(
//                               //         DateFormat('yyyyMMdd')
//                               //             .format(DateTime.now()),
//                               //         false)));
//                             },
//                             text: '오늘의 일기',
//                             options: FFButtonOptions(
//                               width: 290.w,
//                               height: 50.h,
//                               padding: EdgeInsetsDirectional.fromSTEB(
//                                   0.w, 0.h, 0.w, 0.h),
//                               iconPadding: EdgeInsetsDirectional.fromSTEB(
//                                   0.w, 0.h, 0.w, 0.h),
//                               color: Color(0xFFF9DE7A),
//                               textStyle:
//                                   CustomTheme.of(context).titleSmall.override(
//                                         fontFamily: 'Readex Pro',
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                               elevation: 2,
//                               borderSide: BorderSide(
//                                 color: Colors.transparent,
//                                 width: 1.w,
//                               ),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Divider(
//                   thickness: 2,
//                   color: CustomTheme.of(context).alternate,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Column(
//                         children: [
//                           CustomIconButton(
//                             borderRadius: 20,
//                             borderWidth: 1.w,
//                             buttonSize: 56.h,
//                             fillColor: Color(0xFFFAFAFA),
//                             icon: Icon(
//                               Icons.menu_book_rounded,
//                               color: CustomTheme.of(context).primaryText,
//                               size: 40.h,
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => const DiaryListScreen(),
//                               ));
//                             },
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(
//                                 left: 6), // 하단 diary 글자 위치 이동(심기섭 수정)
//                             child: Text(
//                               'Diary',
//                               textAlign: TextAlign.start,
//                               style: CustomTheme.of(context).bodySmall,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           CustomIconButton(
//                             borderRadius: 20,
//                             borderWidth: 1.w,
//                             buttonSize: 56.h,
//                             icon: Icon(
//                               Icons.calendar_month,
//                               color: CustomTheme.of(context).primaryText,
//                               size: 40.h,
//                             ),
//                             onPressed: () {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => const CalendarScreen(),
//                               ));
//                             },
//                           ),
//                           Padding(
//                             padding: EdgeInsets.only(
//                                 left: 10), // 하단 Calendar 글자 위치 이동(심기섭 수정)
//                             child: Text(
//                               'Calendar',
//                               style: CustomTheme.of(context).bodySmall,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Column(
//                         children: [
//                           CustomIconButton(
//                             borderColor: Colors.transparent,
//                             borderRadius: 20,
//                             borderWidth: 1.w,
//                             buttonSize: 56.h,
//                             icon: Icon(
//                               Icons.settings_sharp,
//                               color: CustomTheme.of(context).primaryText,
//                               size: 40.h,
//                             ),
//                             onPressed: () async {
//                               Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) =>
//                                     HomeScreenNavi(), // 기존 홈스크린에서 셋팅 버튼 누르면 홈스크린네비화면으로 전환되도록함.
//                               ));
//                             },
//                           ),

//                           //원래 코드(셋팅 버튼 누르면 홈 하단 앱바 화면 테스트 하려고 잠시 주석 처리함)
//                           //   onPressed: () async {
//                           //     // 호출하려는 main.py의 함수명 적으면 됨
//                           //     var functionName = 'ChatAI';
//                           //     // 아래와같이 테스트 시 필요한 값 키밸류쌍으로 하드코딩해서 호출
//                           //     // 현재는 아무렇게나 값 넣어서 정상호출 안 됨
//                           //     var keyValue = <String, dynamic>{
//                           //       'date': '20230911',
//                           //       'prompt': '하이',
//                           //     };
//                           //     var returnValue = await func.testFunction(
//                           //         functionName, keyValue);
//                           //     print(returnValue);
//                           //   },
//                           // ),
//                           Padding(
//                             padding: EdgeInsets.only(
//                                 left: 6), // 하단 Setting 글자 위치 이동(심기섭 수정)
//                             child: Text(
//                               'Setting',
//                               style: CustomTheme.of(context).bodySmall,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
