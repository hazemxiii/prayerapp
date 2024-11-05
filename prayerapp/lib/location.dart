// ignore_for_file: use_build_context_synchronously
import "dart:convert";

import "package:flutter/material.dart";
import "package:prayerapp/location_class/location_class.dart";
import "package:provider/provider.dart";
import "global.dart";

class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage> {
  late TextEditingController cityController;
  late TextEditingController countryController;

  @override
  void initState() {
    cityController = TextEditingController();
    countryController = TextEditingController();

    countryController.text = LocationHandler.location.country;
    cityController.text = LocationHandler.location.city;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ColorPalette>(builder: (context, palette, child) {
      return Scaffold(
        backgroundColor: palette.getSecC,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () async {
                  await LocationHandler.location.getFromGps(context);
                  setState(() {
                    countryController.text = LocationHandler.location.country;
                    cityController.text = LocationHandler.location.city;
                  });
                },
                icon: const Icon(Icons.gps_fixed))
          ],
          backgroundColor: palette.getMainC,
          foregroundColor: palette.getSecC,
          title: const Text(
            "Location settings",
            style: TextStyle(fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LocationInputWidget(
                  text: "City",
                  color: palette.getMainC,
                  controller: cityController),
              LocationInputWidget(
                  text: "Country",
                  color: palette.getMainC,
                  controller: countryController),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    color: palette.getSecC,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Cancel",
                        style: TextStyle(color: palette.getMainC)),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  MaterialButton(
                    color: palette.getMainC,
                    onPressed: onSave,
                    child:
                        Text("Save", style: TextStyle(color: palette.getSecC)),
                  )
                ],
              )
            ],
          ),
        ),
      );
    });
  }

  void onSave() {
    LocationHandler.location
        .userEnteredAddress(countryController.text, cityController.text);
    Prefs.prefs.setString("prayers", jsonEncode({}));
    Navigator.of(context).pop();
  }
}

class LocationInputWidget extends StatefulWidget {
  final Color color;
  final TextEditingController controller;
  final String text;
  const LocationInputWidget(
      {super.key,
      required this.color,
      required this.controller,
      required this.text});

  @override
  State<LocationInputWidget> createState() => _LocationInputWidgetState();
}

class _LocationInputWidgetState extends State<LocationInputWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        style: TextStyle(color: widget.color),
        cursorColor: widget.color,
        controller: widget.controller,
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(style: BorderStyle.solid, color: widget.color)),
            enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(style: BorderStyle.solid, color: widget.color)),
            label: Text(
              widget.text,
              style: TextStyle(color: widget.color),
            )),
      ),
    );
  }
}
