import 'dart:ffi';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'src/locations.dart' as locations;

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
    // Text(
    //   'Index 1: List',
    //   style: optionStyle,
    // ),
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
          // Add a ListView to the drawer. This ensures the user can scroll
          // through the options in the drawer if there isn't enough vertical
          // space to fit everything.
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
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

  _getAllTags() async {
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
        );
        _markers[tag['name']] = marker;
      }
    });
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      /// both default to 16
      marginEnd: 18,
      marginBottom: 20,
      // animatedIcon: AnimatedIcons.menu_close,
      // animatedIconTheme: IconThemeData(size: 22.0),
      /// This is ignored if animatedIcon is non null
      icon: Icons.add,
      activeIcon: Icons.remove,
      // iconTheme: IconThemeData(color: Colors.grey[50], size: 30),

      /// The label of the main button.
      // label: Text("Open Speed Dial"),
      /// The active label of the main button, Defaults to label if not specified.
      // activeLabel: Text("Close Speed Dial"),
      /// Transition Builder between label and activeLabel, defaults to FadeTransition.
      // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
      /// The below button size defaults to 56 itself, its the FAB size + It also affects relative padding and other elements
      buttonSize: 56.0,
      visible: true,

      /// If true user is forced to close dial manually
      /// by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 8.0,
      shape: CircleBorder(),

      // orientation: SpeedDialOrientation.Up,
      // childMarginBottom: 2,
      // childMarginTop: 2,
      gradientBoxShape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black, Colors.white],
      ),
      children: [
        SpeedDialChild(
          child: Icon(Icons.accessibility),
          backgroundColor: Colors.red,
          label: 'First',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('FIRST CHILD'),
          onLongPress: () => print('FIRST CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: Icon(Icons.brush),
          backgroundColor: Colors.blue,
          label: 'Second',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('SECOND CHILD'),
          onLongPress: () => print('SECOND CHILD LONG PRESS'),
        ),
        SpeedDialChild(
          child: Icon(Icons.keyboard_voice),
          backgroundColor: Colors.green,
          label: 'Third',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () => print('THIRD CHILD'),
          onLongPress: () => print('THIRD CHILD LONG PRESS'),
        ),
      ],
    );
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
