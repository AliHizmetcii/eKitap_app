import 'package:flutter/material.dart';

class inputWidget extends StatelessWidget {
  late TextEditingController controller;
  String labelText = "";
  String hintText = "";
  bool password = false;
  TextInputType inputType = TextInputType.none;

  inputWidget(
    TextEditingController _controller,
    String _labelText,
    String _hintText,
    TextInputType _inputType, {
    Key? key,
    bool? optPassword,
  }) : super(key: key) {
    // TODO: implement inputWidget
    controller = _controller;
    labelText = _labelText;
    hintText = _hintText;
    inputType = _inputType;
    password = optPassword ?? false;
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
          height: 60,
          width: (size * 0.7),
          child: TextFormField(
            keyboardType: inputType,
            controller: controller,
            cursorColor: Colors.black,
            obscureText: password,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(10.0),
              border: OutlineInputBorder(),
              labelText: labelText,
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }
}
