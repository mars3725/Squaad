import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geohash/geohash.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:geolocator/geolocator.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/pages/CreateProfilePage.dart';

class AuthPage extends StatefulWidget {
  final bool silentSignIn;

  AuthPage({this.silentSignIn = false});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;

    if (widget.silentSignIn) {
      setState(() => loading = true);
      GoogleAuth().silentSignIn().then((user) async {
        print("Auth State Changed For User: ${user.toString()}");
        if (user != null) {
          await login(user).then((succeeded) async {
            if (succeeded) {
              print("Silent sign in succeeded. Presenting Main");
              await Navigator.of(context).pushNamed('/MainRoute');
            }
          });
        } else print("Silent sign in failed");
      }).whenComplete(() => setState(() => loading = false));
    }
  }

  Future<bool> login(FirebaseUser user) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    DocumentReference docRef = Firestore.instance.document("users/${user.uid}");
    DocumentSnapshot document = await docRef.get();
    if (document.exists) {
      localUserData = UserData.fromDocument(document);
      for (int i=0; i < 3; i++) {
        StorageReference imgRef = FirebaseStorage.instance.ref().child(localUserData.uid+'_$i');
        int size = 0;
        try {size = (await imgRef.getMetadata()).sizeBytes;} catch (exception) {print(exception);}
        if (size != 0) localUserData.photos.add(await imgRef.getData((size)));
      }
      try {

        Position location = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        localUserData.location = Geohash.encode(
            location.latitude, location.longitude,
            codeLength: 6);
      } catch (PlatformException) {
        print('Could not update location');
      }
      localUserData.loginTimestamp = Timestamp.now();
      await localUserData.docRef.updateData({
        'location' : localUserData.location,
        'loginTimestamp': localUserData.loginTimestamp
      });
      return true;
    } else {
      print("No existing userData for id ${user.uid}");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.all(50.0),
                    child: Image.asset("assets/logo.png",
                        width: 200.0)),
                loading
                    ? CircularProgressIndicator()
                    : Column(children: <Widget>[
                  RaisedButton.icon(
                      icon: Image.asset("assets/google.png", height: 50.0),
                      label: Text("Sign In With Google",
                          style: TextStyle(color: Colors.grey)),
                      color: Colors.white,
                      onPressed: () {
                        setState(() => loading = true);
                        GoogleAuth().interactiveSignIn().then((user) async {
                          print(
                              "Auth State Changed For User: ${user.toString()}");
                          if (user != null) {
                            await login(user).then((succeeded) async {
                              if (succeeded) {
                                print(
                                    "Interactive sign in succeeded. Presenting Main");
                                await Navigator.of(context).pushNamed('/MainRoute');
                              } else {
                                print(
                                    "Interactive sign in failed. Creating User");
                                await Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        CreateProfilePage(user)));
                              }
                            });
                          }
                        }).whenComplete(() => setState(() => loading = false));
                      }),
                ])
              ],
            )));
  }
}

class GoogleAuth {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> interactiveSignIn() async {
    FirebaseUser user;
    try {
      GoogleSignInAccount googleUser = await googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      user = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken));
      print("User ${user.uid} signed in with interface");
    } catch (error) {
      print("Interactive sign in error: $error");
    }
    return user;
  }

  Future<FirebaseUser> silentSignIn() async {
    FirebaseUser user;
    try {
      GoogleSignInAccount googleUser = await googleSignIn.signInSilently();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      user = await FirebaseAuth.instance.signInWithCredential(
          GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken));
      print("User ${user.uid} signed in silently");
    } catch (error) {
      print("Silent sign in error: $error");
    }
    return user;
  }
}

class TwitterAuth {
  //TODO: Implement twitter authentication
}

class FacebookAuth {
  //TODO: Implement facebook authentication
}
