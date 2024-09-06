import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
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

    getPositionFromPrefs().then((data) {
      if (data.isNotEmpty) {
        setState(() {
          cityController.text = data[0];
          countryController.text = data[1];
        });
      }
    });
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
                onPressed: () {
                  getPosition(false).then((data) {
                    setState(() {
                      if (data.isNotEmpty) {
                        countryController.text = data[0];
                        cityController.text = data[1];
                      }
                    });
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
                    onPressed: () {
                      saveLocation(context, countryController.text,
                          cityController.text, palette.getMainC);
                    },
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

Future<List> getPositionFromPrefs() async {
  List position = [];

  await SharedPreferences.getInstance().then((prefs) {
    if (prefs.containsKey("city") & prefs.containsKey("country")) {
      position.add(prefs.getString("city"));
      position.add(prefs.getString("country"));
    }
  });

  return position;
}

void saveLocation(
    BuildContext context, String country, String city, Color c) async {
  await SharedPreferences.getInstance().then((prefs) {
    prefs.remove("prayers");
    prefs.setString("city", city);
    prefs.setString("country", country);
    // we need to update the main page to get prayer times again
    Provider.of<ColorPalette>(context, listen: false).setMainC(c);
    Navigator.of(context).pop();
  });
}
