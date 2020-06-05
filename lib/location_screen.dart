import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  List<LocationData> locationData = [];

  TextStyle textStyleH1 =
      TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
  Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position _currentPosition;
  String _currentAddress;
  Timer timer;
  bool loading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
    timer =
        Timer.periodic(Duration(seconds: 10), (timer) => _getCurrentLocation());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          'Tracking Location',
          style: textStyleH1,
        ),
      ),
      body: _currentPosition == null ? Center(child: CircularProgressIndicator(),) : Column(
        children: <Widget>[
          Expanded(
              flex: 7,
              child: GoogleMap(
                mapType: MapType.normal,
                mapToolbarEnabled: false,
                scrollGesturesEnabled: true,
                zoomGesturesEnabled: true,
                trafficEnabled: true,
                compassEnabled: true,
                indoorViewEnabled: true,
                rotateGesturesEnabled: true,
                tiltGesturesEnabled: true,
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                      _currentPosition.latitude, _currentPosition.longitude),
                  zoom: 14.4746,
                ),
                onMapCreated: (GoogleMapController controller) {
                  _controller.complete(controller);
                },
              )),
          Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Tracking Current location',
                    style: textStyleH1,
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: locationData.length,
                          itemBuilder: (BuildContext context, index) {
                            int indexRow = index + 1;
                            return ListTile(
                              leading: Text(indexRow.toString()),
                              title: Text("Lat: " +
                                  locationData[index].lat +
                                  " Log: " +
                                  locationData[index].log),
                            );
                          }))
                ],
              ))
        ],
      ),
    );
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        locationData.add(LocationData(position.latitude.toString(), position
            .longitude.toString()));
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }
}

class LocationData {
  String lat;
  String log;
  LocationData(this.lat, this.log);
}
