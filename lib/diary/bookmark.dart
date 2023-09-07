import 'package:flutter/material.dart';
import '../custom/custom_theme.dart';
import '../screens/diary_screen.dart';

class Bookmarks extends StatelessWidget {
  const Bookmarks(this.date, this.dateForm, this.title, this.content,
      {super.key});

  final String date;
  final String dateForm;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(24, 12, 24, 12),
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
                      SizedBox(height: 4),
                      Text(
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
                        builder: (context) => DiaryScreen(date, [])));
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
