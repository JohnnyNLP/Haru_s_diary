import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/chart/chart_category_screen.dart';
import 'package:haru_diary/chart/chart_model.dart';
import 'package:haru_diary/custom/custom_theme.dart';
import 'package:haru_diary/provider/common_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SentimentChart extends StatefulWidget {
  SentimentChart({required this.key, required this.navigatorKey})
      : super(key: key);
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<SentimentChartState> key;

  @override
  State<SentimentChart> createState() => SentimentChartState();
}

class SentimentChartState extends State<SentimentChart> {
  List<dynamic> sentiments = [];
  List<Category> categories = [];
  List<SubCategory> subCategories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getSentiment();
  }

  Future getSentiment() async {
    setState(() {
      isLoading = true;
    });

    sentiments.clear();
    categories.clear();
    subCategories.clear();

    // 현재 날짜와 30일 전의 날짜를 가져옵니다.
    DateTime today = DateTime.now();
    DateTime thirtyDaysAgo = today.subtract(Duration(days: 30));
    final userId = Provider.of<CommonProvider>(context, listen: false)
        .getCurrentUser()
        .uid;

    // Firestore의 인스턴스를 가져옵니다.
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collection =
        firestore.collection('user').doc(userId).collection('diary');

    // 원하는 쿼리를 실행합니다.
    QuerySnapshot querySnapshot = await collection
        .where('date',
            isGreaterThanOrEqualTo:
                DateFormat('yyyyMMdd').format(thirtyDaysAgo))
        .get();

    // 각 문서에서 'sentiment' 필드값만 가져와서 리스트에 추가합니다.

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      var sentiment = doc['sentiment'];
      if (sentiment != null) {
        sentiments.add(sentiment);
      }
    }

    // 감정태그 8개
    Map<String, num> monthSentiment = {
      '우울': 0,
      '분노': 0,
      '슬픔': 0,
      '기대': 0,
      '열정': 0,
      '기쁨': 0,
      '애정': 0,
      '불쾌': 0
    };

    // 30일간의 감정분석결과를 합산
    for (Map<String, dynamic> sentiment in sentiments) {
      sentiment.forEach((key, value) {
        if (monthSentiment.containsKey(key))
          monthSentiment[key] = (monthSentiment[key] ?? 0) + value;
      });
    }

    void convertToPercentage(Map<String, num> map) {
      num total =
          map.values.fold(0, (prev, curr) => prev + curr); // 모든 값을 합합니다.

      map.forEach((key, value) {
        map[key] = (value / total) * 100; // 백분위 값으로 변환합니다.
      });
    }

    // 차트 그리기 위해 백분위 값으로 변환
    convertToPercentage(monthSentiment);
    // print(monthSentiment);

    // 값 기준으로 내림차순 정렬
    List<MapEntry<String, num>> sortedEntries = monthSentiment.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    Map<String, num> sortedMap = Map<String, num>.fromEntries(sortedEntries);

    // print(sortedMap);

    // 차트에 필요한 자료구조로 변경
    sortedMap.forEach(
      (key, value) {
        if (value >= 10) {
          categories.add(
            Category(
              title: key,
              color: CustomTheme.of(context).sentimentColor[key]!,
              subCategories: [
                SubCategory(
                    title: key,
                    color: CustomTheme.of(context).sentimentColor[key]!,
                    operations: [value as double]),
              ],
            ),
          );
        } else {
          // 값이 20 미만인 감정태그들은 기타로 분류
          subCategories.add(
            SubCategory(
                title: key,
                color: CustomTheme.of(context).sentimentColor[key]!,
                operations: [value as double]),
          );
        }
      },
    );

    categories.add(
      Category(
        title: '기타',
        color: Color.fromARGB(255, 115, 214, 168),
        subCategories: subCategories,
      ),
    );

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Container()
        : SingleChildScrollView(
            child: Container(
              height: 580.h,
              child: WillPopScope(
                onWillPop: () async {
                  if (widget.navigatorKey.currentState!.canPop()) {
                    widget.navigatorKey.currentState!.pop();
                  }
                  return false;
                },
                child: Navigator(
                  key: widget.navigatorKey,
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) =>
                          CategoryScreen(categories: categories),
                    );
                  },
                ),
              ),
            ),
          );
  }
}
