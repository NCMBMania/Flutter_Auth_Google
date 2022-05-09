import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:ncmb/ncmb.dart';
import 'package:intl/intl.dart';

void main() {
  // NCMBの初期化
  NCMB('YOUR_APPLICATION_KEY', 'YOUR_CLIENT_KEY');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NCMBUser? _user;

  @override
  void initState() {
    super.initState();
    Future(() async {
      // 現在ログインしているユーザー情報（未ログインの場合はnull）を取得
      final user = await NCMBUser.currentUser();
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Facebook Login App'),
        ),
        body: Center(
            child: _user == null
                // 未ログインの場合
                ? TextButton(
                    child: const Text('Login With Facebook'),
                    onPressed: login,
                  )
                // ログインしている場合
                : TextButton(
                    child: Text(
                        'Logged in by ${_user!.getString('displayName', defaultValue: 'No name')}'),
                    onPressed: logout,
                  )),
      ),
    );
  }

  // ログアウト処理
  logout() async {
    await NCMBUser.logout();
    setState(() {
      _user = null;
    });
  }

  // ログイン処理
  login() async {
    final result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final now = DateTime.now();
      final expirationDate = now.add(const Duration(days: 30));
      final userData = await FacebookAuth.instance.getUserData();
      final format = DateFormat("yyyy-MM-ddTHH:mm:ss.S'Z'");
      // リクエストデータの組立
      final data = {
        'id': userData['id'].toString(),
        'access_token': result.accessToken!.token,
        'expiration_date': {
          '__type': 'Date',
          'iso': format.format(expirationDate)
        }
      };
      // ログイン実行
      var user = await NCMBUser.loginWith('facebook', data);
      // 表示名を追加
      user.set('displayName', userData['name']);
      // 更新実行
      await user.save();
      // 表示に反映
      setState(() {
        _user = user;
      });
    } else {
      debugPrint(result.status.toString());
      debugPrint(result.message);
    }
  }
}
