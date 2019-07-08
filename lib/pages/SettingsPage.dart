import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/UserGenerator.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsPageState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {

    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: new Text('Settings')),
        body: WillPopScope(child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0), child: Text('Email: ')),
                Expanded(child: TextField(
                    controller: TextEditingController(text: localUserData.email),
                    onChanged: (value) => localUserData.email = value))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0), child: Text('Location (Geohash): ')),
                Expanded(child: Text(localUserData.location))
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: <Widget>[
                Padding(padding: EdgeInsets.all(10.0), child: Text('Last Login: ')),
                Expanded(child: Text(localUserData.loginTimestamp.toDate().toIso8601String()))
              ]),
              RaisedButton(child: Text("Generate User"),
                  onPressed: () => generateUser(register: true)),
              RaisedButton(child: Text("Delete Profile"),
                  onPressed: () async {
                    await localUserData.docRef.delete();
                    for(int i=0; i< localUserData.photos.length; i++) {
                      await FirebaseStorage.instance.ref().child('${localUserData.uid}_$i.jpg').delete().catchError((error) {});
                    }
                    FirebaseAuth.instance.signOut().then((value)=>
                        Navigator.of(context).popAndPushNamed('/AuthRoute')
                    );
                  }),
            ]),
            onWillPop: () async {
              localUserData.docRef.updateData(<String, dynamic>{
                'email' : localUserData.email,
              });
              return true;
            })
    );
  }
}
