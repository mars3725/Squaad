import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/Profile.dart';
import 'package:squaad/UserGenerator.dart';

class MatchPage extends StatefulWidget {
  final Profile otherProfile;

  MatchPage(this.otherProfile);

  @override
  MatchPageState createState() => MatchPageState();
}

class MatchPageState extends State<MatchPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 50.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Padding(padding: EdgeInsets.all(25.0), child: Text('Its A Match!', style: TextStyle(fontSize: 36.0))),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                Expanded(child: Padding(padding: EdgeInsets.all(5.0),
                    child: AspectRatio(aspectRatio: 1.0,
                        child: CircleAvatar(backgroundImage: Image.memory(localUserData.photos.first).image)))),
                Expanded(child: Padding(padding: EdgeInsets.all(5.0),
                    child: AspectRatio(aspectRatio: 1.0,
                        child: CircleAvatar(backgroundImage: Image.memory(widget.otherProfile.userData.photos.first).image)))),
              ]),
              RaisedButton(child: Text("Make a Squaad"), color: Theme.of(context).backgroundColor,
                    onPressed: () {
                      GroupData groupData = GroupData(generateId(27),
                          name: "${localUserData.name} & ${widget.otherProfile.userData.name}'s Squaad",
                          users: [localUserData.docRef, widget.otherProfile.userData.docRef]);
                      groupData.docRef.setData({
                        'uid': groupData.uid,
                        'name': groupData.name,
                        'users': groupData.users,
                        'events': groupData.events,
                        'votedUsers': groupData.votedUsers
                      });
                      localUserData.groups.add(groupData.docRef);
                      localUserData.docRef.updateData(<String, dynamic>{
                        'groups': localUserData.groups
                      });
                      Navigator.of(context).pop();
                    }),
                RaisedButton(child: Text("Pass"), color: Theme.of(context).backgroundColor,
                    onPressed: ()=> Navigator.of(context).pop())
            ])));
  }
}

