import 'dart:io';

import 'package:bosque_real/utilities/functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

Scaffold updateProfileImage({
  @required File imageFile,
  @required Function goBack,
  @required double screenWidth,
  @required BuildContext context,
  @required bool inAsyncCall,
  @required Function changeAsyncCall,
  @required GlobalKey<ScaffoldState> scaffoldKey,
}) {
  return Scaffold(
    key: scaffoldKey,
    appBar: AppBar(
      backgroundColor: Color(0xFFe2b13c),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: goBack,
      ),
    ),
    body: ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    bottom: 8.0,
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: screenWidth * 0.15,
                    backgroundImage: FileImage(
                      imageFile,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  onPressed: () async {
                    changeAsyncCall(
                      true,
                    );
                    bool result = await uploadPhotoStorage(
                      context: context,
                      imageFile: imageFile,
                    );
                    changeAsyncCall(
                      false,
                    );
                    if (result) {
                      SnackBar snackbar = SnackBar(
                        content: Text(
                            'Tu foto de perfil se ha actualizado con éxito.'),
                        duration: Duration(
                          seconds: 5,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      goBack();
                    } else {
                      SnackBar snackbar = SnackBar(
                        content: Text(
                            'Hubo un error actualizando tu foto de perfil, lo sentimos.'),
                        duration: Duration(
                          seconds: 5,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                      goBack();
                    }
                  },
                  child: Text(
                    'ACTUALIZAR FOTO',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                        color: Color(0xFFe2b13c),
                      ),
                    ),
                  ),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      20.0,
                    ),
                    side: BorderSide(
                      color: Color(0xFFe2b13c),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
