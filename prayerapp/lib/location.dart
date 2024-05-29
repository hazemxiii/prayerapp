import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "settings.dart";
import "main.dart";

class LocationSettings extends StatefulWidget {
  const LocationSettings({super.key});

  @override
  State<LocationSettings> createState() => _LocationSettingsState();
}

class _LocationSettingsState extends State<LocationSettings> {
  Color mainColor = Colors.lightBlue;
  Color secondaryColor = Colors.white;
  Color backColor = Colors.lightBlue[50]!;

  late TextEditingController cityController;
  late TextEditingController countryController;

  @override
  void initState() {
    getColors().then((data) {
      setState(() {
        mainColor = hexToColor(data[0]);
        secondaryColor = hexToColor(data[1]);
        backColor = hexToColor(data[2]);
      });
    });

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
    return Scaffold(
      backgroundColor: secondaryColor,
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
        backgroundColor: mainColor,
        foregroundColor: secondaryColor,
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
            LocationInput(
                text: "City", color: mainColor, controller: cityController),
            LocationInput(
                text: "Country",
                color: mainColor,
                controller: countryController),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MaterialButton(
                  color: backColor,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel", style: TextStyle(color: mainColor)),
                ),
                const SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  color: mainColor,
                  onPressed: () {
                    saveLocation(countryController.text, cityController.text);
                    Provider.of<ColorPalette>(context, listen: false)
                        .setMainC(mainColor);
                    Navigator.of(context).pop();
                  },
                  child: Text("Save", style: TextStyle(color: secondaryColor)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class LocationInput extends StatefulWidget {
  final Color color;
  final TextEditingController controller;
  final String text;
  const LocationInput(
      {super.key,
      required this.color,
      required this.controller,
      required this.text});

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
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

void saveLocation(String country, String city) async {
  await SharedPreferences.getInstance().then((prefs) {
    prefs.remove("prayers");
    prefs.setString("city", city);
    prefs.setString("country", country);
  });
}
