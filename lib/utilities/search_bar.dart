import 'package:flutter/material.dart';

import 'package:bosque_real/utilities/constants.dart';

class SearchBar extends StatelessWidget {
  final String hint;
  final Function toDoPressed;
  final Function toDoChanged;
  final Function onBack;

  SearchBar({
    @required this.hint,
    this.toDoPressed,
    this.toDoChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toDoPressed != null ? toDoPressed : () {},
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        width: MediaQuery.of(context).size.width * .70,
        height: 60.0,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black38, width: .5),
            borderRadius: BorderRadius.circular(15.0)),
        child: Row(
          children: <Widget>[
            Expanded(
                child: TextField(
              style: TextStyle(fontSize: 22, color: Colors.black),
              onTap: toDoPressed != null ? toDoPressed : () {},
              onChanged: toDoChanged != null
                  ? (value) {
                      toDoChanged(value);
                    }
                  : () {},
              maxLines: 1,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: hint,
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: onBack != null
                    ? IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.arrow_back),
                        iconSize: 20.0,
                        onPressed: onBack,
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.person,
                        ),
                        onPressed: toDoPressed,
                      ),
              ),
            )),
            IconButton(
              icon: Icon(
                Icons.search,
                size: 28.0,
              ),
              onPressed: toDoPressed != null ? toDoPressed : () {},
            )
          ],
        ),
      ),
    );
  }
}
