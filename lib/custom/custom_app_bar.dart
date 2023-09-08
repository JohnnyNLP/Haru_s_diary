import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key, required this.text}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF9DE7A),
      automaticallyImplyLeading: false,
      title: Text(
        text,
        textAlign: TextAlign.start,
        style: CustomTheme.of(context).headlineMedium.override(
              fontFamily: 'Outfit',
              color: Color(0xFF394249),
              fontSize: 22.sp,
              fontWeight: FontWeight.w500,
            ),
      ),
      actions: [],
      centerTitle: false,
      elevation: 2,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);
}
