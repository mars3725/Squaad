import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/pages/GroupTabView.dart';

class GroupsPage extends StatefulWidget {
  GroupsPage({Key key}) : super(key: key);

  @override
  GroupsPageState createState() => GroupsPageState();
}

class GroupsPageState extends State<GroupsPage> {

  @override
  Widget build(BuildContext context) {
    if (localUserData.groups.isEmpty) return Center(child: Text("You're not part of any groups!"));
    else return FutureBuilder<List<GroupData>>(future: getGroups(),
        builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView.separated(
            itemBuilder: (context, index) => FlatButton(child: Align(alignment: Alignment.centerLeft,
                child: Text(snapshot.data[index].name, style: TextStyle(fontSize: 18), overflow: TextOverflow.ellipsis)),
                onPressed: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupTabView(snapshot.data[index])))),
            separatorBuilder: (context, index) => Divider(height: 0),
            itemCount: localUserData.groups.length);
      } else return Center(child: CircularProgressIndicator());
    });
  }

  Future<List<GroupData>> getGroups() async {
    List<GroupData> groupDataList = List();
    for(int i=0; i < localUserData.groups.length; i++) groupDataList.add(GroupData.fromDocument(await localUserData.groups[i].get()));
    return groupDataList;
  }
}
