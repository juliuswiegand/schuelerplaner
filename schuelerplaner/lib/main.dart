import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:schuelerplaner/stundenplan.dart';
import 'package:schuelerplaner/fachuebersicht.dart';

Database? datenbank;

void main() {
  runApp(Homescreen());
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key, this.seiteWeiterleiten});

  final int? seiteWeiterleiten;

  @override
  State<Homescreen> createState() => _HomescreenState();
}

Color standardFarbe = Color.fromARGB(255, 67, 134, 73);

class _HomescreenState extends State<Homescreen> {
  int currentPageIndex = 0;

  @override
  void initState() {
    if (widget.seiteWeiterleiten != null) {
      print('Direkt weiterleiten');
      currentPageIndex = widget.seiteWeiterleiten!;
    }
    super.initState();
  }

  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? dark) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && dark != null) {
          lightColorScheme = lightDynamic.harmonized()..copyWith();
          lightColorScheme = lightColorScheme.copyWith(secondary: standardFarbe);
          darkColorScheme = dark.harmonized()..copyWith();
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: standardFarbe);
          darkColorScheme = ColorScheme.fromSeed(seedColor: standardFarbe, brightness: Brightness.dark);
        }
      

      return MaterialApp(
        debugShowCheckedModeBanner: false,

        theme: ThemeData(
          useMaterial3: true,
          colorScheme: lightColorScheme,
          textTheme: TextTheme(
            labelMedium: TextStyle(color: Colors.white, fontSize: 18),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          )
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          textTheme: TextTheme(
            labelMedium: TextStyle(color: Colors.white, fontSize: 18),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          )
        ),

        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: [Dashboard(), StundenplanSeite(), FachUebersicht()][currentPageIndex],
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            destinations: [
              NavigationDestination(icon: Icon(Icons.home,), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Stundenplan'),
              NavigationDestination(icon: Icon(Icons.list), label: 'Faecher')
            ],
          ),
        ));
      },
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            // Begruessung des Users
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topLeft,
              child: Text(
                'Hallo,',
                style: Theme.of(context).textTheme.headline3,
              ),
            ),
            GradientText(
              'Cedric',
              gradientDirection: GradientDirection.ltr,
              gradientType: GradientType.radial,
              radius: 6,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              colors: [
                Color.fromARGB(255, 7, 235, 94), 
                Color.fromARGB(255, 110, 226, 197)
              ]
            ),

            SizedBox(height: 25,),

            // auflistung nächster Stunden
            Text(
              'Deine nächsten Stunden:',
              style: Theme.of(context).textTheme.headline4,
            ),

            SizedBox(height: 10),

            naechsteStundeKarte(),
            naechsteStundeKarte(),

            SizedBox(height: 30),
            
          ],
        ),
      ),
    );
  }
}

class naechsteStundeKarte extends StatelessWidget {
  const naechsteStundeKarte({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 70, 153, 72),
        borderRadius: BorderRadius.all(Radius.circular(15.0))
      ),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Text(
          'Biologie',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      )
    );
  }
}








