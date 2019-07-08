import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:squaad/Data.dart';

class Profile extends StatefulWidget {
//  final DocumentSnapshot docSnapshot;
//  final List<Uint8List> photos;
  final UserData userData;
  Profile(this.userData) : super(key: Key(userData.uid));

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Flexible(child: AspectRatio(aspectRatio: 1.0,
        child: widget.userData.photos.length == 1? Image.memory(widget.userData.photos.single, fit: BoxFit.fitWidth) :
        Swiper(itemCount: widget.userData.photos.length, pagination: SwiperPagination(), loop: true,
        itemBuilder: (BuildContext context, int index) => Image.memory(widget.userData.photos[index])))),
        Text(widget.userData.name,
            style: TextStyle(fontSize: 36.0), textAlign: TextAlign.center),
        Text(widget.userData.bio)
      ]));
  }
}
