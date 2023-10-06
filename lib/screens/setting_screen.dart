import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/custom/custom_icon_button.dart';
import 'package:haru_diary/custom/custom_theme.dart';
import 'package:haru_diary/custom/custom_app_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
    );
  }

  Widget _buildListItem({bool large = false, bool round = false}) {
    return Container(
      height: large ? 100.0 : 50.0,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius:
            round ? BorderRadius.circular(50.0) : BorderRadius.circular(8.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomIconButton(
            borderColor: Colors.transparent,
            borderRadius: 20,
            buttonSize: 40.h,
            // fillColor: Color.fromARGB(255, 255, 255, 255),
            icon: Icon(
              Icons.logout,
              color: CustomTheme.of(context).tertiary,
              size: 25.h,
            ),
            onPressed: () {
              _authentication.signOut();
            },
          ),
          SizedBox(width: 8.0.w),
          Text(
            '로그아웃',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: '설정'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16.w, 16.h, 16.w, 16.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('계정 : ${loggedUser!.email}'),
                    SizedBox(
                      height: 16.h,
                    ),
                    _buildListItem(),
                    // SizedBox(
                    //   height: 16.h,
                    // ),
                    // Container(
                    //   height: 50.0,
                    //   decoration: BoxDecoration(
                    //       color: Colors.grey[200],
                    //       borderRadius: BorderRadius.circular(8.0)),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.center,
                    //     children: [
                    //       CustomIconButton(
                    //         borderColor: Colors.transparent,
                    //         borderRadius: 20,
                    //         buttonSize: 40.h,
                    //         icon: Icon(
                    //           Icons.logout,
                    //           color: CustomTheme.of(context).tertiary,
                    //           size: 25.h,
                    //         ),
                    //         onPressed: () async {
                    //           await func.callFunctions('test', {});
                    //         },
                    //       ),
                    //       SizedBox(width: 8.0.w),
                    //       Text(
                    //         '테스트',
                    //         style: TextStyle(color: Colors.grey),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: const Color.fromARGB(128, 0, 0, 0),
                            fontSize: 12.0),
                        children: <TextSpan>[
                          // TextSpan(text: '강아지 icon by '),
                          TextSpan(
                            text: '작가 mamewmy',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(
                                    'https://kr.freepik.com/free-vector/happy-pomeranian-dog-character-hand-drawn-cartoon-art-illustration_17303376.htm#query=%EA%B0%95%EC%95%84%EC%A7%80%20%EC%BA%90%EB%A6%AD%ED%84%B0&position=6&from_view=keyword&track=ais');
                              },
                          ),
                          TextSpan(text: ' 출처 Freepik'),
                        ],
                      ),
                    ),
                    // RichText(
                    //   text: TextSpan(
                    //     style: TextStyle(color: Colors.black, fontSize: 16.0),
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //         text: '사람',
                    //         style: TextStyle(
                    //             color: Colors.blue,
                    //             decoration: TextDecoration.underline),
                    //         recognizer: TapGestureRecognizer()
                    //           ..onTap = () {
                    //             launchUrlString(
                    //                 'https://icons8.com/icon/ckaioC1qqwCu/%EC%9B%90-%EC%82%AC%EC%9A%A9%EC%9E%90-%EB%82%A8%EC%84%B1');
                    //           },
                    //       ),
                    //       TextSpan(text: ' icon by '),
                    //       TextSpan(
                    //         text: 'Icons8',
                    //         style: TextStyle(
                    //             color: Colors.blue,
                    //             decoration: TextDecoration.underline),
                    //         recognizer: TapGestureRecognizer()
                    //           ..onTap = () {
                    //             launchUrlString(
                    //                 'https://flutter.dev'); // 원하는 URL 입력
                    //           },
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            color: const Color.fromARGB(128, 0, 0, 0),
                            fontSize: 12.0),
                        children: <TextSpan>[
                          TextSpan(
                            text: '일기',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(
                                    'https://icons8.com/icon/J25sLBulrB7D/%EC%9D%BC%EC%A7%80');
                              },
                          ),
                          TextSpan(text: ' icon by '),
                          TextSpan(
                            text: 'Icons8',
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                launchUrlString(
                                    'https://flutter.dev'); // 원하는 URL 입력
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
