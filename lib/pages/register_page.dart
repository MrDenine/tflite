import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:non_helmet_mobile/models/profile.dart';
import 'package:non_helmet_mobile/modules/service.dart';
import 'package:non_helmet_mobile/pages/login.dart';
import 'package:non_helmet_mobile/widgets/load_dialog.dart';
import 'package:non_helmet_mobile/widgets/showdialog.dart';
import 'package:non_helmet_mobile/widgets/splash_logo_app.dart';

class RegisterPage extends StatefulWidget {
  RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isObscure = true;
  bool _showpass = false;
  bool _acceptRegis = false;
  final formKey = GlobalKey<FormState>();
  Profile profiles = Profile();
  String otpUser = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: const [
                Text(
                  'Helmet',
                  style: TextStyle(color: Colors.black),
                ),
                Text('Capture', style: TextStyle(color: Colors.white)),
              ],
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("ลงทะเบียนผู้ใช้",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 30,
                            ),
                            buildFirstname(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildLastname(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildEmail(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            buildConfirmPassword(),
                            const SizedBox(
                              height: 10,
                            ),
                            buildShowPassword(),
                            const SizedBox(
                              height: 30,
                            ),
                            buildAcceptCheckbox(),
                            const SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [backbt(), summitbt()],
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget buildFirstname() {
    return TextFormField(
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ชื่อ',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกชื่อ"),
      ]),
      onSaved: (value) {
        profiles.firstname = value!;
      },
    );
  }

  Widget buildLastname() {
    return TextFormField(
      keyboardType: TextInputType.name,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'นามสกุล',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.person,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกนามสกุล"),
      ]),
      onSaved: (value) {
        profiles.lastname = value!;
      },
    );
  }

  Widget buildEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'อีเมล',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.email,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกอีเมล"),
        FormBuilderValidators.email(context, errorText: "รูปแบบอีเมลไม่ถูกต้อง")
      ]),
      onSaved: (value) {
        profiles.email = value!;
      },
    );
  }

  Widget buildPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'รหัสผ่าน',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: FormBuilderValidators.compose([
        FormBuilderValidators.required(context, errorText: "กรุณากรอกรหัสผ่าน"),
        FormBuilderValidators.minLength(context, 6,
            errorText: "กรุณากรอกรหัสผ่านมากกว่า 6 ตัว")
      ]),
      onSaved: (value) {
        profiles.password = value!;
      },
    );
  }

  Widget buildConfirmPassword() {
    return TextFormField(
      obscureText: _isObscure,
      keyboardType: TextInputType.visiblePassword,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: 'ยืนยันรหัสผ่าน',
        labelStyle: TextStyle(fontSize: 18, color: Colors.grey.shade600),
        fillColor: Colors.white,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.grey,
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return 'กรุณากรอกรหัสผ่าน';
        } else if (value != profiles.password) {
          return 'รหัสผ่านไม่ตรงกัน';
        }
        return null;
      },
    );
  }

  Widget buildShowPassword() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _showpass,
            //checkColor: Colors.white,
            //activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                _showpass = value!;
                _isObscure = !_isObscure;
              });
            },
          ),
          const Text(
            'แสดงรหัสผ่าน',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAcceptCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _acceptRegis,
            // checkColor: Colors.white,
            // activeColor: Colors.black,
            onChanged: (value) {
              setState(() {
                _acceptRegis = value!;
              });
            },
          ),
          const Text(
            'ยอมรับข้อตกลง',
            style: TextStyle(
                fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget backbt() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: MaterialButton(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'ย้อนกลับ',
          style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Login_Page()),
          );
        },
      ),
    );
  }

  Widget summitbt() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.amber.shade400,
        // border: Border.all(color: Colors.amber),
      ),
      child: MaterialButton(
        // padding: const EdgeInsets.all(5.0),
        child: Text(
          'ขอ OTP \n เพื่อสมัคร',
          style: TextStyle(
              fontSize: 17,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          formKey.currentState!.save();
          if (formKey.currentState!.validate()) {
            postdataUser();
          }
        },
      ),
    );
  }

  late int user_id;
  Future<void> postdataUser() async {
    if (_acceptRegis) {
      ShowloadDialog().showLoading(context);
      try {
        var result = await registerUser({
          "email": profiles.email,
          "firstname": profiles.firstname,
          "lastname": profiles.lastname,
          "password": profiles.password,
          "datetime": DateTime.now().toString()
        });
        if (result.pass) {
          var listdata = result.data;
          if (listdata["status"] == "Succeed") {
            user_id = listdata["data"][0]["user_id"];
            reqOTP();
          } else if (listdata["data"] == "Duplicate_Email") {
            Navigator.of(context, rootNavigator: true).pop();
            normalDialog(context, "มีอีเมลนี้แล้ว");
          } else {
            Navigator.of(context, rootNavigator: true).pop();
            normalDialog(context, "ลงทะเบียนไม่สำเร็จ");
          }
        }
        // ignore: empty_catches
      } catch (e) {}
    } else {
      normalDialog(context, "กรุณากดยอมรับข้อตกลง");
    }
  }

  Future<void> reqOTP() async {
    try {
      var result = await req_OTP({
        "user_id": user_id,
        "email": profiles.email,
        "type": 1,
        "datetime": DateTime.now().toString()
      });
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.data["status"] == "Succeed") {
          dialogInputOTP();
        } else if (result.data["data"] == "Invalid email") {
          normalDialog(context, "ไม่มีอีเมลนี้ในระบบ");
        } else {
          normalDialog(context, "บันทึกไม่สำเร็จ");
        }
      }
    } catch (e) {}
  }

  Future<void> checkOTP() async {
    ShowloadDialog().showLoading(context);
    try {
      var result = await check_OTP({
        "otp": otpUser,
        "user_id": user_id,
        "email": profiles.email,
        "type": 1,
        "datetime": DateTime.now().toString()
      });
      if (result.pass) {
        Navigator.of(context, rootNavigator: true).pop();
        if (result.data["status"] == "Succeed") {
          succeedDialog(context, "ลงทะเบียนสำเร็จ", SplashPage());
        } else if (result.data["data"] == "Invalid OTP") {
          normalDialog(context, "รหัส OTP ไม่ถูกต้อง");
        } else {
          normalDialog(context, "หมดเวลาส่ง OTP กรุณาขอ OTP ใหม่อีกครั้ง");
        }
      }
    } catch (e) {}
  }

  dialogInputOTP() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SimpleDialog(
        title: const Text(
          'กรอกรหัส OTP ที่ได้รับใน 5 นาที',
          style: TextStyle(
            fontSize: 17,
          ),
        ),
        children: <Widget>[
          SingleChildScrollView(
              child: Container(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 18),
              decoration: InputDecoration(
                labelText: 'รหัส OTP',
                labelStyle:
                    TextStyle(fontSize: 18, color: Colors.grey.shade600),
                fillColor: Colors.white,
                errorStyle: const TextStyle(color: Colors.red, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.email,
                  color: Colors.grey,
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onChanged: (value) {
                otpUser = value;
              },
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: ElevatedButton(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
                    child: const Text(
                      'ตกลง',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  onPressed: () {
                    checkOTP();
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey.shade300,
                  ),
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(2, 10, 2, 10),
                    child: const Text(
                      'ยกเลิก',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
