import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/custom/palette.dart';

class ChatBubbles extends StatelessWidget {
  const ChatBubbles(
      this.message, this.isMe, this.userName, this.userImage, this.time,
      {super.key});

  final String message;
  final String userName;
  final bool isMe;
  final String userImage;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (isMe)
              Padding(
                padding: EdgeInsets.only(bottom: 5.h, right: 3.w),
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            Padding(
              padding: isMe
                  ? EdgeInsets.fromLTRB(0, 0, 45.w, 5.h)
                  : EdgeInsets.fromLTRB(45.w, 0, 0, 5.h),
              child: ChatBubble(
                clipper: ChatBubbleClipper2(
                    type: isMe
                        ? BubbleType.sendBubble
                        : BubbleType.receiverBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 20.h),
                backGroundColor: isMe
                    ? Palette.first //Color.fromRGBO(254, 182, 36, 0.9)
                    : Colors.blueGrey[50], //Color.fromRGBO(255, 234, 217, 0.9),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.53,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isMe ? Colors.black : Colors.black,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Text(
                        message,
                        style: TextStyle(
                          color: isMe ? Colors.black : Colors.black,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isMe)
              Padding(
                padding: EdgeInsets.only(bottom: 5.h, left: 3.w),
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 8.sp,
                  ),
                ),
              ),
          ],
        ),
        Positioned(
          bottom: 0,
          right: isMe ? 2.w : null,
          left: isMe ? null : 2.w,
          child: CircleAvatar(
            radius: 23.sp,
            backgroundImage: userImage != '' ? NetworkImage(userImage) : null,
          ),
        ),
      ],
    );
  }
}
