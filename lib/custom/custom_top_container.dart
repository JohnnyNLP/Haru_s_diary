import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'custom_icon_button.dart';
import 'custom_theme.dart';

class CustomTopContainer extends StatelessWidget {
  const CustomTopContainer({
    Key? key,
    this.sIcon,
    this.sText,
    this.eText,
    this.eIcon,
    this.sOnPressed,
    this.eOnPressed,
  }) : super(key: key);

  final IconData? sIcon;
  final String? sText;
  final String? eText;
  final IconData? eIcon;
  final VoidCallback? sOnPressed;
  final VoidCallback? eOnPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            if (sIcon != null)
              CustomIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20,
                buttonSize: 40.h,
                fillColor: Color(0xFFFAFAFA),
                icon: Icon(
                  sIcon,
                  color: CustomTheme.of(context).tertiary,
                  size: 30.h,
                ),
                onPressed: sOnPressed ?? () {},
              ),
            if (sText != null)
              Text(
                sText!,
                style: CustomTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: Color(0xFF66686D),
                      fontSize: 14.sp,
                      // fontWeight: FontWeight.w600,
                    ),
              ),
          ]),
          Row(
            children: [
              if (eText != null)
                Text(
                  eText!,
                  style: CustomTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: Color(0xFF66686D),
                        fontSize: 14.sp,
                        // fontWeight: FontWeight.w600,
                      ),
                ),
              if (eIcon != null)
                CustomIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20,
                  buttonSize: 40.h,
                  fillColor: Color(0xFFFAFAFA),
                  icon: Icon(
                    eIcon,
                    color: CustomTheme.of(context).tertiary,
                    size: 29.h,
                  ),
                  onPressed: eOnPressed ?? () {},
                ),
            ],
          ),
        ],
      ),
    );
  }
}
