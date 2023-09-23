import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/screens/chat_screen.dart';
import '../custom/custom_theme.dart';

class ChatRoom extends StatelessWidget {
  const ChatRoom(this.docId, this.dateForm, this.text, {super.key});

  final String docId;
  final String dateForm;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(4.w),
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(24.w, 12.h, 24.w, 12.h),
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
                      Text(
                        dateForm,
                        style: CustomTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        text,
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
                IconButton(
                  icon: Icon(
                    Icons.arrow_forward_outlined,
                    color: Color(0xFFEE8B60),
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ChatScreen(docId: docId)));
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
