import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prayerapp/main.dart';

class TasbihTextInput extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  const TasbihTextInput(
      {super.key, required this.controller, required this.formKey});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          "Specific Numbers (comma-separated)",
          style: TextStyle(color: Palette.of(context).mainColor),
        ),
        const SizedBox(
          height: 5,
        ),
        Form(
          key: formKey,
          child: TextFormField(
            validator: validator,
            controller: controller,
            style: TextStyle(color: Palette.of(context).mainColor),
            decoration: InputDecoration(
                hintText: "e.g., 33,66,99",
                border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Palette.of(context).mainColor))),
          ),
        )
      ],
    );
  }

  String? validator(String? v) {
    if (v == "") {
      return "Cannot Be Empty";
    }
    final regex = RegExp("([0-9]+,{0,1})+");
    bool match = regex.firstMatch(v!)![0] == v;
    if (!match) {
      return "Invalid Input";
    }
    return null;
  }
}

class NumberInput extends StatefulWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  const NumberInput(
      {super.key, required this.controller, required this.formKey});

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
                color: Palette.of(context).mainColor,
                onPressed: () {
                  _changeTasbihNumber(false);
                },
                icon: const Icon(Icons.remove)),
            Form(
                key: widget.formKey,
                child: SizedBox(
                  width: 50,
                  child: Transform.scale(
                    scale: 0.8,
                    child: TextFormField(
                      validator: _validator,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(color: Palette.of(context).mainColor),
                      controller: widget.controller,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Palette.of(context).mainColor))),
                    ),
                  ),
                )),
            IconButton(
                color: Palette.of(context).mainColor,
                onPressed: () {
                  _changeTasbihNumber(true);
                },
                icon: const Icon(Icons.add)),
          ],
        ),
      ],
    );
  }

  void _changeTasbihNumber(bool increase) {
    int v = int.parse(widget.controller.text);
    widget.controller.text = (v + (increase ? 1 : -1)).toString();
  }

  String? _validator(String? v) {
    if (v == "") {
      return "Cannot Be Empty";
    }
    if ((int.tryParse(v!) ?? -1) < 1) {
      return "Must Be A Non-Negative Number";
    }
    return null;
  }
}
