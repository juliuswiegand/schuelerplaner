import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/modelle/stundenplanmodell.dart';
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

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String begruessung() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Guten Morgen,';
    }
    if (hour < 17) {
      return 'Guten Tag,';
    }
    return 'Guten Abend,';
  }

  Future<List<Widget>> bekommeNaechstenStunden() async {
    List<Widget> naechstenStundenKarten = [];
    List<Fach> alleFaecher = [];
    List<Schulstunde> naechstenStunden = [];
    List<Schulstunde> naechstenStundenAlle = [];
    final int aktuellerTagIndex = DateTime.now().weekday - 1;

    naechstenStundenAlle = await Datenbank.instance.alleStundenAuslesen(aktuellerTagIndex);

    DateTime aktuelleZeit = DateTime(2000, 1, 1, TimeOfDay.now().hour, TimeOfDay.now().minute);

    // sortiere stunden aus die schon stattgefunden haben
    for (var i = 0; i < naechstenStundenAlle.length; i++) {
      if (naechstenStundenAlle[i].endzeit.isAfter(aktuelleZeit)) {
        naechstenStunden.add(naechstenStundenAlle[i]);
      }
    }

    // lade die fachobjekte der schulstunden
    for (var i = 0; i < naechstenStunden.length; i++) {
      Fach? fach = await Datenbank.instance.fachAuslesen(naechstenStunden[i].fachid);
      alleFaecher.add(fach!);
    }

    // wenn liste lehr zeig benutzer das er keine stunden mehr hat
    if (naechstenStunden.length == 0) {
      return [];
    }

    // zeige nur die naechsten 3 stunden
    for (var i = 0; i < naechstenStunden.length; i++) {
      if (i <= 2) {
        naechstenStundenKarten.add(naechsteStundeKarte(
          fachname: alleFaecher[i].name,
          farbe: alleFaecher[i].farbe,
          startzeit: naechstenStunden[i].startzeit,
          endzeit: naechstenStunden[i].endzeit,
          raum: naechstenStunden[i].raum,
        ));
        naechstenStundenKarten.add(SizedBox(height: 7,));
      }
    }

    return naechstenStundenKarten;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ 
              Container(
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    iconSize: 30,
                    style: ButtonStyle(
                      side: MaterialStatePropertyAll(
                        BorderSide(
                          color: Colors.white.withAlpha(50),
                        ),
                      )
                    ),
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      print('Pressed');
                    },
                  ),
                ),
              ),
              Text(begruessung(), style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),

              SizedBox(height: 40,),

              Text('Deine nächsten Stunden:', style: TextStyle(fontSize: 19),),
              SizedBox(height: 12,),
              
              FutureBuilder(
                future: bekommeNaechstenStunden(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: snapshot.data!,
                    );
                  } else {
                    return Text('Lädt...');
                  }
                })           
            ]
          ),
        ),
      ),
    );
  }
}

class naechsteStundeKarte extends StatelessWidget {
  const naechsteStundeKarte({
    super.key,
    required this.fachname,
    required this.farbe,
    required this.startzeit,
    required this.endzeit,
    required this.raum
  });

  final String fachname;
  final String farbe;
  final DateTime startzeit;
  final DateTime endzeit;
  final String raum;

  double berechneZeitFortschritt() {
    DateTime aktuelleZeit = DateTime(2000, 1, 1, TimeOfDay.now().hour, TimeOfDay.now().minute);

    Duration differenz = startzeit.difference(endzeit);
    int differenzInMinuten = differenz.inMinutes;

    Duration aktuelleDifferenz = startzeit.difference(aktuelleZeit);
    int aktuelleDifferenzInMinuten = aktuelleDifferenz.inMinutes;
    //print(aktuelleDifferenzInMinuten);

    if (differenzInMinuten == 0) {
      return 1;
    }

    double prozentualerFortschritt = aktuelleDifferenzInMinuten / differenzInMinuten;

    return prozentualerFortschritt;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      height: 55,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          LinearProgressIndicator(
            minHeight: 55,
            value: berechneZeitFortschritt(),
            valueColor: AlwaysStoppedAnimation(Color(int.parse(farbe))),
            backgroundColor: Color(int.parse(farbe)).withAlpha(60),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 17),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fachname,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.room, color: Colors.white,),
                      SizedBox(width: 2,),
                      Text(
                        raum,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ]
                  ),
                ]
              ),
            ),
        ],
      ),
    );
  }
}