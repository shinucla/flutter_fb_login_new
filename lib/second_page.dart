import 'dart:convert'; // for using jsonDecode()
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'config.dart';

class SecondPage extends StatefulWidget {
  @override SecondPageState createState() => new SecondPageState();
}

class SecondPageState extends State<SecondPage> {
  final storage = new FlutterSecureStorage();

  bool isAuthenticated = false;
  bool isLoggedIn = false;

  String accessToken = '';
  String jwt = "";
  Map<String, dynamic> user = {};

  @override void initState() {
    super.initState();
    this.initStoredValuesAsyc();
  }

  @override Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First App',
      home: Scaffold(
	appBar: AppBar( title: Text('Facebook Login') ),
	body: Container(
	  child: Center(child: isAuthenticated
			? (isLoggedIn
			   ? RaisedButton(child: Text('Login Out, ${this.user["first_name"]} ${this.user["last_name"]}!'),
					  onPressed: () => initLogout())
			   : RaisedButton(child: Text('Login in'), onPressed: () => initLogin()))
			: RaisedButton(child: Text('Auth with FB'), onPressed: () => initFBAuth()))

	)
      )
    );
  }

  void initStoredValuesAsyc() async {
    var token = await this.storage.read(key: Config.FSS_KEY_FB_TOKEN);
    var jwt = await this.storage.read(key: Config.FSS_KEY_JWT);
    var user = await this.storage.read(key: Config.FSS_KEY_USER);

    setState(() {
      this.accessToken = token;
      this.jwt = jwt;
      this.isAuthenticated = null == token ? false : true;
      this.isLoggedIn = null == jwt ? false : true;
      this.user = null == user ? {} : jsonDecode(user);
    });
  }

  void initFBAuth() async {
    var fb = FacebookLogin();
    var res = await fb.logInWithReadPermissions(['email']);

    switch (res.status) {
    case FacebookLoginStatus.error:
      print("Error: " + res.errorMessage);
      onAuthStatusChanged(res, false);
      break;

    case FacebookLoginStatus.cancelledByUser:
      print("Cancelled by user");
      onAuthStatusChanged(res, false);
      break;

    case FacebookLoginStatus.loggedIn:
      print("Authed");
      onAuthStatusChanged(res, true);
      break;
    }
  }

  void initLogin() async {
    var url = "${Config.APP_SERVER_URL}user/api/loginByFacebook";
    var res = await http.post(url, body: { "token": this.accessToken });

    if (200 == res.statusCode) {
      var body = jsonDecode(res.body);

      if (null != body['error']) {
	print('NOT Logged in');

      } else {
	/* decode user from jwt */
	var jwt = body['data']['jwt'];
	var base64 = jwt.split('.')[1].replaceAll('-', '+').replaceAll('_', '/');
	base64 = base64.padRight(base64.length + (4 - base64.length % 4) % 4, '='); // pading '=' so the len is multiple of 4
	var decode = Utf8Codec().fuse(Base64Codec()).decode(base64);
	var user = jsonDecode(decode);
	
	storeKeyValue(Config.FSS_KEY_JWT, jwt);
	storeKeyValue(Config.FSS_KEY_USER, jsonEncode(user));
	setState(() {
	  this.jwt = jwt;
	  this.isLoggedIn = null == jwt ? false : true;
	  this.user = user;
	});
      }

    } else {
      print('NOT Logged in');
    }
  }

  void initLogout() async {
    setState(() {
      this.jwt = null;
      this.isLoggedIn = false;
      this.user = {};
      () async {
	await this.storage.delete(key: Config.FSS_KEY_USER);
	await this.storage.delete(key: Config.FSS_KEY_JWT);
      }();
    });
  }

  void onAuthStatusChanged(res, bool isAuthenticated) {
    setState(() {
      this.isAuthenticated = isAuthenticated;
      if (isAuthenticated) {
	print(res.accessToken.token);
	this.accessToken = res.accessToken.token;
	storeKeyValue(Config.FSS_KEY_FB_TOKEN, this.accessToken);
      }
    });
  }

  void storeKeyValue(key, value) async {
    await this.storage.write(key: key, value: value);
  }
}
