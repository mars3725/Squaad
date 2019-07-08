import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';

class GroupMembersPage extends StatefulWidget {
  final GroupData group;
  GroupMembersPage(this.group);

  @override
  GroupMembersPageState createState() => GroupMembersPageState();
}

class GroupMembersPageState extends State<GroupMembersPage> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<GestureDetector>>(future: getMemberButtons(), builder: (context, snapshot) {
      if (snapshot.hasData) {
        return GridView.count(padding: EdgeInsets.symmetric(vertical: 25), crossAxisCount: 2, children: snapshot.data);
      } else return Center(child: CircularProgressIndicator());
    });

  }

  Future<List<GestureDetector>> getMemberButtons() async {
    List<GestureDetector> membersButtons = List();

    for (int i=0; i < widget.group.users.length; i++) {
      UserData userData = UserData.fromDocument(await widget.group.users[i].get());
      StorageReference imgRef = FirebaseStorage.instance.ref().child(userData.uid+'_0');
      int size = 0;
      try {size = (await imgRef.getMetadata()).sizeBytes;} catch (exception) {print(exception);}
      if (size != 0) userData.photos.add(await imgRef.getData((size)));
      membersButtons.add(GestureDetector(
          onTap: (){},
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            CircleAvatar(radius: 75, backgroundImage: Image.memory(userData.photos.first).image),
            Text(userData.name, style: TextStyle(fontSize: 25),)])));
    }

    membersButtons.add(
        GestureDetector(
            onTap: (){
              if (widget.group.votedUsers.contains(localUserData.docRef)) widget.group.votedUsers.remove(localUserData.docRef);
              else widget.group.votedUsers.add(localUserData.docRef);
              setState(() {});
            },
            child: Column(children: <Widget>[
              Icon(widget.group.votedUsers.contains(localUserData.docRef)? Icons.add_circle : Icons.add_circle_outline,
                  color: widget.group.votedUsers.contains(localUserData.docRef)? Colors.green : Theme.of(context).accentColor, size: 150),
              Text('${widget.group.votedUsers.length}/${widget.group.users.length}')])));
    return membersButtons;
  }
}
