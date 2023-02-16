import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/einstellungen.dart';
import 'package:schuelerplaner/farbManipulation.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:sqflite/sqflite.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:schuelerplaner/stundenplan.dart';
import 'package:schuelerplaner/fachuebersicht.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:schuelerplaner/hausaufgabenuebersicht.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';

Database? datenbank;

void main() async {
  var app;

  WidgetsFlutterBinding.ensureInitialized();
  await weiterleitenFallNichtErstesMal().then((value) {
    if (value) {
      app = ErsterWillkommenScreen();
    } else {
      app = Homescreen();
    }
  },);

  runApp(MaterialApp(home: app, debugShowCheckedModeBanner: false,));
}

Future<bool> weiterleitenFallNichtErstesMal() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool erstesMal = prefs.getBool('erstesMal') ?? true;
  return erstesMal;
}

class WillkommenScreen extends StatefulWidget {
  const WillkommenScreen({super.key});

  @override
  State<WillkommenScreen> createState() => _WillkommenScreenState();
}

class ErsterWillkommenScreen extends StatefulWidget {
  const ErsterWillkommenScreen({super.key});

  @override
  State<ErsterWillkommenScreen> createState() => _ErsterWillkommenScreenState();
}

class _ErsterWillkommenScreenState extends State<ErsterWillkommenScreen> {
  TextEditingController nameTextController = TextEditingController();

  void fertig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('erstesMal', false);
    prefs.setString('benutzername', nameTextController.value.text);
  }

  SnackBar leererNameWarnung() {
    return SnackBar(
      content: Text('Bitte erste einen Namen eingeben', style: TextStyle(fontSize: 16),),
      backgroundColor: Color.fromARGB(255, 77, 65, 182),
    );
  }

  final _scaffoldManagerSchluessel = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 25, 0, 255),
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Color.fromARGB(255, 25, 0, 255),
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,

      home: ScaffoldMessenger(
        key: _scaffoldManagerSchluessel,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Willkommen', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),),
                    SizedBox(height: 30,),
                    Text('Wie willst du genannt werden?', style: TextStyle(fontSize: 18),),
                    SizedBox(height: 10,),
                    TextField(
                      controller: nameTextController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                        labelText: 'Name'
                      ),            
                    ),
                    SizedBox(height: 30,),
                    FilledButton(
                      onPressed: () {
                        if (nameTextController.value.text != '') {
                          fertig();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen()));
                        } else {
                          ScaffoldMessengerState messenger = _scaffoldManagerSchluessel.currentState!;
                          messenger.showSnackBar(leererNameWarnung());
                        }               
                      },
                      child: Text('Fertig', style: TextStyle(fontWeight: FontWeight.bold),),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WillkommenScreenState extends State<WillkommenScreen> {
  void fertig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('erstesMal', false);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Poppins',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
      ),
      themeMode: ThemeMode.system,

      home: Scaffold(
        body: SafeArea(
          child: IntroductionScreen(
            pages: [
              PageViewModel(
                title: 'Viel Erfolg!',
                bodyWidget: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))
                      ),
                    ),
                  ],
                ),

                decoration: PageDecoration(
                  bodyAlignment: Alignment.center,
                  titleTextStyle: TextStyle(fontSize: 40)
                )
              ),
            ],
            next: Icon(Icons.arrow_forward),
            back: Icon(Icons.arrow_back),
            showBackButton: true,
            dotsFlex: 3,
            dotsDecorator: DotsDecorator(
              activeColor: Color.fromARGB(255, 67, 139, 79),
              activeSize: Size(30, 10),
              activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            done: Text('Fertig'),
            onDone: () {
              fertig();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homescreen()));
            },
          ),
        ),
      ),
    );
  }
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key, this.seiteWeiterleiten});

  final int? seiteWeiterleiten;

  @override
  State<Homescreen> createState() => _HomescreenState();
}

Color standardFarbe = Color.fromARGB(255, 92, 89, 228);

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
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            labelSmall:  TextStyle(color: Colors.white, fontSize: 18),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          dividerColor: Color.fromARGB(134, 102, 102, 102),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: darkColorScheme,
          //scaffoldBackgroundColor: Colors.black,
          fontFamily: 'Poppins',
          textTheme: TextTheme(
            labelSmall:  TextStyle(color: Colors.white, fontSize: 18),
          ),
          appBarTheme: AppBarTheme(
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          dividerColor: Color.fromARGB(45, 255, 255, 255),
        ),

        home: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
          ),
          body: [Dashboard(), StundenplanSeite(), FachUebersicht(), HausaufgabenSeite()][currentPageIndex],
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            selectedIndex: currentPageIndex,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            destinations: [
              NavigationDestination(icon: Icon(Icons.home,), label: 'Dashboard'),
              NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Stundenplan'),
              NavigationDestination(icon: Icon(Icons.list), label: 'Fächer'),
              NavigationDestination(icon: Icon(Icons.task), label: 'Hausaufgaben')
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
  String benutzerName = 'Benutzer';

  @override
  void initState() {
    benutzerNameLaden();
    super.initState();
  }

  void benutzerNameLaden() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    benutzerName = prefs.getString('benutzername') ?? 'Benutzer';
    setState(() {});
  }

  String begruessung() {
    var hour = DateTime.now().hour;
    if (hour < 12 && hour > 4) {
      return 'Guten Morgen,';
    }
    if (hour < 18 && hour > 4) {
      return 'Guten Tag,';
    }
    if (hour < 4 || hour == 23) {
      return 'Gute Nacht,';
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

  Future<List<Widget>> bekommeHausaufgabenBisMorgen() async {
    List<Widget> hausaufgabenBisMorgen = [];
    DateTime morgen = DateTime.now().add(Duration(days: 1));
    List<Hausaufgabe> alleHausaufgaben = await Datenbank.instance.alleNichtErledigtenHausaufgabenAuslesen();

    alleHausaufgaben.forEach((element) {
      if (element.abgabeZeitpunkt.month == morgen.month && element.abgabeZeitpunkt.day == morgen.day) {
        hausaufgabenBisMorgen.add(HausaufgabeKarteDashboard(hausaufgabe: element));
        hausaufgabenBisMorgen.add(SizedBox(height: 15,));
      }
    });

    print(hausaufgabenBisMorgen);
    return hausaufgabenBisMorgen;
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(begruessung(), style: TextStyle(fontSize: 30),),
                  Container(
                    //height: 50,
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EinstellungenSeite())).then((value) => benutzerNameLaden());
                        },
                      ),
                    ),
                  ),
                ],
              ),

              GradientText(
                benutzerName, 
                style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold, height: 1),
                colors: [standardFarbe, farbeVerdunkeln(standardFarbe, 0.07)],
              ),

              SizedBox(height: 10,),
              Divider(thickness: 2,),
              SizedBox(height: 30,),
              
              Expanded(
                child: ListView(
                  children: [
                    Text('Deine nächsten Stunden:', style: TextStyle(fontSize: 19),),
                    SizedBox(height: 12,),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor, width: 2),             
                        borderRadius: BorderRadius.circular(30)
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(top: 15, bottom: 10, left: 15, right: 15),
                        child: TimerBuilder.periodic(
                          Duration(minutes: 1),
                          builder: (context) {
                            return FutureBuilder(
                              future: bekommeNaechstenStunden(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data!.length != 0) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: snapshot.data!,
                                    );
                                  } else {
                                    return Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 0,),
                                          Icon(Icons.check, color: Theme.of(context).dividerColor.withAlpha(100), size: 50,),
                                          Text('Heute hast du keine Stunden mehr', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(150), fontSize: 15),)
                                        ],
                                      ),
                                    );
                                  }
                                } else {
                                  return Text('Lädt...');
                                }
                              }
                            );
                          },           
                        ),
                      ),
                    ),

                    SizedBox(height: 35,),
                    Text('Hausaufgaben für morgen:', style: TextStyle(fontSize: 19),),
                    SizedBox(height: 12,),

                    FutureBuilder(
                      future: bekommeHausaufgabenBisMorgen(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.length != 0) {
                            return Column(
                              children: snapshot.data!,
                            );
                          } else {
                            return Center(
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Theme.of(context).dividerColor, width: 2),             
                                  borderRadius: BorderRadius.circular(30)
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(height: 0,),
                                      Icon(Icons.celebration_outlined, color: Theme.of(context).dividerColor.withAlpha(100), size: 50,),
                                      Text('Keine Hausaufgaben bis morgen', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(150), fontSize: 15),)
                                    ],
                                  ),
                                ),
                              )
                            );
                          }
                        } else {
                          return Text('Lädt...');
                        }
                      }
                    )
                  ],
                ),
              ),     
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

class HausaufgabeKarteDashboard extends StatefulWidget {
  const HausaufgabeKarteDashboard({
    super.key,
    required this.hausaufgabe,
  });

  final Hausaufgabe hausaufgabe;

  @override
  State<HausaufgabeKarteDashboard> createState() => _HausaufgabeKarteDashboardState();
}

class _HausaufgabeKarteDashboardState extends State<HausaufgabeKarteDashboard> {
  Fach? fach = Fach(lehrer: 'Lädt...', name: 'Lädt...', farbe: '4286279837');

  @override
  void initState() {
    bekommeFach();
    super.initState();
  }

  static const wochentage = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag'
  ];

  Future<void> bekommeFach() async {
    fach = await Datenbank.instance.fachAuslesen(widget.hausaufgabe.fachid);

    if (fach == null) {
      fach = Fach(lehrer: 'Lädt...', name: 'Lädt...', farbe: '4286279837');
    }
    setState(() {});
  }

  String zeitDifferenzInTagen(DateTime vergleichsDatum) {
    Duration difference = DateTime.now().difference(vergleichsDatum);

    if (difference.inHours.abs() < 24) {
      return 'Morgen';
    }

    if (difference.inDays.abs() == 1) {
       return '2 Tage';
    }
    return difference.inDays.abs().toString() + ' Tage';
  }

  Future<void> alsErledigtMarkieren() async {
    Hausaufgabe hausaufgabe = Hausaufgabe(
      id: widget.hausaufgabe.id,
      fachid: widget.hausaufgabe.fachid,
      erstellungsZeitpunkt: widget.hausaufgabe.erstellungsZeitpunkt,
      abgabeZeitpunkt: widget.hausaufgabe.abgabeZeitpunkt,
      aufgabe: widget.hausaufgabe.aufgabe,
      erledigt: true,
    );
    await Datenbank.instance.hausaufgabeAktualisieren(hausaufgabe);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(30),
      onTap: (() {
        Navigator.push(context, MaterialPageRoute(builder: ((context) => HausaufgabeBearbeiten(hausaufgabe: widget.hausaufgabe))));
      }),
      child: DottedBorder(
        strokeWidth: 2,
        borderType: BorderType.RRect,
        color: Theme.of(context).dividerColor,
        radius: Radius.circular(30),
        dashPattern: [15, 5],
        padding: EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.library_add, size: 18, color: Theme.of(context).dividerColor.withAlpha(100),),
                    SizedBox(width: 3,),
                    Text(
                      widget.hausaufgabe.erstellungsZeitpunkt.day.toString().padLeft(2, '0') + '.' + widget.hausaufgabe.erstellungsZeitpunkt.month.toString().padLeft(2, '0') + '.' + widget.hausaufgabe.erstellungsZeitpunkt.year.toString(),
                      style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(100)),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 1.5),
                    color: Color(int.parse(fach!.farbe)),
                    borderRadius: BorderRadius.circular(30)
                  ),
                  child: Text(
                    fach!.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            // fach marker
            
            SizedBox(height: 15,),
    
            Container(
              width: double.infinity,
              child: Text(
                widget.hausaufgabe.aufgabe,
                style: TextStyle(fontSize: 17),
              ),
            ),
    
            SizedBox(height: 15,),
    
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.label_important, size: 22,),
                SizedBox(width: 8,),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    wochentage[widget.hausaufgabe.abgabeZeitpunkt.weekday - 1] + ' | ' + widget.hausaufgabe.abgabeZeitpunkt.day.toString().padLeft(2, '0') + '.' + widget.hausaufgabe.abgabeZeitpunkt.month.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ] 
            ),
            SizedBox(height: 20,),
            Container(width: double.infinity, height: 40, 
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(5),
                ),
                onPressed: () {
                  alsErledigtMarkieren();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 0,)));
                }, 
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check),
                    SizedBox(width: 5,),
                    Text('Erledigt')
                  ],
                ),
              )
            ),
          ],
        ),
      ),
    );
  }
}