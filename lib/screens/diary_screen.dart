import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/screens/chat_screen.dart';

import '../api/functions.dart';
import '../custom/custom_app_bar.dart';
import '../custom/custom_theme.dart';
import '../custom/custom_top_container.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen(this._docId, this._date, {Key? key}) : super(key: key);
  final String _docId;
  final String _date;

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _adviceController = TextEditingController();

  final emotion = false;
  final _authentication = FirebaseAuth.instance; //Firebase 인증 객체 생성
  final _firestore = FirebaseFirestore.instance;

  User? loggedUser;
  DocumentReference? diaryRef;
  Stream<DocumentSnapshot>? _diaryStream;
  bool _isLoading = false; // 로딩 상태를 나타내는 변수
  bool _isEdit = false;
  DocumentSnapshot? diary;

  Map sentiment = {'most': []};
  List origin = []; // 서버에서 불러온 최초 최빈 감정값 저장
  final tags = [
    '기쁨',
    '기대',
    '열정',
    '애정',
    '슬픔',
    '분노',
    '우울',
    '불쾌',
  ]; // 사용되는 모든 감정태그들

  @override // 아래 void initState()는 초기 상태 설정 메서드. 사용자 정보, 문서 레퍼런스, 일기 내용을 불러옴
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDocumentReference();
  }

  // 로딩 상태를 토글하는 메서드
  void _toggleLoading() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  // 현재 로그인한 사용자 정보를 가져오는 메서드
  void _getCurrentUser() {
    final user = _authentication.currentUser;
    try {
      if (user != null) {
        loggedUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  // 일기의 Firestore문서 레퍼런스를 가져오는 메서드
  void _getDocumentReference() {
    diaryRef = _firestore
        .collection('user')
        .doc(loggedUser!.uid)
        .collection('diary')
        .doc(widget._docId);
    _diaryStream = diaryRef!.snapshots();
  }

  void _writeDiary() async {
    func.callLambda(
      'https://wighxciiz2.execute-api.ap-northeast-2.amazonaws.com/test/submit',
      {
        'userID': loggedUser!.uid,
        'docID': widget._docId,
        'date': widget._date,
      },
    );
  }

  // 일기를 Firestore에 업데이트 하는 메서드
  Future<void> _updateDiary(
      {String? title, String? content, String? advice}) async {
    var temp;
    if (origin.length > 0) {
      if (origin[0] != sentiment['most'][0]) {
        temp = sentiment[origin[0]];
        sentiment[origin[0]] = sentiment[sentiment['most'][0]];
        sentiment[sentiment['most'][0]] = temp;
        if (origin.length > 1 && origin[1] == sentiment['most'][0])
          origin[1] = origin[0];
        origin[0] = sentiment['most'][0];
      }
      if (origin.length > 1 && origin[1] != sentiment['most'][1]) {
        temp = sentiment[origin[1]];
        sentiment[origin[1]] = sentiment[sentiment['most'][1]];
        sentiment[sentiment['most'][1]] = temp;
        origin[1] = sentiment['most'][1];
      }
    }
    await diaryRef!.set(
      {
        'title': title ?? _titleController.text,
        'content': content ?? _contentController.text,
        'advice': advice ?? _adviceController.text,
        'sentiment': sentiment,
        'time': widget._date,
      },
      SetOptions(merge: true),
    );
  }

  Widget buttonListView(List<dynamic> items) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return Padding(
          padding: EdgeInsets.only(right: 4.w),
          child: popupMenuBtns(index, items[index]),
        );
      },
    );
  }

  Widget popupMenuBtns(idx, text) {
    // 현재 선택되어있는 감정을 제외한 감정태그들을 팝업으로 보여줌
    List<String> remain =
        tags.where((tag) => !sentiment['most'].contains(tag)).toList();
    return PopupMenuButton<int>(
      enabled: _isEdit,
      offset: Offset(0, 40), // 버튼 아래로 40 픽셀만큼 오프셋
      child: Container(
        alignment: Alignment.center, // 수직, 수평 가운데 정렬
        width: 65.w,
        padding: EdgeInsets.all(6.0.h),
        decoration: BoxDecoration(
          color: CustomTheme.of(context).sentimentColor[text], // 원하는 배경색으로 변경
          borderRadius: BorderRadius.circular(6.0), // 모서리 둥글게
        ),
        child: Text(
          text,
          style: TextStyle(color: Colors.white), // 원하는 텍스트 스타일로 변경
        ),
      ),
      itemBuilder: (context) => [
        for (var tag in remain)
          PopupMenuItem(
            value: idx,
            child: ListTile(
              title: Text(tag),
              onTap: () {
                setState(() {
                  sentiment['most'][idx] = tag;
                });
                Navigator.pop(context);
              },
            ),
          )
      ],
    );
  }

  // UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _diaryStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            // 오류 발생 시 출력
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            // 데이터 로딩 중
            _isLoading = true;
          } else if (snapshot.connectionState == ConnectionState.active) {
            // Stream에 새로운 데이터 도착
            if (snapshot.hasData && snapshot.data!.exists) {
              // stream으로부터 데이터를 전달받았고, 실제 문서가 있는 경우
              if (diary != snapshot.data!) {
                diary = snapshot.data!;
                _titleController.text = diary!['title'] ?? 'No title';
                _contentController.text = diary!['content'] != null
                    ? diary!['content'].toString().trim()
                    : 'No content';
                _adviceController.text = diary!['advice'] ?? 'No advice';

                sentiment = diary!['sentiment'];
                origin = List.from(sentiment['most']);
              }
              _isLoading = false;
            } else {
              _isLoading = true;
              _writeDiary();
            }
          }
          return ModalProgressHUD(
            inAsyncCall: _isLoading,
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                key: scaffoldKey,
                backgroundColor: Color(0xFFFAFAFA),
                appBar: CustomAppBar(text: '하루의 일기장'),
                body: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 18),
                  child: SafeArea(
                    top: true,
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          16.w, 16.h, 16.w, 16.h),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          CustomTopContainer(
                            sBtns: [
                              {
                                'icon': Icons.chevron_left_outlined,
                                'onPressed': () {
                                  Navigator.pop(context);
                                },
                              },
                            ],
                            eBtns: [
                              if (_isEdit)
                                {
                                  'icon': Icons.check,
                                  'onPressed': () async {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('확인'),
                                          content: Text('수정하신 내용을 저장하시겠습니까?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('예'),
                                              onPressed: () async {
                                                _toggleLoading();
                                                await _updateDiary();
                                                setState(() {
                                                  _isEdit = !_isEdit;
                                                });
                                                _toggleLoading();
                                                Navigator.of(context)
                                                    .pop(); // 다이얼로그 닫기
                                                FocusScope.of(context)
                                                    .unfocus();
                                              },
                                            ),
                                            TextButton(
                                              child: Text('아니오'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // 다이얼로그 닫기
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                },
                            ],
                            popupItems: [
                              {
                                'title': '대화보기',
                                'onTap': () async {
                                  Navigator.pop(context);
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                          docId: widget._docId,
                                          date: widget._date)));
                                }
                              },
                              {
                                'title': _isEdit ? '수정취소' : '수정하기',
                                'onTap': () {
                                  setState(() {
                                    _isEdit = !_isEdit;
                                  });
                                  Navigator.pop(context);
                                },
                              },
                              {
                                'title': '일기장 재작성',
                                'onTap': () {
                                  Navigator.pop(context);
                                  diaryRef!.delete(); // 기존 일기 삭제
                                },
                              },
                            ],
                          ),
                          Divider(
                            thickness: 2,
                            color: CustomTheme.of(context).alternate,
                          ),
                          Align(
                            alignment: AlignmentDirectional(0, 0),
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
                              child: TextField(
                                readOnly: !_isEdit,
                                controller: _titleController,
                                decoration: InputDecoration(
                                  hintText: '제목',
                                ),
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                style:
                                    CustomTheme.of(context).bodyMedium.override(
                                          fontFamily: 'Readex Pro',
                                          color: Color(0xFF394249),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SelectionArea(
                                  child: Text(
                                '감정 상태: ',
                                style: CustomTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color:
                                          CustomTheme.of(context).secondaryText,
                                      fontSize: 15.sp,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.bold,
                                    ),
                              )),
                              SizedBox(
                                height: 35.h, // 높이 지정
                                width: MediaQuery.of(context).size.width -
                                    (15.sp * 10), // 너비 지정
                                child: buttonListView(sentiment['most']),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                            child: Container(
                              decoration: BoxDecoration(),
                            ),
                          ),
                          Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color:
                                    CustomTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF6D9CC),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Color(0x33000000),
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: AlignmentDirectional(0, 0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16, 16, 16, 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            readOnly: !_isEdit,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            controller: _contentController,
                                            maxLines: null,
                                            style: CustomTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16.h,
                                  ),
                                  SelectionArea(
                                      child: Text(
                                    '하루의 한마디: ',
                                    style: CustomTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Readex Pro',
                                          color: CustomTheme.of(context)
                                              .secondaryText,
                                          fontSize: 15,
                                          letterSpacing: 1,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  )),
                                  SizedBox(
                                    height: 8.h,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 246, 233, 204),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: Color(0x33000000),
                                          offset: Offset(0, 2),
                                        )
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: AlignmentDirectional(0, 0),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          16, 16, 16, 16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextField(
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                            controller: _adviceController,
                                            maxLines: null,
                                            style: CustomTheme.of(context)
                                                .headlineSmall
                                                .override(
                                                  fontFamily: 'Outfit',
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
