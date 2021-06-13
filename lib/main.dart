import 'dart:ffi';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'dart:io';
// import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'src/locations.dart' as locations;
import 'dart:ui' as ui;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final appTitle = "AirTag";
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    GMAP(),
    BodyWidget(),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _getLocation() {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('AirTag'),
          backgroundColor: Colors.green[1000],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  image:
                      DecorationImage(image: AssetImage('assets/AirTag.png'),scale: 0.5),
                  // image: DecorationImage(image: NetworkImage('data:image/jpeg;base64,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'));
                ),
                child: Text('AirTag'),
              ),
              ListTile(
                title: Text('Map'),
                onTap: () {
                  GMAP();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('List'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'List',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.green[400],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}

class GMAP extends StatefulWidget {
  const GMAP({Key? key}) : super(key: key);

  @override
  _GMAPState createState() => _GMAPState();
}

class _GMAPState extends State<GMAP> {
  final Map<String, Marker> _markers = {};
  String serverResponse = 'Server response';
  // LatLng _center = const LatLng(0,0);
  LatLng _center = const LatLng(32.0853, 34.7818);
  Future<void> _onMapCreated(GoogleMapController controller) async {
    // final airTags = await locations.getGoogleOffices();
    // setState(() {
    //   _markers.clear();
    //   for (final tag in airTags.offices) {
    //     final marker = Marker(
    //       markerId: MarkerId(tag.name),
    //       position: LatLng(tag.lat, tag.lng),
    //       infoWindow: InfoWindow(
    //         title: tag.name,
    //         snippet: tag.address,
    //       ),
    //     );
    //     _markers[tag.name] = marker;
    //   }
    // });
    _getAllTags();
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }



  _getAllTags() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/AirTag.png', 100);

    final url = Uri.parse(
        'http://localhost:8000/graphql?query={locations{id,name,address,lat,lng}}');
    var response = await get(url);
    Map<String, dynamic> data = jsonDecode(response.body);
    var locations = data['data']['locations'];
    setState(() {
      _markers.clear();
      for (final tag in locations) {
        print(tag);
        final marker = Marker(
          markerId: MarkerId(tag['name']),
          position: LatLng(tag['lat'], tag['lng']),
          infoWindow: InfoWindow(
            title: tag['name'],
            snippet: tag['address'] +
                "\n" +
                tag['lat'].toString() +
                " | " +
                tag['lng'].toString(),
             
          ),
          icon: BitmapDescriptor.fromBytes(markerIcon),
        );
        _markers[tag['name']] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _center,
            zoom: 10,
          ),
          markers: _markers.values.toSet(),
          compassEnabled: true,
          indoorViewEnabled: true,
          myLocationButtonEnabled: false,
          trafficEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          buildingsEnabled: true,
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // _makeGetRequest();
          _getAllTags();
        },
        child: const Icon(Icons.settings),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  const BodyWidget({Key? key}) : super(key: key);

  @override
  BodyWidgetState createState() => BodyWidgetState();
}

class BodyWidgetState extends State<BodyWidget> {
  String locationsResponse = 'locationsResponse';
  String locationResponse = 'locationResponse';
  String setLocationResponse = 'setLocationResponse';

  int id = 0;
  int toBeDeletedId = 0;
  String name = '';
  String address = '';
  double lat = 0.0;
  double lng = 0.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: (MediaQuery.of(context).size.width - 50),
          height: (MediaQuery.of(context).size.height),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                child: Text('Get all tags'),
                onPressed: () {
                  _getAllTags();
                },
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Text(locationsResponse)),
              ElevatedButton(
                child: Text('Get tags by id'),
                onPressed: () {
                  _getTagByID(id);
                },
              ),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a tag`s id'),
                  onSubmitted: (String input) {
                    setState(() {
                      id = int.parse(input);
                    });
                    _getTagByID(id);
                  }),
              Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(locationResponse)),
              ElevatedButton(
                child: Text('Delete tag by id'),
                onPressed: () {
                  _deleteTag();
                },
              ),
              ElevatedButton(
                child: Text('Delete all tags'),
                onPressed: () {
                  _deleteAllTag();
                },
              ),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter a tag`s id'),
                  onSubmitted: (String input) {
                    setState(() {
                      toBeDeletedId = int.parse(input);
                    });
                    _deleteTag();
                  }),
              ElevatedButton(
                child: Text('Add new tag'),
                onPressed: () {
                  _addTag();
                },
              ),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Tag name'),
                  onChanged: (String input) {
                    setState(() {
                      name = input.toString();
                    });
                  }),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Tag address'),
                  onChanged: (String input) {
                    setState(() {
                      address = input.toString();
                    });
                  }),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Tag lat'),
                  onChanged: (String input) {
                    setState(() {
                      lat = double.parse(input);
                    });
                  }),
              TextField(
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Tag lng'),
                  onChanged: (String input) {
                    setState(() {
                      lng = double.parse(input);
                    });
                  }),
            ],
          ),
        ),
      ),
    );
  }

  _getTagByID(id) async {
    final url = Uri.parse(
        'http://localhost:8000/graphql?query={location(id:${id}){id,name,address,lat,lng}}');
    var response = await get(url);
    Map<String, dynamic> data = jsonDecode(response.body);
    // var location = data['data']['location'];
    // String name = location['name'];
    // var lat = location['lat'];
    // var lng = location['lng'];
    // print('name, ${name}!');
    // print('lat, ${lat}!');
    // print('lng, ${lng}!');
    setState(() {
      locationResponse = response.body;
    });
  }

  _getAllTags() async {
    final url = Uri.parse(
        'http://localhost:8000/graphql?query={locations{id,name,address,lat,lng}}');
    var response = await get(url);
    setState(() {
      locationsResponse = response.body;
    });
  }

  _addTag() async {
    // final url = Uri.parse(
    //     'http://localhost:8000/graphql?query={createLocation(name:"test",address:"test",lat:32.18,lng:34.851){id,name,address,lat,lng}}');
    final url = Uri.parse(
        'http://localhost:8000/graphql?query={createLocation(name:"$name",address:"$address",lat:$lat,lng:$lng){id,name,address,lat,lng}}');
    var response = await get(url);
    setState(() {
      locationsResponse = response.body;
      name = '';
      address = '';
      lat = 0;
      lng = 0;
    });
  }

  _deleteTag() async {
    final url = Uri.parse(
        'http://localhost:8000/graphql?query={deleteLocation(id:$toBeDeletedId){id,name,address,lat,lng}}');
    var response = await get(url);
    setState(() {
      locationsResponse = response.body;
    });
  }

  _deleteAllTag() async {
    final url = Uri.parse(
        'http://localhost:8000/graphql?query={deleteLocations{id,name,address,lat,lng}}');
    var response = await get(url);
    setState(() {
      locationsResponse = response.body;
    });
  }
}
