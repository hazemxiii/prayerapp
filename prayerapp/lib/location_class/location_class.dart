import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:prayerapp/global.dart';
import 'package:prayerapp/location_settings_page.dart';

class LocationHandler {
  static Location location = Location();
}

class Location {
  double? _la;
  double? _lo;
  String _city = "";
  String _country = "";

  void saveToPrefs() {
    if (_la != null && _lo != null) {
      Prefs.prefs.setDouble(PrefsKeys.la, _la!);
      Prefs.prefs.setDouble(PrefsKeys.lo, _lo!);
    }
    Prefs.prefs.setString(PrefsKeys.city, _city);
    Prefs.prefs.setString(PrefsKeys.country, _country);
  }

  void userEnteredAddress(String country, String city) {
    _country = country;
    _city = city;
    Prefs.prefs.setString(PrefsKeys.prayers, jsonEncode({}));
    saveToPrefs();
  }

  bool isLocationEmpty() {
    return _city == "" || _country == "";
  }

  Future<void> getFromGps(BuildContext context) async {
    bool serviceEnabled;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled && context.mounted) {
      showLocationDialogs(context, "Please Enable Location Services");
      return;
    }

    // ignore: use_build_context_synchronously
    if (!await askPermission()) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _la = position.latitude;
    _lo = position.longitude;
    // ignore: use_build_context_synchronously
    getAddressFromCoordinates();
  }

  void getAddressFromCoordinates() async {
    try {
      List<Placemark> address = await placemarkFromCoordinates(_la!, _lo!);
      _country = address[0].country ?? "";
      _city = address[0].administrativeArea ?? "";
    } catch (e) {
      // ignore: use_build_context_synchronously
      debugPrint("Error getting address: ${e.toString()}");
    }
  }

  Future<bool> askPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if ((permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever)) {
      return false;
    }
    return true;
  }

  void printLocation() {
    debugPrint("La=$_la - Lo=$_lo - Country = $_country - City = $_city");
  }

  void askForManualInput(BuildContext context) {
    Color c = Color(Prefs.prefs.getInt(PrefsKeys.primaryColor)!);
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text(
              "Error Getting Address",
              style: TextStyle(color: c),
            ),
            content: Text(
              "Add An Address Manually?",
              style: TextStyle(color: c),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (_) => const LocationSettingsPage()));
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: c),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel", style: TextStyle(color: c)))
            ],
          );
        });
  }

  Future<void> showLocationDialogs(BuildContext context, String text,
      {List<Widget>? actions}) async {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(text),
            actions: actions ?? [],
          );
        });
  }

  void initFromPrefs() {
    _la = Prefs.prefs.getDouble(PrefsKeys.la);
    _lo = Prefs.prefs.getDouble(PrefsKeys.lo);
    _city = Prefs.prefs.getString(PrefsKeys.city) ?? "";
    _country = Prefs.prefs.getString(PrefsKeys.country) ?? "";
  }

  String get city => _city;
  String get country => _country;
  double get la => _la!;
  double get lo => _lo!;
}