import 'dart:io';

import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  bool permissionStatus = false;
  late Future _futureGetPath;
  List<dynamic> listImagePath = <dynamic>[];

  @override
  void initState() {
    super.initState();

    _futureGetPath = _getPath();
    _checkPermission();
  }

  _checkPermission() async {
    if (await Permission.storage.request().isGranted) {
      setState(() {
        permissionStatus = true;
      });
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      setState(() {
        permissionStatus = false;
      });
    }
  }

  Future<String> _getPath() async {
    return await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_PICTURES);
  }

  _fetchFiles(Directory directory) {
    List<dynamic> listImage = <dynamic>[];
    directory.list().forEach((element) {
      RegExp regExp = RegExp(".(gif|jpe?g|png)", caseSensitive: false);
      if (regExp.hasMatch('$element')) listImage.add(element);

      setState(() {
        listImagePath = listImage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text("Images"),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder(
              future: _futureGetPath,
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                if (snapshot.hasData) {
                  var directory = Directory(snapshot.data);
                  if (permissionStatus) {
                    _fetchFiles(directory);
                  } else {
                    return const Text("No Permission");
                  }
                  return Text(snapshot.data);
                } else {
                  return const Text("Loading....");
                }
              },
            )
          ),
          Expanded(
            flex: 19,
            child: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(5),
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              crossAxisCount: 3,
              children: _getListImgs(listImagePath),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _getListImgs(List<dynamic> listImagePath) {
    List<Widget> listImages = <Widget>[];
    for (var imagePath in listImagePath) {
      listImages.add(
        Container(
          padding: const EdgeInsets.all(8),
          child: Image.file(imagePath, fit: BoxFit.cover),
        ),
      );
    }
    return listImages;
  }
}
