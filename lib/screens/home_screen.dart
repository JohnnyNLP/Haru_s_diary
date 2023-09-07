import 'package:firebase_auth/firebase_auth.dart';
import 'package:haru_diary/custom/custom_app_bar.dart';
import 'package:intl/intl.dart';

import '../custom/custom_top_container.dart';
import '/custom/custom_icon_button.dart';
import '/custom/custom_theme.dart';
import '/custom/custom_widgets.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';
import 'diary_screen.dart';
import 'weekly_diary_screen.dart';

class HomeScreen2 extends StatefulWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _authentication = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: 'Home'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTopContainer(
                  sIcon: Icons.logout,
                  // sText: 'Logout',
                  sOnPressed: () {
                    _authentication.signOut();
                  },
                  eText: 'Edit Home',
                  eIcon: Icons.keyboard_control,
                ),
                Divider(
                  thickness: 2,
                  color: CustomTheme.of(context).alternate,
                ),
                Align(
                  alignment: AlignmentDirectional(-1, 0),
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                    child: Text(
                      '<나의 하루>',
                      style: CustomTheme.of(context).bodyMedium.override(
                            fontFamily: 'Readex Pro',
                            color: Color(0xFF394249),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1286&q=80',
                      width: 243,
                      height: 234,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                  child: Container(
                    width: 100,
                    height: 140,
                    decoration: BoxDecoration(
                      color: CustomTheme.of(context).secondaryBackground,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                          child: FFButtonWidget(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ));
                            },
                            text: '대화 하기',
                            options: FFButtonOptions(
                              width: 290,
                              height: 50,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: Color(0xFFF9DE7A),
                              textStyle:
                                  CustomTheme.of(context).titleSmall.override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                              elevation: 2,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 10, 0, 10),
                          child: FFButtonWidget(
                            onPressed: () {
                              print('Button pressed ...');

                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => DiaryScreen(
                                      DateFormat('yyyyMMdd')
                                          .format(DateTime.now()),
                                      [])));
                            },
                            text: '오늘의 일기',
                            options: FFButtonOptions(
                              width: 290,
                              height: 50,
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              iconPadding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                              color: Color(0xFFF9DE7A),
                              textStyle:
                                  CustomTheme.of(context).titleSmall.override(
                                        fontFamily: 'Readex Pro',
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                              elevation: 2,
                              borderSide: BorderSide(
                                color: Colors.transparent,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: CustomTheme.of(context).alternate,
                ),
                Container(
                  decoration: BoxDecoration(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          CustomIconButton(
                            borderRadius: 20,
                            borderWidth: 1,
                            buttonSize: 56,
                            fillColor: Color(0xFFFAFAFA),
                            icon: Icon(
                              Icons.menu_book_rounded,
                              color: CustomTheme.of(context).primaryText,
                              size: 40,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const WeeklyDiaryScreen(),
                              ));
                            },
                          ),
                          Text(
                            'Diary',
                            textAlign: TextAlign.start,
                            style: CustomTheme.of(context).bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CustomIconButton(
                            borderRadius: 20,
                            borderWidth: 1,
                            buttonSize: 56,
                            icon: Icon(
                              Icons.calendar_month,
                              color: CustomTheme.of(context).primaryText,
                              size: 40,
                            ),
                            onPressed: () {
                              print('IconButton pressed ...');
                            },
                          ),
                          Text(
                            'Calendar',
                            style: CustomTheme.of(context).bodySmall,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          CustomIconButton(
                            borderColor: Colors.transparent,
                            borderRadius: 20,
                            borderWidth: 1,
                            buttonSize: 56,
                            icon: Icon(
                              Icons.settings_sharp,
                              color: CustomTheme.of(context).primaryText,
                              size: 40,
                            ),
                            onPressed: () {
                              print('IconButton pressed ...');
                            },
                          ),
                          Text(
                            'Setting',
                            style: CustomTheme.of(context).bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Padding(
                //   padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                //   child: Container(
                //     decoration: BoxDecoration(),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.max,
                //       children: [
                //         Padding(
                //           padding: EdgeInsetsDirectional.fromSTEB(49, 0, 0, 0),
                //           child: Text(
                //             'Diary',
                //             textAlign: TextAlign.start,
                //             style: CustomTheme.of(context).bodyMedium,
                //           ),
                //         ),
                //         Padding(
                //           padding: EdgeInsetsDirectional.fromSTEB(51, 0, 42, 0),
                //           child: Text(
                //             'Calendar',
                //             style: CustomTheme.of(context).bodyMedium,
                //           ),
                //         ),
                //         Text(
                //           'Setting',
                //           style: CustomTheme.of(context).bodyMedium,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
