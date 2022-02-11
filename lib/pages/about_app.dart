import 'package:flutter/material.dart';

class AboutApp extends StatefulWidget {
  AboutApp({Key? key}) : super(key: key);

  @override
  State<AboutApp> createState() => _AboutAppState();
}

class _AboutAppState extends State<AboutApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: const Text(
            'About App',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            //textAlign: TextAlign.center,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
            child: Container(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Row(
                children: const [
                  Text(
                    "ติดต่อ:\t\t\t\t\t\t\t\t\t\t",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "test@mail.com",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  )
                ],
              )
            ],
          ),
        )));
  }
}
