import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bosque_real/data/user_data.dart';

Future showChangeNameDialog(
    {BuildContext context, TextEditingController nameController}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(builder: (context, setState) {
        //String name;
        return AlertDialog(
          title: Text(
            'Cambiar nombre',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                TextFormField(
                  onChanged: (newName) {
                    setState(() {});
                  },
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'NOMBRE',
                    labelStyle: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(
                context,
                'cerrar',
              ),
              color: Colors.red,
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            FlatButton(
              onPressed:
                  nameController.text == null || nameController.text == ''
                      ? () {}
                      : () => Navigator.pop(
                            context,
                            nameController.text,
                          ),
              color: nameController.text == null || nameController.text == ''
                  ? Colors.grey
                  : Colors.green,
              child: Text(
                'Actualizar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      });
    },
  ).then((value) async {
    if (value != 'cerrar') {
      Provider.of<UserData>(context, listen: false).changeName(newName: value);
    }
  });
}
