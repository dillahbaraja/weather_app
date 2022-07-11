import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MaterialApp(
      title: "Weather App",
      home: Home(),
    ));

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  var temp;
  var description;
  var currently;
  var humidity;
  var windSpeed;
  var myLocation;

  Position currentPosition;
  String currentAddress;

  getCurrentLocation() {
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true)
        .then((Position position) {
      setState(() {
        currentPosition = position;
        getAddressFromLatLng();
      });
    }).catchError((e) {
      print(e.toString());
    });
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        currentAddress = "${place.subLocality}";
        myLocation = currentAddress != null ? currentAddress : "Semarang";
        print(myLocation);
        getWeather();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  getWeather() async {
    /*
    http.Response response = await http.get(
        "https://api.openweathermap.org/data/2.5/weather?q=" +
            myLocation.toString() +
            ",id&units=metric&appid=917f65cb503809a5e6368d9720197a22");
    */

    http.Response response = await http.get(
        "https://api.openweathermap.org/data/2.5/weather?lat=" +
            currentPosition.latitude.toString() +
            "&lon=" +
            currentPosition.longitude.toString() +
            "&units=metric&appid=917f65cb503809a5e6368d9720197a22");

    var result = jsonDecode(response.body);
    setState(() {
      this.temp = result['main']['temp'];
      this.description = result['weather'][0]['description'];
      this.currently = result['weather'][0]['main'];
      this.humidity = result['main']['humidity'];
      this.windSpeed = result['wind']['speed'];
    });
  }

  @override
  void initState() {
    super.initState();
    this.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 3,
            width: MediaQuery.of(context).size.width,
            color: Colors.red,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // atur ke tengah
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                        myLocation != null
                            ? "Currently in " + myLocation.toString()
                            : "Currently in Surakarta",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600))),
                Text(
                  temp != null ? temp.toString() + "\u00B0" : "Loading",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                        currently != null ? currently.toString() : "Loading",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          Expanded(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.thermometerHalf),
                  title: Text("Temperature"),
                  trailing: Text(
                      temp != null ? temp.toString() + "\u00B0" : "Loading"),
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.cloud),
                  title: Text("Weather"),
                  trailing: Text(
                      description != null ? description.toString() : "Loading"),
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.sun),
                  title: Text("Humidity"),
                  trailing:
                      Text(humidity != null ? humidity.toString() : "Loading"),
                ),
                ListTile(
                  leading: FaIcon(FontAwesomeIcons.wind),
                  title: Text("Wind Speed"),
                  trailing: Text(
                      windSpeed != null ? windSpeed.toString() : "Loading"),
                ),
              ],
            ),
          ))
        ],
      ),
    );
  }
}
