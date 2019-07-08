import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

UserData localUserData;

class UserData {
  String uid, name, email, bio, location;
  Timestamp loginTimestamp;
  List<DocumentReference> groups, likes;
  List<Uint8List> photos;
  DocumentReference docRef;

  UserData(this.uid, {
    this.name = '',
    this.email = '',
    this.bio = '',
    this.location = '',
    this.loginTimestamp, this.groups, this.likes, this.photos}) {
    if (loginTimestamp == null) loginTimestamp = Timestamp.now();
    if (groups == null) groups = List<DocumentReference>();
    if (likes == null) likes = List<DocumentReference>();
    if (photos == null) photos = List<Uint8List>();
    docRef = Firestore.instance.document('users/$uid');
  }

  UserData.fromDocument(DocumentSnapshot document) {
    uid = document.documentID;
    name = document.data['name'];
    email = document.data['email'];
    bio = document.data['bio'];
    location = document.data['location'];
    loginTimestamp = document.data['loginTimestamp'];
    likes = document.data['likes'].cast<DocumentReference>().toList();
    groups = document.data['groups'].cast<DocumentReference>().toList();
    photos = List<Uint8List>();
    docRef = document.reference;
  }
}

class GroupData {
  String uid, name;
  List<DocumentReference> users, events, votedUsers;
  DocumentReference docRef;
  CollectionReference messagesRef;

  GroupData(this.uid, {
    this.name = '',
    this.users, this.events, this.votedUsers}) {
    if (users == null) users = List();
    if (events == null) events = List();
    if (votedUsers == null) votedUsers = List();
    docRef = Firestore.instance.document('groups/$uid');
    messagesRef = docRef.collection('messages');
  }

  GroupData.fromDocument(DocumentSnapshot document) {
    uid = document.documentID;
    name = document.data['name'];
    users = document.data['users'].cast<DocumentReference>().toList();
    events = document.data['events'].cast<DocumentReference>().toList();
    votedUsers = document.data['votedUsers'].cast<DocumentReference>().toList();
    docRef = document.reference;
    messagesRef = docRef.collection('messages');
  }
}

class MessageData {
  String uid, content;
  DocumentReference creator;
  Timestamp timestamp;
  List<DocumentReference> likes;

  MessageData(this.creator, {
    this.content = '',
    this.timestamp, this.likes}) {
    if (timestamp == null) timestamp = Timestamp.now();
    if (likes == null) likes = List();
  }

  MessageData.fromDocument(DocumentSnapshot document) {
    content = document.data['content'];
    creator = document.data['creator'];
    timestamp = document.data['timestamp'];
    likes = document.data['likes'].cast<DocumentReference>().toList();
    uid = document.documentID;
  }

//  Future<void> likeMessage() async {
//    DocumentReference docRef = Firestore.instance.document("messages/$uid");
//    Firestore.instance.runTransaction((Transaction tx) async {
//      DocumentSnapshot postSnapshot = await tx.get(docRef);
//      if (postSnapshot.exists) {
//        await tx.update(docRef, <String, dynamic>{'likes': postSnapshot.data['likes'] + 1});
//      }
//    });
//  }
}

class EventData {
  String uid, name, description, location;
  DocumentReference creator, docRef;
  Timestamp eventTimestamp;
  Uint8List photo;
  List<DocumentReference> going, notGoing, undecided;

  EventData(this.creator, this.uid, {
    this.name = '',
    this.description = '',
    this.location = '',
    this.eventTimestamp,
    this.photo,
    this.going, this.notGoing, this.undecided}) {
    if (eventTimestamp == null) eventTimestamp = Timestamp.now();
    if (going == null) going = List();
    if (notGoing == null) notGoing = List();
    if (undecided == null) undecided = List();
    docRef = Firestore.instance.document('events/$uid');
  }

  EventData.fromDocument(DocumentSnapshot document) {
    uid = document.documentID;
    name = document.data['name'];
    description = document.data['description'];
    location = document.data['location'];
    creator = document.data['creator'];
    eventTimestamp = document.data['eventTimestamp'];
    going = document.data['going'].cast<DocumentReference>().toList();
    notGoing = document.data['notGoing'].cast<DocumentReference>().toList();
    undecided = document.data['undecided'].cast<DocumentReference>().toList();
    docRef = document.reference;
  }
}