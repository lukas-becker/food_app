
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom;

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About this App"),
        //actions: [IconButton(icon: Icon(Icons.close), onPressed: () {Navigator.pop(context);})],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: MediaQuery.of(context).size.width,height: 40),
            Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Colors.white, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5),spreadRadius: 5,blurRadius: 7,offset: Offset(0, 3))]), child: Padding(padding: EdgeInsets.all(10), child: Image.asset('images/logo.png', width: 100,),),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 30),
            Text("Snack Hunter", style: TextStyle(fontSize: 30),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 30),
            Text("A Project by:", style: TextStyle(fontSize: 24),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            Text("Lukas Becker", style: TextStyle(fontSize: 20),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            Text("Nico Miller", style: TextStyle(fontSize: 20),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            Text("Jonas Sperling", style: TextStyle(fontSize: 20),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 30),
            Text("Licenses:", style: TextStyle(fontSize: 16),),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 Food Vector by Vecteezy', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://www.vecteezy.com/free-vector/food')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 http Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/dart-lang/http/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 url_launcer Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/flutter/plugins/blob/master/packages/url_launcher/url_launcher/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 flutter_slideable Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/letsar/flutter_slidable/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 path_provider Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/flutter/plugins/blob/master/packages/path_provider/path_provider/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 sqflite Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/tekartik/sqflite/blob/master/sqflite/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 path Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/dart-lang/path/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 powerset Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/hterkelsen/powerset/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 smart_select Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/davigmacode/flutter_smart_select/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 html Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/Sub6Resources/flutter_html/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 Firebase Core Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_core/firebase_core/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 firebase_database Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/FirebaseExtended/flutterfire/blob/master/packages/firebase_database/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 flutter_custom_tabs Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/droibit/flutter_custom_tabs/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 uuid Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/Daegalus/dart-uuid/blob/master/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 5),
            InkWell(
                child: new Text('🔗 share Libary', style: TextStyle(fontSize: 16),),
                onTap: () => _launchURL(context, 'https://github.com/flutter/plugins/blob/master/packages/share/LICENSE')
            ),
            SizedBox(width: MediaQuery.of(context).size.width,height: 40),
          ],
        ),
      )
    );
  }

  ///Launch url in Chrome Custom Tab
  _launchURL(BuildContext context, String url) async {
    try {
      await custom.launch(
        url,
        option: new custom.CustomTabsOption(
            toolbarColor: Theme.of(context).primaryColor,
            enableDefaultShare: true,
            enableUrlBarHiding: true,
            showPageTitle: true,
            animation: new custom.CustomTabsAnimation.slideIn()),
      );
    } catch (e) {
      // An exception is thrown if browser app is not installed on Android device.
      debugPrint(e.toString());
    }
  }
}