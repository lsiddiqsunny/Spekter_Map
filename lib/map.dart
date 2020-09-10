import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  static GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Position position;
  Set<Marker> markers;
  CameraPosition cameraPosition =
      CameraPosition(target: LatLng(23.6850, 90.3563), zoom: 7);
  String name;
  @override
  Future<void> initState() {
    super.initState();
    markers = Set<Marker>();
    name = "";
  }

  double zoomVal = 5.0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Spekter Map"),
      ),
      body: Stack(
        children: <Widget>[
          _buildGoogleMap(context),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  Future<void> _showDialog(BuildContext context) async {
    _positionController.text = 'Lat: ' +
        position.latitude.toStringAsFixed(3) +
        ',Long: ' +
        position.longitude.toStringAsFixed(3);
    _nameController.text = name;
    return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Add Your Info'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: _positionController,
                      decoration: InputDecoration(
                        labelText: 'Position',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter position';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _nameController,
                      //initialValue: name,
                      decoration: InputDecoration(
                        labelText: 'Enter Name',
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    name = _nameController.text;
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }

  Future<void> _getLocation() async {
    position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      cameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude), zoom: 7);
      markers.add(Marker(
        markerId: MarkerId(name),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: InfoWindow(title: name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueRed,
        ),
        onTap: () async {
          await _showDialog(context);

          print('Name: ' + name + ' Position: ' + position.toString());
          // _scaffoldKey.currentState.showSnackBar(SnackBar(
          //   content: Text(position.toString()),
          // ));
        },
      ));
    });
  }

  Widget _buildGoogleMap(BuildContext context) {
    _getLocation();
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: cameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: markers,
      ),
    );
  }
}
