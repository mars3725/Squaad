import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/PhotoEditor.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({Key key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  GlobalKey<FormState> _formKey = GlobalKey();

  _EditProfilePageState();

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
        appBar: AppBar(title: new Text('My Profile')),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: WillPopScope(
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Flexible(
                            child: AspectRatio(
                                aspectRatio: 1.0,
                                child: PhotoEditor())),
                        TextFormField(
                            initialValue: localUserData.name,
                            style: TextStyle(
                                fontSize: 36.0, color: Colors.black),
                            textAlign: TextAlign.center,
                            onSaved: (value) =>
                            localUserData.name = value),
                        TextFormField(
                            initialValue: localUserData.bio,
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.black),
                            textAlign: TextAlign.center,
                            onSaved: (value) =>
                            localUserData.bio = value)
                      ]),
                ),
                onWillPop: () async {
                  if (localUserData.photos.isEmpty || localUserData.name.isEmpty) return false;
                  else {
                    _formKey.currentState.save();
                    localUserData.docRef.updateData(<String, dynamic>{
                      'name': localUserData.name,
                      'bio': localUserData.bio,
                    });
                    for (int i = 0; i < 3; i++)
                      FirebaseStorage.instance.ref().child(localUserData.uid + '_$i').delete().catchError((error) {});

                    for (int i = 0; i < localUserData.photos.length; i++)
                      FirebaseStorage.instance.ref().child(localUserData.uid + '_$i').putData(localUserData.photos[i]);
                    return true;
                  }
                })));
  }
}
