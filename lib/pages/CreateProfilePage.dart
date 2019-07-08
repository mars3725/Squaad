import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:geohash/geohash.dart';
import 'package:geolocator/geolocator.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/PhotoEditor.dart';

class _CreateProfilePageState extends State<CreateProfilePage> {
  GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    localUserData = UserData(widget.user.uid,
        name: widget.user.displayName.split(" ").first,
        email: widget.user.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Welcome')),
        floatingActionButton: FloatingActionButton(child: Icon(Icons.check),
            onPressed: () {
              SystemChannels.textInput.invokeMethod("TextInput.hide");
              FocusScope.of(context).requestFocus(FocusNode());
              _formKey.currentState.save();
              if (localUserData.name.isNotEmpty &&
                  localUserData.email.isNotEmpty &&
                  localUserData.photos.isNotEmpty)
                createProfile().then((_) => Navigator.of(context).pushNamed('/MainRoute'),
                    onError: ()=> print('Failded to initialize metadata'));
            }),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(child: PhotoEditor()),
                    TextFormField(decoration: InputDecoration(labelText: 'Name'),
                        initialValue: localUserData.name,
                        onSaved: (value) => localUserData.name = value),
                    TextFormField(decoration: InputDecoration(labelText: 'Email'),
                        initialValue: localUserData.email,
                        onSaved: (value) => localUserData.email = value),
                    TextFormField(decoration: InputDecoration(labelText: 'Bio'),
                        maxLines: 2,
                        initialValue: localUserData.bio,
                        onSaved: (value) => localUserData.bio = value),
                  ])
            )));
  }

  Future<void> createProfile() async {
    Position location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    localUserData.location = Geohash.encode(
        location.latitude, location.longitude,
        codeLength: 6);
    localUserData.loginTimestamp = Timestamp.now();

    await localUserData.docRef.setData(<String, dynamic>{
      'uid' : localUserData.uid,
      'name': localUserData.name,
      'email' : localUserData.email,
      'bio': localUserData.bio,
      'location': localUserData.location,
      'loginTimestamp': localUserData.loginTimestamp,
      'groups': localUserData.groups,
      'likes': localUserData.likes
    });

    for(int i=0; i<localUserData.photos.length; i++) FirebaseStorage.instance.ref().child(localUserData.uid+'_$i').putData(localUserData.photos[i]);
  }
}


class CreateProfilePage extends StatefulWidget {
  final FirebaseUser user;
  final GlobalKey<FormState> _formKey = GlobalKey();
  CreateProfilePage(this.user);

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}