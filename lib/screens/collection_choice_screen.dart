import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/diary/collection_list.dart';  // Make sure to import your CollectionList
import 'package:intl/intl.dart';

import '../custom/custom_app_bar.dart';
import '../custom/custom_top_container.dart';
import '/custom/custom_theme.dart';

class CollectionChoiceScreen extends StatefulWidget {
  const CollectionChoiceScreen({Key? key}) : super(key: key);

  @override
  _CollectionChoiceScreenState createState() => _CollectionChoiceScreenState();
}

class _CollectionChoiceScreenState extends State<CollectionChoiceScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  final _authentication = FirebaseAuth.instance;
  User? loggedUser;
  String? _collectionPath;
  Stream<QuerySnapshot<Map<String, dynamic>>>? _docStream;

  // 추가된 부분: 선택한 문서를 저장할 리스트
  List<DocumentSnapshot> selectedDocs = [];

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getCollectionPath();
    getDocStream();
  }

  void getCurrentUser() {
    final user = _authentication.currentUser;
    if (user != null) {
      loggedUser = user;
    }
  }

   // 원본: getCurrentUser()코드
//   void getCurrentUser() {
//   final user = _authentication.currentUser;
//   try {
//     if (user != null) {
//       loggedUser = user;
//     }
//   } catch (e) {
//     print(e);
//   }
// } 

  void getCollectionPath() {
    _collectionPath = '/user/${loggedUser!.uid}/diary';
  }


  void getDocStream() {
    DateTime now = DateTime.now();
    DateTime lastSunday = now.subtract(Duration(days: now.weekday));
    print(lastSunday);
    String formattedDate = DateFormat('yyyyMMdd').format(lastSunday);
    _docStream = FirebaseFirestore.instance
        .collection(_collectionPath!)
        .orderBy(FieldPath.documentId, descending: false)
        .where(FieldPath.documentId, isGreaterThan: formattedDate)
        .snapshots();
  }
    //원본: void getDocStream() 코드
  //   void getDocStream() {
  //   DateTime now = DateTime.now();
  //   DateTime lastSunday = now.subtract(Duration(days: now.weekday));
  //   print(lastSunday);
  //   String formattedDate = DateFormat('yyyyMMdd').format(lastSunday);
  //   final Stream<QuerySnapshot<Map<String, dynamic>>> chatStream =
  //       FirebaseFirestore.instance
  //           .collection(_collectionPath!)
  //           .orderBy(FieldPath.documentId, descending: false)
  //           .where(FieldPath.documentId, isGreaterThan: formattedDate)
  //           .snapshots();
  //   _docStream = chatStream;
  // }

  void collectSelectedDocs(List<bool> isChecked, List<DocumentSnapshot> docs) {
    selectedDocs.clear();
    for (int i = 0; i < isChecked.length; i++) {
      if (isChecked[i]) {
        selectedDocs.add(docs[i]);
      }
    }
    // 여기에서 selectedDocs를 사용하여 새 컬렉션을 만들 수 있습니다.
  }

  @override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFFAFAFA),
        appBar: CustomAppBar(text: 'Collection'),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: EdgeInsetsDirectional.all(16.h),
            child: Column(
              children: [
                Row(  // 이 부분이 수정되었습니다.
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,  
                  children: [
                    IconButton(
                      icon: Icon(Icons.chevron_left_outlined),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_sweep),
                      onPressed: () {
                        // 삭제 로직
                      },
                    ),
                  ],
                ),
                Divider(
                  thickness: 2,
                  color: CustomTheme.of(context).alternate,
                ),
                Expanded(
                  child: CollectionList(
                    _docStream!,  
                    onSelectedItems: (isChecked, docs) {  
                      collectSelectedDocs(isChecked, docs);
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Logic to handle selected documents in `selectedDocs`
                    // 예) 새 컬렉션을 생성하는 코드
                  },
                  child: Text('collection 생성'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
