import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squaad/Data.dart';

class PhotoEditor extends StatefulWidget {
  PhotoEditor();

  @override
  _PhotoEditorState createState() => _PhotoEditorState();
}

class _PhotoEditorState extends State<PhotoEditor> {
  List<ImageCroppingData> croppingData;
  int imageIndex = 0;
  Offset initialOffset = Offset.zero;
  @override
  void initState() {
    super.initState();
    croppingData = List.generate(3,(index) => ImageCroppingData(imgData:
    localUserData.photos.length > index? localUserData.photos[index]: null));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          if (croppingData[imageIndex].imgData == null) {
            ImagePicker.pickImage(source: ImageSource.gallery).then(
                    (file) {
                      croppingData[imageIndex].imgData = file.readAsBytesSync();
                      croppingData[imageIndex].scale = 1.0;
                      croppingData[imageIndex].offset = Offset.zero;
                  setState(() => imageIndex-= croppingData.length);
                });
          }
        },
        child: AspectRatio(aspectRatio: 1.0, child: imageIndex.isNegative?
            editImageWidget()
            : Swiper(
          itemBuilder: (BuildContext context, int index) {
            if (croppingData[index].imgData == null) return nullImageWidget();
            else return ViewImage(croppingData[index],
              onClear: () => setState(() => localUserData.photos.removeAt(imageIndex)),
              onEdit: () => setState(() => imageIndex-= croppingData.length));
          },
          itemCount: croppingData.length,
          loop: true,
          pagination: SwiperPagination(),
          index: imageIndex,
          onIndexChanged: (newIndex) =>
              setState(() => imageIndex = newIndex),
        )));
  }

  Widget editImageWidget() {
    return Stack(children: <Widget>[
      GestureDetector(
          onScaleStart: (details) => initialOffset = details.focalPoint,
          onScaleUpdate: (details) {
            if (details.scale != 1.0 &&
                croppingData[imageIndex+croppingData.length].scale != details.scale) {
              setState(() {
                croppingData[imageIndex+croppingData.length].scale = details.scale;
              });
            } else if (details.scale == 1.0) {
              Offset delta = Offset(details.focalPoint.dx - initialOffset.dx,
                  details.focalPoint.dy - initialOffset.dy);
              setState(() => croppingData[imageIndex+croppingData.length].offset =
                  croppingData[imageIndex+croppingData.length].offset + delta/125);
            }
          },
          onScaleEnd: (details) => initialOffset = null,
          child: croppingData[imageIndex+croppingData.length].getImageWidget(Colors.black)),
      Align(alignment: Alignment.topLeft,
          child: Padding(padding: EdgeInsets.all(5.0),
              child: GestureDetector(
                  child: Icon(Icons.done, color: Theme.of(context).primaryColor, size: 50.0),
                  onTap: () => croppingData[imageIndex + croppingData.length].getBytes().then((bytes) {
                    localUserData.photos.add(bytes);
                    setState(() => imageIndex+= croppingData.length);
                  }
                  ))))]);
  }

  Widget nullImageWidget() {
    return Container(color: Theme.of(context).primaryColor.withOpacity(0.75),
        child: Center(child: Icon(Icons.add_a_photo, size: 50.0)));
  }
}

class ViewImage extends StatefulWidget {
  final ImageCroppingData _initialCroppingData;
  final VoidCallback onClear, onEdit;
  ViewImage(this._initialCroppingData,
      {this.onClear, this.onEdit});

  @override
  _ViewImageState createState() => _ViewImageState(_initialCroppingData);
}

class _ViewImageState extends State<ViewImage> {
  ImageCroppingData croppingData;

  _ViewImageState(this.croppingData);

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      croppingData.getImageWidget(Colors.black),
      Align(alignment: Alignment.topRight,
          child: Padding(padding: EdgeInsets.all(5.0),
              child: GestureDetector(
                  child: Icon(Icons.clear, color: Theme.of(context).primaryColor, size: 50.0),
                  onTap: () {
                    croppingData.imgData = null;
                    if (widget.onClear != null) widget.onClear();
                  }))),
      Align(alignment: Alignment.topLeft,
          child: Padding(padding: EdgeInsets.all(5.0),
              child: GestureDetector(
                  child: Icon(Icons.crop, color: Theme.of(context).primaryColor, size: 50.0),
                  onTap: () {
                    if (widget.onEdit != null) widget.onEdit();
                  })))]);
  }
}

class ImageCroppingData {
  double scale;
  Uint8List imgData;
  Offset offset;
  GlobalKey _globalKey = GlobalKey();

  ImageCroppingData(
      {this.imgData,
        this.scale = 1.0,
        this.offset = Offset.zero});

  Future<Uint8List> getBytes() async {
    RenderRepaintBoundary boundary = _globalKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 600/boundary.size.width);
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }

  Widget getImageWidget(Color backgroundColor) {
    return RepaintBoundary(key: _globalKey, child: AspectRatio(aspectRatio: 1.0, child: Container(
        color: backgroundColor,
        child: ClipRect(child: Transform(
            transform: Matrix4.translationValues(offset.dx, offset.dy,0.0)..scale(scale),
            child: Image.memory(imgData))))));
  }
}