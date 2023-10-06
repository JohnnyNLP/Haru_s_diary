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
    this.sBtns,
    this.eBtns,
    this.popupItems,
  }) : super(key: key);

  final IconData? sIcon;
  final String? sText;
  final String? eText;
  final IconData? eIcon;
  final VoidCallback? sOnPressed;
  final VoidCallback? eOnPressed;
  final List<Map>? sBtns;
  final List<Map>? eBtns;
  final List<Map>? popupItems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0.h, 0, 10.h, 0),
      width: 100.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 255, 255, 255),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(children: [
            if (sBtns != null)
              for (var btn in sBtns!)
                CustomIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20,
                  buttonSize: 40.h,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  icon: Icon(
                    btn['icon'] ?? null,
                    color: CustomTheme.of(context).tertiary,
                    size: 30.h,
                  ),
                  onPressed: btn['onPressed'] ?? () {},
                ),
            if (sIcon != null)
              CustomIconButton(
                borderColor: Colors.transparent,
                borderRadius: 20,
                buttonSize: 40.h,
                fillColor: Color.fromARGB(255, 255, 255, 255),
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
              if (eBtns != null)
                for (var btn in eBtns!)
                  CustomIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 20,
                    buttonSize: 40.h,
                    fillColor: Color.fromARGB(255, 255, 255, 255),
                    icon: Icon(
                      btn['icon'] ?? null,
                      color: CustomTheme.of(context).tertiary,
                      size: 30.h,
                    ),
                    onPressed: btn['onPressed'] ?? () {},
                  ),
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
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  icon: Icon(
                    eIcon,
                    color: CustomTheme.of(context).tertiary,
                    size: 29.h,
                  ),
                  onPressed: eOnPressed ?? () {},
                ),
              if (popupItems != null)
                PopupMenuButton<int>(
                  padding: EdgeInsets.all(0),
                  offset: Offset(0, 50.h),
                  icon: Icon(
                    Icons.more_vert,
                    color: CustomTheme.of(context).tertiary,
                    size: 30.h,
                  ),
                  itemBuilder: (context) => [
                    for (var item in popupItems!)
                      PopupMenuItem(
                        child: ListTile(
                          title: Text(item['title']),
                          onTap: item['onTap'],
                        ),
                      )
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }
}
