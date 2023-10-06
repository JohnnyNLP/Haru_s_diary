import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                    fontSize: 10.sp,
                  ),
                ),
              ),
            Padding(
              padding: isMe
                  ? EdgeInsets.fromLTRB(0, 0, 40.w, 5.h)
                  : EdgeInsets.fromLTRB(40.w, 0, 0, 5.h),
              child: ChatBubble(
                clipper: ChatBubbleClipper2(
                    type: isMe
                        ? BubbleType.sendBubble
                        : BubbleType.receiverBubble),
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(top: 20),
                backGroundColor: isMe ? Colors.blue : Color(0xffE7E7ED),
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.55,
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
                            color: isMe ? Colors.white : Colors.black),
                      ),
                      Text(
                        message,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black),
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
                    fontSize: 10.sp,
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
            radius: 25.h,
            backgroundImage: userImage != '' ? NetworkImage(userImage) : null,
          ),
        ),
      ],
    );
  }
}
