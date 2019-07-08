import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:squaad/pages/GroupsPage.dart';
import 'package:squaad/pages/MeetPage.dart';

class BottomNavigationView extends StatefulWidget {
  final List<BottomNavigationBarItem> tabs = [
    BottomNavigationBarItem(
      icon:  Icon(Icons.group),
      title:  Text("Groups"),
    ),
    BottomNavigationBarItem(
      icon:  Icon(Icons.portrait),
      title:  Text("Meet"),
    ),
  ];

  @override
  BottomNavigationViewState createState() => BottomNavigationViewState();
}

class BottomNavigationViewState extends State<BottomNavigationView> {
  int index;
  String title;

  @override
  void initState() {
    super.initState();
    index = 1;
    title = (widget.tabs.first.title as Text).data;
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Center(child: Text(title, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32.0))),
        automaticallyImplyLeading: false,
        actions: <Widget>[PopupMenuButton<String>(
            onSelected: (result) {
              switch(result) {
                case 'edit':
                  Navigator.of(context).pushNamed('/EditProfileRoute');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/SettingsRoute');
                  break;
                case 'logOut':
                  FirebaseAuth.instance.signOut().then(
                          (value) => Navigator.of(context).popAndPushNamed('/AuthRoute'));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(value: 'edit', child: Text('Edit Profile')),
              PopupMenuItem<String>(value: 'settings', child: Text('Settings')),
              PopupMenuItem<String>(value: 'logOut', child: Text('Sign Out'))
            ])],
      ),
      body:  index == 0? GroupsPage() : MeetPage(),
      bottomNavigationBar: Theme(data: Theme.of(context).copyWith(
          canvasColor: Theme.of(context).primaryColor),
        child: BottomNavigationBar(
            currentIndex: index,
            fixedColor: Theme.of(context).accentColor,
            iconSize: 32.0,
            items: widget.tabs,
            onTap: (int index) => setState(() {
              this.index = index;
              title = (widget.tabs[index].title as Text).data;
            })
        ),
      ),
    );
  }
}
