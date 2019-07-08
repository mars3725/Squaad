import 'dart:async';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/pages/CreateEventPage.dart';
import 'package:squaad/pages/EventPage.dart';

class GroupEventsPage extends StatefulWidget {
  final GroupData group;
  GroupEventsPage(this.group);

  @override
  GroupEventsPageState createState() => GroupEventsPageState();
}

class GroupEventsPageState extends State<GroupEventsPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(floatingActionButton: FloatingActionButton(child: Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateEventPage(widget.group))).
        then((event) => setState(() {
                  if (event != null) widget.group.events.add(event.docRef);
                  widget.group.docRef.updateData({'events': widget.group.events});
        }))),
        body: FutureBuilder<List<GestureDetector>>(future: getEvents(), builder: (context, snapshot) {
      if (snapshot.hasData) {
        if (snapshot.data.isEmpty) return Center(child: Text('No events for this group. Create One!'));
        else return GridView.count(childAspectRatio: 1, padding: EdgeInsets.symmetric(vertical: 25), crossAxisCount: 2, children: snapshot.data);
      } else return Center(child: CircularProgressIndicator());
    }));

  }

  Future<List<GestureDetector>> getEvents() async {
    List<GestureDetector> events = List();

    for (int i=0; i < widget.group.events.length; i++) {
      EventData eventData = EventData.fromDocument(await widget.group.events[i].get());
      StorageReference imgRef = FirebaseStorage.instance.ref().child(eventData.uid);
      int size = 0;
      try {size = (await imgRef.getMetadata()).sizeBytes;} catch (exception) {print(exception);}
      if (size != 0) eventData.photo = await imgRef.getData((size));
      events.add(GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => EventPage(eventData))),
          child: Card(semanticContainer: true, color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                eventData.photo == null? Container() : Image.memory(eventData.photo, height: 100, fit: BoxFit.cover),
                Align(alignment: Alignment.bottomCenter, child: Column(children: <Widget>[
                  Text(eventData.name, style: TextStyle(fontSize: 24)),
                  Text(DateFormat("MMMM d\nh:mma").format(eventData.eventTimestamp.toDate()), textAlign: TextAlign.center, style: TextStyle(fontSize: 24))
                ])),
              ]))
      ));
    }
    return events;
  }
}
