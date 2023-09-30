import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haru_diary/screens/home_screen_navi.dart';
import 'package:haru_diary/screens/login_signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:haru_diary/provider/common_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // 기기마다 화면 사이즈 달라도 비슷하게 보일 수 있게 screenUtil 사용
      designSize: Size(360, 780), // 화면크기 초기값
      builder: (context, child) => ChangeNotifierProvider(
        // provider 사용하기위해 최상위 위젯에서 감쌈
        create: (context) => CommonProvider(),
        child: MaterialApp(
          title: 'haru_diary',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: StreamBuilder(
            // 로그인 여부에 따라서 홈 화면으로 갈지 로그인 화면으로 갈지 변경
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return HomeScreenNavi();
              }
              return LoginSignupScreen();
            },
          ),
        ),
      ),
    );
  }
}
