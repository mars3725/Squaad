import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/pages/GroupEventsPage.dart';
import 'package:squaad/pages/GroupMembersPage.dart';
import 'package:squaad/pages/MessagesPage.dart';

class GroupTabView extends StatefulWidget {
  final GroupData group;

  GroupTabView(this.group);

  @override
  GroupTabViewState createState() => GroupTabViewState();
}

class GroupTabViewState extends State<GroupTabView> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            actions: <Widget>[PopupMenuButton<String>(
                onSelected: (result) {
                  switch(result) {
                    case 'leave':
                      widget.group.users.remove(localUserData.docRef);
                      widget.group.votedUsers.remove(localUserData.docRef);
                      widget.group.docRef.updateData({
                        'users': widget.group.users,
                        'votedUsers': widget.group.votedUsers});
                      localUserData.groups.remove(widget.group.docRef);
                      widget.group.users.forEach((doc) => localUserData.likes.remove(doc));
                      //TODO: Possibly make likes remove after group creation
                      localUserData.docRef.updateData({
                        'groups': localUserData.groups,
                        'likes': localUserData.likes});
                      Navigator.pop(context);
                      break;
                    case 'rename':
                      showDialog<String>(context: context, builder: (context) => SimpleDialog(
                        title: Text("Rename your Squaad"),
                        children: <Widget>[
                          TextField(controller: TextEditingController(text: widget.group.name), textAlign: TextAlign.center, onSubmitted: (value)=> Navigator.pop(context, value))
                        ])).then(
                              (value) {
                                if (value != null) {
                                  widget.group.docRef.updateData({'name': value});
                                  setState(() => widget.group.name = value);
                                }
                              });
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'leave', child: Text('Leave')),
                  PopupMenuItem<String>(value: 'rename', child: Text('Rename'))
                ])],
          title: Text(widget.group.name),
          bottom: TabBar(
            tabs: [
              Tab(text: "Messages"),
              Tab(text: "Members"),
              Tab(text: "Events"),
            ],
          ),
        ),
        body: TabBarView(children: [
          MessagesPage(widget.group),
          GroupMembersPage(widget.group),
          GroupEventsPage(widget.group),
        ]),
      ),
    );
  }
}
