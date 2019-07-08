import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:squaad/Data.dart';
import 'package:squaad/PhotoEditor.dart';
import 'package:squaad/UserGenerator.dart';
import 'dart:ui' as ui;

class CreateEventPage extends StatefulWidget {
  final GroupData groupData;

  const CreateEventPage(this.groupData);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  EventData eventData = EventData(localUserData.docRef, generateId(27));
  ImageCroppingData imgCroppingData;
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey _photoKey = GlobalKey();


  @override
  void initState() {
    imgCroppingData = ImageCroppingData(imgData: eventData.photo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('New Event')),
        floatingActionButton: FloatingActionButton(child: Icon(Icons.check),
            onPressed: () {
              _formKey.currentState.save();
              if (eventData.name.isNotEmpty &&
                  eventData.location.isNotEmpty &&
                  eventData.eventTimestamp != null) {
                eventData.undecided = widget.groupData.users;
                eventData.docRef.setData(<String, dynamic>{
                  'uid': eventData.uid,
                  'name': eventData.name,
                  'description': eventData.description,
                  'location': eventData.location,
                  'creator': eventData.creator,
                  'eventTimestamp': eventData.eventTimestamp,
                  'going': eventData.going,
                  'notGoing': eventData.notGoing,
                  'undecided': eventData.undecided});
                if (eventData.photo != null) {
                  RenderRepaintBoundary boundary = _photoKey.currentContext.findRenderObject();
                  boundary.toImage(pixelRatio: 600 / boundary.size.width).then((image) =>
                      image.toByteData(format: ui.ImageByteFormat.png).then((bytes) {
                        eventData.photo = bytes.buffer.asUint8List();
                        FirebaseStorage.instance.ref().child(eventData.uid).putData(eventData.photo);
                        Navigator.of(context).pop(eventData);
                      }));
                } else Navigator.of(context).pop(eventData);
              }
            }),
        body: Padding(
            padding: EdgeInsets.all(15.0),
            child: Form(
                key: _formKey,
                child: Column(
                    children: <Widget>[
                      Flexible(child: AspectRatio(aspectRatio: 1.5, child: GestureDetector(
                          onTap: () => ImagePicker.pickImage(source: ImageSource.gallery).then(
                                  (img) => setState(() => eventData.photo = img.readAsBytesSync())),
                          child: RepaintBoundary(key: _photoKey, child: eventData.photo == null?
                          Container(
                              color: Theme.of(context).primaryColor.withOpacity(0.75),
                              child: Center(child: Icon(Icons.add_a_photo, size: 50.0))) :
                          Image.memory(eventData.photo, fit: BoxFit.cover),)))),
                      TextFormField(decoration: InputDecoration(icon: Text('Name')),
                          initialValue: eventData.name,
                          onSaved: (value) => eventData.name = value),
                      PlacesAutocompleteFormField(apiKey: 'AIzaSyBQtEsRQTFQVgaRVuz3R4D_UsBQNketee0', hint: '',
                          inputDecoration: InputDecoration(icon: Icon(Icons.location_on)),
                          initialValue: eventData.location,
                          onSaved: (value) => eventData.location = value
                      ),
                      DateTimePickerFormField(decoration: InputDecoration(icon: Icon(Icons.access_time)),
                          locale: Localizations.localeOf(context),
                          resetIcon: null,
                          editable: false,
                          format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
                          onSaved: (value) => eventData.description = value.toIso8601String()),
                      TextFormField(decoration: InputDecoration(icon: Text('Description')),
                          maxLines: 2,
                          initialValue: eventData.description,
                          onSaved: (value) => eventData.description = value),
                    ])
            )));
  }
}
