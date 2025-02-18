// ignore_for_file: use_build_context_synchronously
import "package:flutter/material.dart";
import "package:prayerapp/location_class/location_class.dart";
import "package:prayerapp/main.dart";
import "package:prayerapp/sqlite.dart";

class LocationSettingsPage extends StatefulWidget {
  const LocationSettingsPage({super.key});

  @override
  State<LocationSettingsPage> createState() => _LocationSettingsPageState();
}

class _LocationSettingsPageState extends State<LocationSettingsPage> {
  late TextEditingController loController;
  late TextEditingController laController;

  @override
  void initState() {
    loController = TextEditingController();
    laController = TextEditingController();

    laController.text = (LocationHandler.location.la ?? "").toString();
    loController.text = (LocationHandler.location.lo ?? "").toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    return Scaffold(
      backgroundColor: palette.secColor,
      appBar: AppBar(
        backgroundColor: palette.mainColor,
        foregroundColor: palette.secColor,
        title: const Text(
          "Location settings",
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Location Settings",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: palette.mainColor),
            ),
            Text(
              "Set Your Location Manually Or Let The GPS Find You",
              style: TextStyle(
                  fontSize: 14,
                  color: Color.lerp(palette.mainColor, palette.secColor, 0.4)),
            ),
            const SizedBox(
              height: 20,
            ),
            LocationInputWidget(
                text: "Latitude",
                color: palette.mainColor,
                controller: loController),
            LocationInputWidget(
                text: "Longitude",
                color: palette.mainColor,
                controller: laController),
            Column(
              children: [
                MaterialButton(
                  color: palette.secColor,
                  onPressed: _getLocationFromGPS,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: palette.mainColor,
                        ),
                        Text("Get Location From GPS",
                            style: TextStyle(color: palette.mainColor)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                MaterialButton(
                  color: palette.mainColor,
                  onPressed: onSave,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Save", style: TextStyle(color: palette.secColor)),
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _getLocationFromGPS() async {
    await LocationHandler.location.getFromGps(context);
    setState(() {
      laController.text = LocationHandler.location.la.toString();
      loController.text = LocationHandler.location.lo.toString();
    });
  }

  void onSave() {
    double? la = double.tryParse(laController.text);
    double? lo = double.tryParse(loController.text);
    if (la != null && lo != null) {
      LocationHandler.location.userEnteredAddress(
          double.parse(laController.text), double.parse(loController.text));
      Db().deletePrayers();
      Navigator.of(context).pop();
    }
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
