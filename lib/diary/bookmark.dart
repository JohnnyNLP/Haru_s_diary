import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../custom/custom_theme.dart';
import '../screens/diary_screen.dart';

class Bookmarks extends StatelessWidget {
  const Bookmarks(
      this.docId, this.date, this.dateForm, this.title, this.content,
      {super.key});

  final String docId;
  final String date;
  final String dateForm;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          // 패딩 값을 줄였습니다.
          padding: EdgeInsets.fromLTRB(0, 0, 0, 4.h),
          child: Container(
            // 여기도 패딩 값을 줄였습니다.
            padding: EdgeInsetsDirectional.fromSTEB(12.w, 12.h, 12.w, 12.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: CustomTheme.of(context).secondaryBackground,
              boxShadow: [
                BoxShadow(
                  blurRadius: 3,
                  color: Color(0x20000000),
                  offset: Offset(0, 1),
                )
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CustomTheme.of(context).bodySmall.override(
                                    fontFamily: 'Readex Pro',
                                    // color: Color(0xFFF46060),
                                    fontSize: 15,
                                    // fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Text(
                            dateForm,
                            style: CustomTheme.of(context).bodySmall.override(
                                  fontFamily: 'Readex Pro',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CustomTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              // color: Color(0xFFF46060),
                              fontSize: 15,
                              // fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 1.0), // 원하는 패딩 값을 설정
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_outlined,
                      color: Color(0xFFEE8B60),
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DiaryScreen(docId, date)));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
