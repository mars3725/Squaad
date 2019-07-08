import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squaad/Data.dart';

class EventPage extends StatefulWidget {
  final EventData eventData;

  const EventPage(this.eventData);

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('New Event')),
    body: Column(
      children: <Widget>[
        widget.eventData.photo == null? Container() : Image.memory(widget.eventData.photo),
        Text(widget.eventData.name),
        Text(widget.eventData.location),
        Text(DateFormat("EEEE, MMMM d, yyyy 'at' h:mma").format(widget.eventData.eventTimestamp.toDate())),
        Text(widget.eventData.description),
        Row(children: <Widget>[Text('Going'), FutureBuilder<Row>(future: createUsersRow(widget.eventData.going), builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data;
          else return CircularProgressIndicator();
        })]),
        Row(children: <Widget>[Text('Undecided'), FutureBuilder<Row>(future: createUsersRow(widget.eventData.undecided), builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data;
          else return CircularProgressIndicator();
        })]),
        Row(children: <Widget>[Text('Not Going'), FutureBuilder<Row>(future: createUsersRow(widget.eventData.notGoing), builder: (context, snapshot) {
          if (snapshot.hasData) return snapshot.data;
          else return CircularProgressIndicator();
        })])
      ],
    ),
    );
  }

  Future<Row> createUsersRow(List<DocumentReference> userReferences) async {
    List userPhotos = List();
    for (int i=0; i < userReferences.length; i++) {
      UserData userData = UserData.fromDocument(await userReferences[i].get());
      StorageReference imgRef = FirebaseStorage.instance.ref().child(userData.uid+'_0');
      int size = 0;
      try {size = (await imgRef.getMetadata()).sizeBytes;} catch (exception) {print(exception);}
      if (size != 0) userData.photos.add(await imgRef.getData((size)));
      List children = [CircleAvatar(backgroundImage: Image.memory(userData.photos.first).image)];
      if (widget.eventData.creator == userReferences[i]) children.add(Align(alignment: Alignment.bottomRight, child: Icon(Icons.star)));
      if (children.length == 1) userPhotos.add(children.single);
      else  userPhotos.add(Stack(children: children));
    }
    return Row(children: userPhotos);
  }
}
