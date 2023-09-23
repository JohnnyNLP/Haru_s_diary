import '../api/functions.dart';
import '../custom/custom_app_bar.dart';
import '../custom/custom_theme.dart';
import '../custom/custom_top_container.dart';
import '../custom/custom_widgets.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen(this._date, this._write, {Key? key}) : super(key: key);
  final String _date;
  final bool _write;

  @override
  _DiaryScreenState createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _adviceController = TextEditingController();

  // String? _diaryId;
  final emotion = false;
  final _authentication = FirebaseAuth.instance; //Firebase 인증 객체 생성
  User? loggedUser;
  DocumentReference? diaryRef;
  // todo: 현재 하루에 대화 하나 일기 하나 구조로 만들어둠.
  // 이후에 여러개 할 수 있게 수정해야함. 시간 없어서 일단 ㄱㄱ
  bool _isLoading = false; // 로딩 상태를 나타내는 변수

  @override // 아래 void initState()는 초기 상태 설정 메서드. 사용자 정보, 문서 레퍼런스, 일기 내용을 불러옴
  void initState() {
    super.initState();
    _getCurrentUser();
    _getDocumentReference();
    _fetchDiary();
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
    diaryRef = FirebaseFirestore.instance
        .collection('user')
        .doc(loggedUser!.uid)
        .collection('diary')
        .doc(widget._date);
  }

  Future<void> _fetchDiary() async {
    DocumentSnapshot documentSnapshot = await diaryRef!.get();
    if (documentSnapshot.data() == null && widget._write) {
      _toggleLoading();

      // var returnValue =
      await func.callFunctions('writeDiary', {'date': widget._date});

      // _titleController.text = returnValue['title'];
      // _contentController.text = returnValue['diary'].toString().trim();
      // _adviceController.text = returnValue['advice'] ?? '';
      // print(returnValue['sentiment']);

      documentSnapshot = await diaryRef!.get();

      _toggleLoading();
    }
    if (documentSnapshot.data() != null) {
      Map<String, dynamic> diary =
          documentSnapshot.data() as Map<String, dynamic>;
      _titleController.text = diary['title'] ?? 'No title';
      _contentController.text = diary['content'] != null
          ? diary['content'].toString().trim()
          : 'No content';
      _adviceController.text = diary['advice'] ?? 'No advice';
    }
  }

  // 일기를 Firestore에 업데이트 하는 메서드
  Future<void> _updateDiary(
      {String? title, String? content, String? advice}) async {
    await diaryRef!.set(
      {
        'title': title ?? _titleController.text,
        'content': content ?? _contentController.text,
        'advice': advice ?? _adviceController.text,
        'time': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
  }

  // Widget _buildListView(List<String> items) {
  //   return ListView.builder(
  //     itemCount: items.length,
  //     itemBuilder: (BuildContext context, int index) {
  //       return ListTile(
  //         title: Text(items[index]),
  //       );
  //     },
  //   );
  // }

  Widget createButton(text, color) {
    return FFButtonWidget(
      onPressed: () {
        print('Button pressed ...');
      },
      text: text,
      options: FFButtonOptions(
        height: 33,
        padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
        iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
        color: color,
        textStyle: CustomTheme.of(context).titleSmall.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              fontSize: 8,
            ),
        elevation: 3,
        borderSide: BorderSide(
          color: Colors.transparent,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // UI를 빌드하는 메서드
  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTopContainer(
                      sText: 'Back',
                      sIcon: Icons.chevron_left_outlined,
                      sOnPressed: () {
                        Navigator.pop(context);
                      },
                      eText: '수정하기',
                      eIcon: Icons.create_outlined,
                      eOnPressed: () async {
                        _toggleLoading();
                        await _updateDiary();
                        _toggleLoading();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                    Divider(
                      thickness: 2,
                      color: CustomTheme.of(context).alternate,
                    ),
                    Align(
                      alignment: AlignmentDirectional(0, 0),
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
                        child: TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: '제목',
                          ),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: CustomTheme.of(context).bodyMedium.override(
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
                          style: CustomTheme.of(context).bodyMedium.override(
                                fontFamily: 'Readex Pro',
                                color: CustomTheme.of(context).secondaryText,
                                fontSize: 15,
                                letterSpacing: 1,
                                fontWeight: FontWeight.bold,
                              ),
                        )),
                        // _buildListView(['긍정']),
                        SizedBox(
                          height: 35, // 높이 지정
                          width:
                              MediaQuery.of(context).size.width - 110, // 너비 지정
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              createButton('긍정', Color(0xB1009D36)),
                              SizedBox(width: 8),
                              createButton('우울', Color(0xA2151AB4)),
                            ],
                          ),
                        ),
                        // createButton('긍정', Color(0xB1009D36)),
                        // SizedBox(width: 8),
                        // createButton('우울', Color(0xA2151AB4)),
                        // SizedBox(width: 8),
                        // createButton('분노', Color(0xA2151AB4)),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 8),
                      child: Container(
                        decoration: BoxDecoration(),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: CustomTheme.of(context).secondaryBackground,
                          // boxShadow: [
                          //   BoxShadow(
                          //     blurRadius: 4,
                          //     color: Color(0x33000000),
                          //     offset: Offset(0, 2),
                          //   )
                          // ],
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextField(
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
                              height: 14,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
  }
}
