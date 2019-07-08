import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';

class MessagesPage extends StatefulWidget {
  final GroupData groupData;

  const MessagesPage(this.groupData);

  @override
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<MessageData> messages = List();
  String messageText = '';

  @override
  void initState() {
    super.initState();
    getMessages().then((messages) => messages.addAll(messages));
    widget.groupData.messagesRef.snapshots().listen((data) => print(data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Column(mainAxisAlignment: MainAxisAlignment.end,children: List<Widget>.generate(messages.length, (i) => Row(children: <Widget>[
      Text(messages[i].content)],))..add(Divider())
      ..add(Row(children: <Widget>[
        Expanded(child: Padding(padding: EdgeInsets.symmetric(vertical: 5), child: TextField(onChanged: (text) => messageText = text, onSubmitted: (text) => sendMessage(), decoration: InputDecoration(hintText: 'Type a message...'),))),
        GestureDetector(child: Icon(Icons.send), onTap: () => sendMessage())]))));
  }

  Future<List<MessageData>> getMessages({MessageData cursor}) async {
    Query query = widget.groupData.messagesRef.orderBy('timestamp', descending: true).limit(25);
    if (cursor != null) query.startAfter([cursor.timestamp]);
    List<MessageData> messageDataList = List();
    QuerySnapshot ref = await query.getDocuments();
    for(int i=0; i < ref.documents.length; i++) messageDataList.add(MessageData.fromDocument(ref.documents[i]));
    return messageDataList;
  }

  void sendMessage() {
    widget.groupData.messagesRef.add({
      "content": messageText,
      "creator": localUserData.docRef,
      "timestamp": Timestamp.now(),
      "likes": List()
    });
  }
}
