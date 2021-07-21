import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unihub_app/controllers/editProfile_controller.dart';
import 'package:unihub_app/controllers/login_controller.dart';
import 'package:unihub_app/i18N/appTranslations.dart';
import 'package:unihub_app/models/faculty.dart';
import 'package:unihub_app/models/degree.dart';
import 'package:unihub_app/models/university.dart';
import 'package:unihub_app/models/user.dart';
import 'package:unihub_app/screens/login/login.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

String finalUsername;
List<University> universitiesList = [];
List<Faculty> schoolsList = [];
List<Degree> degreesList = [];
List<String> subjectsList = [];
List<String> universitiesNamesList = [];
List<String> schoolsNamesList = [];
List<String> degreesNamesList = [];
Image imageUser;

class EditProfileScreen extends StatefulWidget {
  UserApp currentUser;
  EditProfileScreen(this.currentUser);
  EditProfile createState() => EditProfile();
}

class EditProfile extends State<EditProfileScreen> {
  final cloudinary =
      Cloudinary('181174856115133', 'vFmY1fKzbfKPeCkVTowq0EWVgic', 'unihub-ea');

  @override
  void initState() {
    getValidationData().whenComplete(() async {
      await getUniversities();
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  bool _isHidden = true;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _roleController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();
  String universitySelected;
  String schoolSelected;
  String degreeSelected;
  List<String> subjectsAskingSelected;
  List<String> subjectsDoneSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.instance.text("editProfile_title", null),
            style: TextStyle(color: Colors.blue),
          ),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 1,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SafeArea(
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                    },
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(
                                height: 15,
                              ),
                              Center(
                                child: Stack(
                                  children: [
                                    Container(
                                        width: 130,
                                        height: 130,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                width: 4,
                                                color: Theme.of(context)
                                                    .scaffoldBackgroundColor),
                                            boxShadow: [
                                              BoxShadow(
                                                  spreadRadius: 2,
                                                  blurRadius: 10,
                                                  color: Colors.black
                                                      .withOpacity(0.5),
                                                  offset: Offset(0, 2))
                                            ],
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(this
                                                    .widget
                                                    .currentUser
                                                    .profilePhoto)))),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  width: 4,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                              color: Colors.blue),
                                          child: IconButton(
                                            alignment: Alignment.center,
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                            ),
                                            onPressed: () async {
                                              showModalBottomSheet(
                                                  context: context,
                                                  clipBehavior: Clip.hardEdge,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                    24)),
                                                  ),
                                                  builder: (context) {
                                                    return SafeArea(
                                                      child: IntrinsicHeight(
                                                        child: Column(
                                                          children: <Widget>[
                                                            InkWell(
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .camera,
                                                                        color: Colors
                                                                            .grey
                                                                            .shade800),
                                                                    VerticalDivider(),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.instance.text(
                                                                            "pickOrigin_camera",
                                                                            null),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w300),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              onTap:
                                                                  setImageFromCamera,
                                                            ),
                                                            InkWell(
                                                              child: Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            16),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .image,
                                                                      color: Colors
                                                                          .grey
                                                                          .shade800,
                                                                    ),
                                                                    VerticalDivider(),
                                                                    Expanded(
                                                                      child:
                                                                          Text(
                                                                        AppLocalizations.instance.text(
                                                                            "pickOrigin_gallery",
                                                                            null),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.w300),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                              onTap:
                                                                  setImageFromGallery,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 3),
                                      labelText: AppLocalizations.instance
                                          .text("profile_fullname", null),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 3),
                                      labelText: AppLocalizations.instance
                                          .text("profile_description", null),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 3),
                                      labelText: AppLocalizations.instance
                                          .text("profile_phone", null),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              Container(
                                child: new DropdownButton<String>(
                                  isExpanded: true,
                                  value: universitySelected,
                                  hint: Text(AppLocalizations.instance
                                      .text("university", null)),
                                  items: universitiesNamesList.map((String e) {
                                    return DropdownMenuItem<String>(
                                      value: e,
                                      child: e == "Not Selected"
                                          ? Text(AppLocalizations.instance.text(
                                              e.split(" ").join().toLowerCase(),
                                              null))
                                          : Text(e),
                                    );
                                  }).toList(),
                                  onChanged: (String e) {
                                    setState(() {
                                      universitySelected = e;
                                    });
                                    getSchools(e);
                                  },
                                ),
                              ),
                              FutureBuilder<List<String>>(
                                  future: getSchools(universitySelected),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        child: new DropdownButton<String>(
                                          isExpanded: true,
                                          value: schoolSelected,
                                          hint: Text(AppLocalizations.instance
                                              .text("college", null)),
                                          items: snapshot.data.map((String e) {
                                            return DropdownMenuItem<String>(
                                              value: e,
                                              child: e == "Not Selected"
                                                  ? Text(AppLocalizations
                                                      .instance
                                                      .text(
                                                          e
                                                              .split(" ")
                                                              .join()
                                                              .toLowerCase(),
                                                          null))
                                                  : Text(e),
                                            );
                                          }).toList(),
                                          onChanged: (String e) async {
                                            setState(() {
                                              schoolSelected = e;
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                              FutureBuilder<List<String>>(
                                  future: getDegrees(schoolSelected),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Container(
                                        child: new DropdownButton<String>(
                                          isExpanded: true,
                                          value: degreeSelected,
                                          hint: Text(AppLocalizations.instance
                                              .text("degree", null)),
                                          items: snapshot.data.map((String e) {
                                            return DropdownMenuItem<String>(
                                              value: e,
                                              child: e == "Not Selected"
                                                  ? Text(AppLocalizations
                                                      .instance
                                                      .text(
                                                          e
                                                              .split(" ")
                                                              .join()
                                                              .toLowerCase(),
                                                          null))
                                                  : Text(e),
                                            );
                                          }).toList(),
                                          onChanged: (String e) async {
                                            setState(() {
                                              degreeSelected = e;
                                            });
                                          },
                                        ),
                                      );
                                    } else {
                                      return Container();
                                    }
                                  }),
                              FutureBuilder<List<String>>(
                                future: getSubjects(degreeSelected),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                        child: Column(children: [
                                      Text(subjectsDoneSelected == null ||
                                              subjectsDoneSelected.length == 0
                                          ? AppLocalizations.instance.text(
                                                  "profile_subjectsDone",
                                                  null) +
                                              ": " +
                                              AppLocalizations.instance.text(
                                                  "profile_noSubjectsSelected",
                                                  null)
                                          : AppLocalizations.instance.text(
                                                  "profile_subjectsDone",
                                                  null) +
                                              ": " +
                                              subjectsDoneSelected.join(', ')),
                                      ChipsChoice<String>.multiple(
                                          wrapped: false,
                                          value: subjectsDoneSelected,
                                          onChanged: (val) => setState(
                                              () => subjectsDoneSelected = val),
                                          choiceItems:
                                              C2Choice.listFrom<String, String>(
                                                  source: subjectsList,
                                                  value: (i, v) => v,
                                                  label: (i, v) => v)),
                                    ]));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              FutureBuilder<List<String>>(
                                future: getSubjects(degreeSelected),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Container(
                                        child: Column(children: [
                                      Text(subjectsAskingSelected == null ||
                                              subjectsAskingSelected.length == 0
                                          ? AppLocalizations.instance.text(
                                                  "profile_subjectsAsking",
                                                  null) +
                                              ": " +
                                              AppLocalizations.instance.text(
                                                  "profile_noSubjectsSelected",
                                                  null)
                                          : AppLocalizations.instance.text(
                                                  "profile_subjectsAsking",
                                                  null) +
                                              ": " +
                                              subjectsAskingSelected
                                                  .join(', ')),
                                      ChipsChoice<String>.multiple(
                                          wrapped: false,
                                          value: subjectsAskingSelected,
                                          onChanged: (val) => setState(() {
                                                subjectsAskingSelected = val;
                                              }),
                                          choiceItems:
                                              C2Choice.listFrom<String, String>(
                                                  source: subjectsList,
                                                  value: (i, v) => v,
                                                  label: (i, v) => v)),
                                    ]));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: TextFormField(
                                  controller: _roleController,
                                  decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 3),
                                      labelText: AppLocalizations.instance
                                          .text("profile_role", null),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always),
                                ),
                              ),
                              this.widget.currentUser.isGoogleAccount
                                  ? Container()
                                  : Column(children: [
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        child: TextFormField(
                                          obscureText: _isHidden,
                                          controller: _passwordController,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(bottom: 3),
                                            labelText: AppLocalizations.instance
                                                .text("password", null),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            suffix: InkWell(
                                              onTap: _tooglePasswordView,
                                              child: Icon(
                                                _isHidden
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 10, 10, 10),
                                        child: TextFormField(
                                          obscureText: _isHidden,
                                          controller: _password2Controller,
                                          validator: (String value) {
                                            if (value.isEmpty) {
                                              return AppLocalizations.instance.text(
                                                  "editProfile_missingConfirmation",
                                                  null);
                                            }
                                            if (_passwordController.text !=
                                                (value)) {
                                              return AppLocalizations.instance.text(
                                                  "editProfile_passwordsNotEqual",
                                                  null);
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.only(bottom: 3),
                                            labelText: AppLocalizations.instance
                                                .text("register_repeatPassword",
                                                    null),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            suffix: InkWell(
                                              onTap: _tooglePasswordView,
                                              child: Icon(
                                                _isHidden
                                                    ? Icons.visibility
                                                    : Icons.visibility_off,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ]),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      minimumSize:
                                          MaterialStateProperty.all<Size>(
                                              Size(140, 40)),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.red),
                                    ),
                                    child: Text(
                                      AppLocalizations.instance
                                          .text("cancel", null),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      minimumSize:
                                          MaterialStateProperty.all<Size>(
                                              Size(140, 40)),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.blue),
                                    ),
                                    child: Text(
                                      AppLocalizations.instance
                                          .text("save", null),
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    ),
                                    onPressed: () async {
                                      if (_formKey.currentState.validate()) {
                                        int isPasswordOK =
                                            await LoginController().loginUser(
                                                this
                                                    .widget
                                                    .currentUser
                                                    .username,
                                                _passwordController.text);
                                        if (isPasswordOK == 200) {
                                          UserApp updatedUser = new UserApp(
                                              this.widget.currentUser.username,
                                              _nameController.text,
                                              _descriptionController.text,
                                              universitySelected,
                                              schoolSelected,
                                              degreeSelected,
                                              _roleController.text,
                                              subjectsDoneSelected,
                                              subjectsAskingSelected,
                                              _phoneController.text,
                                              this
                                                  .widget
                                                  .currentUser
                                                  .profilePhoto,
                                              this.widget.currentUser.followers,
                                              this.widget.currentUser.following,
                                              this
                                                  .widget
                                                  .currentUser
                                                  .isGoogleAccount);
                                          http.Response response =
                                              await EditProfileController()
                                                  .updateProfile(updatedUser);
                                          if (response.statusCode == 200) {
                                            createToast(
                                                AppLocalizations.instance.text(
                                                    "editProfile_userCorrectlyUpdated",
                                                    null),
                                                Colors.green);
                                            Navigator.of(context)
                                                .pop(updatedUser);
                                          } else {
                                            createToast(
                                                response.body, Colors.red);
                                          }
                                        }
                                      }
                                    },
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                              )
                            ],
                          ),
                        ),
                      ),
                    )))));
  }

  void _tooglePasswordView() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  void setImageFromCamera() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    try {
      if (kIsWeb) {
        final response = await cloudinary.uploadFile(
            fileBytes: await image.readAsBytes(),
            resourceType: CloudinaryResourceType.image,
            folder: 'profilePhotos',
            fileName: this.widget.currentUser.username);
        if (response.isSuccessful) {
          createToast(
              AppLocalizations.instance
                  .text("editProfile_imageCorrectlyUploaded", null),
              Colors.green);
          this.widget.currentUser.profilePhoto = response.secureUrl;
        }
      } else {
        final response = await cloudinary.uploadFile(
            filePath: image.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'profilePhotos',
            fileName: this.widget.currentUser.username);
        if (response.isSuccessful) {
          createToast(
              AppLocalizations.instance
                  .text("editProfile_imageCorrectlyUploaded", null),
              Colors.green);
          this.widget.currentUser.profilePhoto = response.secureUrl;
        }
      }
    } on Exception catch (e) {
      print(e);
      createToast(
          AppLocalizations.instance
              .text("editProfile_imageErrorUploading", null),
          Colors.red);
    }
  }

  void setImageFromGallery() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    try {
      if (kIsWeb) {
        final response = await cloudinary.uploadFile(
            fileBytes: await image.readAsBytes(),
            resourceType: CloudinaryResourceType.image,
            folder: 'profilePhotos');
        if (response.isSuccessful) {
          createToast(
              AppLocalizations.instance
                  .text("editProfile_imageCorrectlyUploaded", null),
              Colors.green);
          this.widget.currentUser.profilePhoto = response.secureUrl;
        }
      } else {
        final response = await cloudinary.uploadFile(
            filePath: image.path,
            resourceType: CloudinaryResourceType.image,
            folder: 'profilePhotos');
        if (response.isSuccessful) {
          createToast(
              AppLocalizations.instance
                  .text("editProfile_imageCorrectlyUploaded", null),
              Colors.green);
          this.widget.currentUser.profilePhoto = response.secureUrl;
        }
      }
    } on Exception catch (e) {
      print(e);
      createToast(
          AppLocalizations.instance
              .text("editProfile_imageErrorUploading", null),
          Colors.red);
    }
  }

  Future getValidationData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var username = preferences.getString('username');
    _nameController.text = this.widget.currentUser.fullname;
    _descriptionController.text = this.widget.currentUser.description;
    _roleController.text = this.widget.currentUser.role;
    _phoneController.text = this.widget.currentUser.phone;
    this.widget.currentUser.university == null
        ? universitySelected = this.widget.currentUser.university
        : universitySelected = "Not Selected";
    subjectsAskingSelected =
        new List<String>.from(this.widget.currentUser.subjectsRequested);
    subjectsDoneSelected =
        new List<String>.from(this.widget.currentUser.subjectsDone);
    setState(() {
      finalUsername = username;
    });
  }

  Future getUniversities() async {
    universitiesList = [];
    universitiesNamesList = [];
    schoolsNamesList = [];
    degreesList = [];
    degreesNamesList = [];
    subjectsList = [];
    http.Response response = await EditProfileController().getUniversities();
    for (var university in jsonDecode(response.body)) {
      universitiesList.add(University.fromMap(university));
      universitiesNamesList.add(University.fromMap(university).name);
    }
    universitiesNamesList.add('Not Selected');
    if (universitySelected != 'Not Selected' || universitySelected != null) {
      getSchools(universitySelected);
      if (schoolSelected != null || schoolSelected != 'Not Selected') {
        getDegrees(schoolSelected);
        if (degreeSelected != null || degreeSelected != 'Not Selected') {
          getSubjects(degreeSelected);
        }
      }
    }
  }

  Future<List<String>> getSchools(String uniName) async {
    schoolsNamesList = [];
    degreesList = [];
    degreesNamesList = [];
    subjectsList = [];
    for (var university in universitiesList) {
      if (university.name == uniName) {
        schoolsNamesList = new List<String>.from(university.schools);
      }
    }
    schoolsNamesList.add('Not Selected');
    return schoolsNamesList;
  }

  Future<List<String>> getDegrees(String schoolParam) async {
    degreesList = [];
    degreesNamesList = [];
    subjectsList = [];
    http.Response response =
        await EditProfileController().getSchool(schoolParam);
    Faculty school = Faculty.fromMap(jsonDecode(response.body));
    degreesNamesList = new List<String>.from(school.degrees);
    degreesNamesList.add('Not Selected');
    return degreesNamesList;
  }

  Future<List<String>> getSubjects(String degreeParam) async {
    subjectsList = [];
    http.Response response =
        await EditProfileController().getDegree(degreeParam);
    Degree degree = Degree.fromMap(jsonDecode(response.body));
    subjectsList = new List<String>.from(degree.subjects);
    return subjectsList;
  }
}
