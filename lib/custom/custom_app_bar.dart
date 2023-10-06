import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/custom/palette.dart';
import 'custom_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.text,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  final String text;
  final MainAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: Color.fromARGB(255, 234, 200, 166),
      backgroundColor: Palette.first,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: alignment, // 변경됨
        children: [
          Text(
            text,
            style: CustomTheme.of(context).headlineMedium.override(
                  fontFamily: 'Poppins',
                  color: Color(0xFF394249),
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
      actions: [],
      centerTitle: false,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h) * 0.75;
}
