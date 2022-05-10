import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ncmb/ncmb.dart';

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
          title: const Text('Google Login App'),
        ),
        body: Center(
            child: _user == null
                // 未ログインの場合
                ? TextButton(
                    child: const Text('Login With Google'),
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
    final googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
    );
    // ログインを実行して結果を受け取る
    final account = await googleSignIn.signIn();
    if (account == null) return;
    final accessToken = (await account.authentication).accessToken;
    // 認証用データの作成
    final data = {'id': account.id, 'access_token': accessToken};
    // ログイン実行
    var user = await NCMBUser.loginWith('google', data);
    // 表示名を追加
    if (user.getString('displayName', defaultValue: '') == '') {
      user.set('displayName', account.displayName!);
      // 更新実行
      await user.save();
    }
    // 表示に反映
    setState(() {
      _user = user;
    });
  }
}
