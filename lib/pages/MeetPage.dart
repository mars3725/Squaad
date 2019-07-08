import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/Profile.dart';
import 'package:squaad/pages/MatchPage.dart';

class MeetPage extends StatefulWidget {
  final double initBottomOffset = 15.0;

  @override
  MeetPageState createState() => MeetPageState();
}

class MeetPageState extends State<MeetPage> {
  double _bottomCardOffset;
  bool loadingUsers = false;
  bool exhaustedUsers = false;
  final List<Profile> matchPool = List();

  @override
  void initState() {
    super.initState();
    _bottomCardOffset = widget.initBottomOffset;
    loadingUsers = true;
    getNearbyUsers(precision: 1).then((users) {
      loadingUsers = false;
      if (mounted) setState(() {
        if (users.isEmpty) exhaustedUsers = true;
        else {
          matchPool.addAll(users);
          print("adding " + users.length.toString()+ " users to pool");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> stack = List();
    if (exhaustedUsers) stack.add(Center(child: Text("There's nobody left to meet!")));
    else stack.add(Center(child: CircularProgressIndicator()));
    if (matchPool.length > 1) stack.add(
        Positioned(child: matchPool[1],
            top: -_bottomCardOffset, bottom: _bottomCardOffset,
            left: _bottomCardOffset, right: _bottomCardOffset));
    if (matchPool.length > 0) stack.add(
        DraggableCard(child: matchPool.first,
          onSlideUpdate: (distance) =>
              setState(() => _bottomCardOffset = widget.initBottomOffset
                  - (distance / 10).clamp(0.0, widget.initBottomOffset)),
          onSlideOutComplete: (direction) {
            if (matchPool.length < 5 && !loadingUsers) {
              loadingUsers = true;
              getNearbyUsers(precision: 1, cursor: matchPool.last.userData).then((users) {
                loadingUsers = false;
                setState(() {
                  if (users.isEmpty) exhaustedUsers = true;
                  else {
                    matchPool.addAll(users);
                    print("adding " + users.length.toString()+ " users to pool");
                  }
                });
              });
            }
            if (direction == SlideDirection.left) { //Pass
              print("Passed user " + matchPool.first.userData.name);
              matchPool.removeAt(0);
            } else if (direction == SlideDirection.right) { //Like
              print('liked user ' + matchPool.first.userData.name);
              localUserData.likes.add(matchPool.first.userData.docRef);
              localUserData.docRef.updateData({'likes': localUserData.likes});
              if (matchPool.first.userData.likes.contains(localUserData.docRef)) {
                print("Match!");

                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) =>
                        MatchPage(matchPool.first))).then(
                        (pool)=> matchPool.removeAt(0));
              } else matchPool.removeAt(0);
            }
            setState(() => _bottomCardOffset = widget.initBottomOffset);
          },
        ));

    return Stack(children: stack);
  }

  Future<List<Profile>> getNearbyUsers({int precision = 4, UserData cursor}) async {
    assert(precision > 0 && precision <= 6);

    Query query = Firestore.instance
        .collection('users')
        .where('location',
        isGreaterThanOrEqualTo:
        localUserData.location.substring(0, precision),
        isLessThanOrEqualTo:
        localUserData.location.substring(0, precision) + 'z')
        .orderBy('location').orderBy('uid')
        .limit(5);
    if (cursor != null) query = query.startAfter([cursor.location, cursor.uid]);
    QuerySnapshot docs = await query.getDocuments();
    List<UserData> userDataList = List();
    for(int i=0; i < docs.documents.length; i++) {
      if (docs.documents[i].data['uid'] != localUserData.uid && !localUserData.likes.contains(docs.documents[i].reference)) {
        UserData userData = UserData.fromDocument(docs.documents[i]);
        for (int p = 0; p < 3; p++) {
          StorageReference imgRef = FirebaseStorage.instance.ref().child(docs.documents[i].data['uid'] + '_$p');
          int size = 0;
          try {
            size = (await imgRef.getMetadata()).sizeBytes;
          } catch (exception) {
            print(exception);
          }
          if (size != 0) userData.photos.add(await imgRef.getData((size)));
        }
        userDataList.add(userData);
      }
    }
    if (userDataList.isEmpty && docs.documents.isNotEmpty) return getNearbyUsers(precision: precision, cursor: UserData.fromDocument(docs.documents.last));
    else return List<Profile>.generate(userDataList.length, (index) => Profile(userDataList[index]));
  }
}

enum SlideDirection { left, right }

class DraggableCard extends StatefulWidget {
  final Profile child;
  final bool dragEnabled;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection direction) onSlideOutComplete;

  DraggableCard({
    this.child,
    this.onSlideUpdate,
    this.onSlideOutComplete,
    this.dragEnabled = true
  });

  @override
  _DraggableCardState createState() => _DraggableCardState();
}

class _DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  Offset cardOffset, offsetOrigin;
  double rotation;
  SlideDirection slideOutDirection;
  AnimationController slideOutAnimation, slideBackAnimation;
  Tween<Offset> slideOutTween;

  @override
  void initState() {
    cardOffset = Offset.zero;
    rotation = 0.0;
    super.initState();
    slideBackAnimation = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() => setState(() {
        cardOffset = Offset.lerp(
          offsetOrigin,
          const Offset(0.0, 0.0),
          Curves.elasticOut.transform(slideBackAnimation.value),
        );

        if (null != widget.onSlideUpdate) {
          widget.onSlideUpdate(cardOffset.distance);
        }
      }))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            offsetOrigin = null;
            offsetOrigin = null;
          });
        }
      });

    slideOutAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          cardOffset = slideOutTween.evaluate(slideOutAnimation);

          if (null != widget.onSlideUpdate) {
            widget.onSlideUpdate(cardOffset.distance);
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            offsetOrigin = null;
            slideOutTween = null;

            if (widget.onSlideOutComplete != null) {
              widget.onSlideOutComplete(slideOutDirection);
            }
          });
        }
      });
  }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.child.key != oldWidget.child.key) {
      cardOffset = Offset.zero;
      rotation = 0.0;
    }
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.dragEnabled) offsetOrigin = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      cardOffset = details.globalPosition - offsetOrigin;
      rotation = (pi / 16) *
          (cardOffset.dx / (MediaQuery.of(context).size.width)) *
          (MediaQuery.of(context).size.height / 2 - offsetOrigin.dy).sign;
      if (null != widget.onSlideUpdate) {
        widget.onSlideUpdate(cardOffset.distance);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset / cardOffset.distance;
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size.width));
        slideOutAnimation.forward(from: 0.0);
        slideOutDirection =
        isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else {
        offsetOrigin = cardOffset;
        rotation = 0.0;
        slideBackAnimation.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Transform.rotate(
            angle: rotation,
            child: Container(
                transform: Matrix4.translationValues(
                    cardOffset.dx, cardOffset.dy, 0.0),
                child: widget.child)));
  }
}
