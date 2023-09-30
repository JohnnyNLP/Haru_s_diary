import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/custom/custom_icon_button.dart';
import 'package:haru_diary/custom/custom_theme.dart';
import 'package:haru_diary/custom/custom_app_bar.dart';

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
            padding: EdgeInsetsDirectional.all(16.h),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionHeader('계정 : ${loggedUser!.email}'),
                  SizedBox(
                    height: 16.h,
                  ),
                  _buildListItem(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
