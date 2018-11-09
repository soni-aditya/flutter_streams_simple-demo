import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Photo Streamer',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PhotoList(),
    );
  }
}

class PhotoList extends StatefulWidget {
  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
  StreamController<Photo> streamController;
  List<Photo> photoList = [];

  @override
  void initState() {
    super.initState();
    //Initiating the stream controller
    streamController = StreamController.broadcast();
    //subscribing to the stream
    streamController.stream.listen((photo) {
      setState(() {
        photoList.add(photo);
      });
    });
    //Load all the data from the api
    load(streamController);
  }

  load(StreamController sController) async {
    String url = 'https://jsonplaceholder.typicode.com/photos';
    var client = http.Client();
    var request = http.Request('get', Uri.parse(url));
    var streamResponse = await client.send(request);
    streamResponse.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        //Taking each photo from the list and changing it into a collection
        .expand((singlePhotoFromList) => singlePhotoFromList)
        .map((map) => Photo.mapFromJson(map))
        .pipe(streamController);
  }

  @override
  void dispose() {
    streamController?.close();
    streamController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Streamer'),
      ),
      body: Center(
        child: ListView.builder(
            cacheExtent: 1500.0,
            itemBuilder: (BuildContext context, int index) =>
                _makeElement(index)),
      ),
    );
  }

  _makeElement(int index) {
    if (index >= photoList.length) {
      return null;
    }
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Column(
        children: <Widget>[
          Image.network(photoList[index].url),
          Text(photoList[index].title),
        ],
      ),
    );
  }
}

class Photo {
  final String title;
  final String url;

  Photo(this.title, this.url);

  Photo.mapFromJson(Map jsonMap)
      : title = jsonMap['title'],
        url = jsonMap['url'];
}
