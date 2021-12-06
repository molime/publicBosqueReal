import 'dart:io';

import 'package:bosque_real/screens/auth/login.dart';
import 'package:bosque_real/screens/main/profile/update_image.dart';
import 'package:flutter/material.dart';
import 'package:bosque_real/widgets/profile/profile_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:bosque_real/widgets/profile/change_name_dialog.dart';
import 'package:bosque_real/data/user_data.dart';
import 'package:bosque_real/config/auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool changePassword = false;
  bool changeName = false;
  String password;
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scaffoldPhotoKey = GlobalKey<ScaffoldState>();
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  File _imageFile;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    print({
      'user.photoUrl': Provider.of<UserData>(context).user.photoUrl,
      'user.photoUrl == null':
          Provider.of<UserData>(context).user.photoUrl == null,
      'user.photoUrl == ""': Provider.of<UserData>(context).user.photoUrl == "",
    });
    return _imageFile != null
        ? updateProfileImage(
            imageFile: _imageFile,
            goBack: () {
              setState(() {
                _imageFile = null;
              });
            },
            screenWidth: MediaQuery.of(context).size.width,
            context: context,
            inAsyncCall: isLoading,
            changeAsyncCall: (bool value) {
              setState(() {
                isLoading = value;
              });
            },
            scaffoldKey: _scaffoldPhotoKey,
          )
        : SafeArea(
            child: Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                backgroundColor: Color(0xFFe2b13c),
                leading: IconButton(
                  icon: Icon(
                    Icons.exit_to_app,
                    color: Colors.white,
                  ),
                  onPressed: () async {
                    await logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                ),
              ),
              body: ListView(
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
                          child: InkWell(
                            onTap: selectImage,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: MediaQuery.of(context).size.width * 0.15,
                              backgroundImage: Provider.of<UserData>(context)
                                              .user
                                              .photoUrl ==
                                          null ||
                                      Provider.of<UserData>(context)
                                              .user
                                              .photoUrl ==
                                          ""
                                  ? null
                                  : NetworkImage(
                                      Provider.of<UserData>(context)
                                          .user
                                          .photoUrl,
                                    ),
                              child: Provider.of<UserData>(context)
                                              .user
                                              .photoUrl ==
                                          null ||
                                      Provider.of<UserData>(context)
                                              .user
                                              .photoUrl ==
                                          ""
                                  ? Icon(
                                      Icons.person,
                                      size: MediaQuery.of(context).size.width *
                                          0.15,
                                      color: Colors.black,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        if (!changePassword && !changeName) ...[
                          Padding(
                            padding: EdgeInsets.all(
                              16.0,
                            ),
                            child: Column(
                              children: [
                                ProfileCard(
                                  text:
                                      Provider.of<UserData>(context).user.email,
                                  icon: Icons.alternate_email,
                                ),
                                ProfileCard(
                                  text: Provider.of<UserData>(context)
                                              .user
                                              .displayName !=
                                          null
                                      ? Provider.of<UserData>(context)
                                          .user
                                          .displayName
                                      : 'Nombre vacío',
                                  icon: Icons.person,
                                  onPressed: () async {
                                    await showChangeNameDialog(
                                        context: context,
                                        nameController: TextEditingController(
                                          text: Provider.of<UserData>(context,
                                                          listen: false)
                                                      .user
                                                      .displayName !=
                                                  null
                                              ? Provider.of<UserData>(context,
                                                      listen: false)
                                                  .user
                                                  .displayName
                                              : '',
                                        ));
                                  },
                                ),
                              ],
                            ),
                          ),
                          RaisedButton(
                            onPressed: () {
                              setState(() {
                                changePassword = true;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                20.0,
                              ),
                              side: BorderSide(
                                color: Color(0xFFe2b13c),
                              ),
                            ),
                            color: Colors.white,
                            child: Text(
                              'CAMBIA DE CONTRASEÑA',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                  color: Color(0xFFe2b13c),
                                ),
                              ),
                            ),
                          ),
                        ],
                        if (changePassword) ...[
                          Form(
                            key: _formKey,
                            child: Flex(
                              direction: Axis.vertical,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  child: TextFormField(
                                    obscureText: true,
                                    controller: currentPasswordController,
                                    validator: (val) => val.length < 6
                                        ? 'La contraseña debe tener al menos 6 caracteres'
                                        : null,
                                    decoration: InputDecoration(
                                      labelText: 'CONTRASEÑA ACTUAL',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Color(0xFFe2b13c),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: TextFormField(
                                        onChanged: (newPassword) {
                                          setState(() {
                                            password = newPassword;
                                          });
                                        },
                                        obscureText: true,
                                        controller: passwordController,
                                        validator: (val) => val.length < 6
                                            ? 'La contraseña debe tener al menos 6 caracteres'
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: 'NUEVA CONTRASEÑA',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFe2b13c),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    passwordController.text ==
                                                passwordConfirmController
                                                    .text &&
                                            passwordController.text.length >
                                                0 &&
                                            passwordConfirmController
                                                    .text.length >
                                                0
                                        ? Icon(
                                            Icons.check,
                                            color: Color(0xFFe2b13c),
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.65,
                                      child: TextFormField(
                                        obscureText: true,
                                        controller: passwordConfirmController,
                                        validator: (val) => val !=
                                                passwordController.text
                                            ? 'Las contraseñas deben ser iguales'
                                            : null,
                                        decoration: InputDecoration(
                                          labelText: 'CONFIRMA CONTRASEÑA',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Color(0xFFe2b13c),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    passwordController.text ==
                                                passwordConfirmController
                                                    .text &&
                                            passwordController.text.length >
                                                0 &&
                                            passwordConfirmController
                                                    .text.length >
                                                0
                                        ? Icon(
                                            Icons.check,
                                            color: Color(0xFFe2b13c),
                                          )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    RaisedButton(
                                      onPressed: () async {
                                        if (_formKey.currentState.validate()) {
                                          try {
                                            final userSignIn = await auth
                                                .signInWithEmailAndPassword(
                                              email: Provider.of<UserData>(
                                                      context,
                                                      listen: false)
                                                  .user
                                                  .email,
                                              password:
                                                  currentPasswordController
                                                      .text,
                                            );
                                            try {
                                              await userSignIn.user
                                                  .updatePassword(password);
                                              SnackBar snackbar = SnackBar(
                                                  content: Text(
                                                      "¡Contraseña cambiada con éxito!"));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                              setState(() {
                                                _formKey.currentState.reset();
                                                passwordController.clear();
                                                passwordConfirmController
                                                    .clear();
                                                password = null;
                                                currentPasswordController
                                                    .clear();
                                                changePassword = false;
                                              });
                                            } catch (errorChange) {
                                              SnackBar snackbar = SnackBar(
                                                  content: Text(
                                                      "Hubo un error cambiando la contraseña."));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackbar);
                                              setState(() {
                                                _formKey.currentState.reset();
                                                passwordController.clear();
                                                passwordConfirmController
                                                    .clear();
                                                password = null;
                                                currentPasswordController
                                                    .clear();
                                                changePassword = false;
                                              });
                                            }
                                          } catch (errorSignIn) {
                                            SnackBar snackbar = SnackBar(
                                              content: Text(
                                                'Hubo un error con tu contraseña actual',
                                              ),
                                            );
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(snackbar);
                                            setState(() {
                                              _formKey.currentState.reset();
                                              passwordController.clear();
                                              passwordConfirmController.clear();
                                              password = null;
                                              currentPasswordController.clear();
                                              changePassword = false;
                                            });
                                          }
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        side: BorderSide(
                                          color: Colors.green,
                                        ),
                                      ),
                                      color: Colors.white,
                                      child: Text(
                                        'CONFIRMAR',
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    RaisedButton(
                                      onPressed: () async {
                                        setState(() {
                                          changePassword = false;
                                        });
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        side: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                      color: Colors.white,
                                      child: Text(
                                        'CANCELAR',
                                        style: GoogleFonts.openSans(
                                          textStyle: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> selectImage() async {
    PickedFile pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );

    setState(() {
      _imageFile = File(pickedFile.path);
    });
  }
}
