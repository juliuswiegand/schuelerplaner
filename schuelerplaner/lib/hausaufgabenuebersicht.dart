import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:schuelerplaner/farbManipulation.dart';
import 'package:schuelerplaner/main.dart';
import 'package:dotted_border/dotted_border.dart';


class HausaufgabenSeite extends StatefulWidget {
  const HausaufgabenSeite({super.key});

  @override
  State<HausaufgabenSeite> createState() => _HausaufgabenSeiteState();
}

class _HausaufgabenSeiteState extends State<HausaufgabenSeite> {
  List<Hausaufgabe> alleHausaufgaben = [];
  List<Fach> alleFaecher = [];
  bool amLaden = false;

  @override
  void initState() {
    hausaufgabenLaden();
    alleFaecherLaden();
    super.initState();
  }

  Future<void> hausaufgabenLaden() async {
    setState(() => amLaden = true);
    this.alleHausaufgaben = await Datenbank.instance.alleNichtErledigtenHausaufgabenAuslesen();
    setState(() => amLaden = false);
  }

  Future<void> alleFaecherLaden() async {
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen();
  }

  Future<void> zeigeFachFehlermeldung() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Fehler'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Erstelle zuvor ein Fach bevor du Hausaufgaben erstellen kannst'),
              ],
            ),
          ),
          actions: <Widget>[
            OutlinedButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              print('Hausaufgaber erstellen');        
              Navigator.push(context, MaterialPageRoute(builder: (context) => HausaufgabenArchiv()));     
            },
            child: Icon(Icons.inventory),
          ),
          SizedBox(width: 10,),
          FloatingActionButton(
            heroTag: null,
            onPressed: () {
              print('Hausaufgaber erstellen');        
              if (alleFaecher.length != 0) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HausaufgabeErstellen()));
              } else {
                zeigeFachFehlermeldung();
              }        
            },
            child: Icon(Icons.note_add),
          ),
        ],
      ),
      body: SafeArea(
        child: (
          amLaden
          ? LinearProgressIndicator()
          : alleHausaufgaben.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sentiment_very_satisfied, size: 80, color: Theme.of(context).dividerColor.withAlpha(130),),
                  SizedBox(height: 10,),
                  Text('Keine Hausaufgaben', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(160),),),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(25),
              itemCount: alleHausaufgaben.length,
              itemBuilder: (context, index) {
                final hausaufgabe = alleHausaufgaben[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: HausaufgabeKarte(hausaufgabe: hausaufgabe),
                );
              },
            )
        ),
      )
    );
  }
}

class HausaufgabenArchiv extends StatefulWidget {
  const HausaufgabenArchiv({super.key});

  @override
  State<HausaufgabenArchiv> createState() => _HausaufgabenArchivState();
}

class _HausaufgabenArchivState extends State<HausaufgabenArchiv> {
  List<Hausaufgabe> alleHausaufgaben = [];
  List<Fach> alleFaecher = [];
  bool amLaden = false;

  @override
  void initState() {
    hausaufgabenLaden();
    super.initState();
  }

  Future<void> hausaufgabenLaden() async {
    setState(() => amLaden = true);
    this.alleHausaufgaben = await Datenbank.instance.alleErledigtenHausaufgabenAuslesen();
    setState(() => amLaden = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Erledigte Hausaufgaben'),
      ),

      body: SafeArea(
        child: (
          amLaden
          ? LinearProgressIndicator()
          : alleHausaufgaben.isEmpty
            ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.dangerous_outlined, size: 80, color: Theme.of(context).dividerColor.withAlpha(130),),
                  SizedBox(height: 10,),
                  Text('Hier ist es leer', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(160),),),
                ],
              ),
            )
            : ListView.builder(
              padding: const EdgeInsets.all(25),
              itemCount: alleHausaufgaben.length,
              itemBuilder: (context, index) {
                final hausaufgabe = alleHausaufgaben[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: HausaufgabeArchivKarte(hausaufgabe: hausaufgabe, seiteAktualisieren: hausaufgabenLaden,),
                );
              },
            )
        ),
      ),
    );
  }
}

class HausaufgabeArchivKarte extends StatefulWidget {
  const HausaufgabeArchivKarte({
    super.key,
    required this.hausaufgabe,
    required this.seiteAktualisieren
  });

  final Hausaufgabe hausaufgabe;
  final seiteAktualisieren;

  @override
  State<HausaufgabeArchivKarte> createState() => _HausaufgabeArchivKarteState();
}

class _HausaufgabeArchivKarteState extends State<HausaufgabeArchivKarte> {
  Fach? fach = Fach(lehrer: 'Lädt...', name: 'Lädt...', farbe: '4286279837');

  @override
  void initState() {
    bekommeFach();
    ueberpeufeAlter();
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
  
  Future<void> hausaufgabeLoeschen() async {
    await Datenbank.instance.hausaufgabeLoeschen(widget.hausaufgabe.id);
  }

  Future<void> hausaufgabeAlsUnerledigtMarkieren() async {
    Hausaufgabe hausaufgabe = Hausaufgabe(
      id: widget.hausaufgabe.id,
      fachid: widget.hausaufgabe.fachid, 
      erledigt: false, 
      erstellungsZeitpunkt: widget.hausaufgabe.erstellungsZeitpunkt, 
      abgabeZeitpunkt: widget.hausaufgabe.abgabeZeitpunkt, 
      aufgabe: widget.hausaufgabe.aufgabe,
    );

    await Datenbank.instance.hausaufgabeAktualisieren(hausaufgabe);
  }

  Future<void> ueberpeufeAlter() async {
    if (berechneUebrigeZeit() == 0) {
      await Datenbank.instance.hausaufgabeLoeschen(widget.hausaufgabe.id);
    }  
  }

  int berechneUebrigeZeit() {
    int maximalesAlter = 14; // Tage
  	DateTime loeschungsTag = widget.hausaufgabe.abgabeZeitpunkt.add(Duration(days: maximalesAlter));
    Duration differenz = DateTime.now().difference(loeschungsTag);

    if (differenz.inDays.abs() <= 0) {
      return 0;
    }

    return differenz.inDays.abs();
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
                    Icon(Icons.delete_forever, size: 18, color: Theme.of(context).dividerColor.withAlpha(100),),
                    SizedBox(width: 3,),
                    Text(
                      'Löschung in ' + berechneUebrigeZeit().toString() + ' Tagen',
                      style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(100), fontSize: 12),
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
            Row(
              children: [
                Container(height: 40, 
                  child: ElevatedButton(
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(5),
                    ),
                    onPressed: () {
                      hausaufgabeLoeschen();
                      widget.seiteAktualisieren();
                    }, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete),
                      ],
                    ),
                  )
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Container(height: 40, 
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all(5),
                      ),
                      onPressed: () {
                        hausaufgabeAlsUnerledigtMarkieren();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
                      }, 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.unarchive),
                          SizedBox(width: 5,),
                          Text('Als unerledigt markieren')
                        ],
                      ),
                    )
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class HausaufgabeKarte extends StatefulWidget {
  const HausaufgabeKarte({
    super.key,
    required this.hausaufgabe,
  });

  final Hausaufgabe hausaufgabe;

  @override
  State<HausaufgabeKarte> createState() => _HausaufgabeKarteState();
}

class _HausaufgabeKarteState extends State<HausaufgabeKarte> {
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
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

class HausaufgabeErstellen extends StatefulWidget {
  const HausaufgabeErstellen({super.key});

  @override
  State<HausaufgabeErstellen> createState() => _HausaufgabeErstellenState();
}

class _HausaufgabeErstellenState extends State<HausaufgabeErstellen> {
  late List<Fach> alleFaecher;
  bool amLaden = false;
  bool ersteMalLaden = true;
  Fach ausgewaehltesFach = Fach(lehrer: '', id: 0, name: '', farbe: '');
  DateTime abgabeDatum = DateTime.now().add(Duration(days: 1));
  DateTime erstellDatum = DateTime(2000, 1, 1);
  final List<bool> abgabeTerminAuswahlen = <bool>[true, false];
  bool gefunden = false;
  TextEditingController aufgabeTextController = TextEditingController();

  @override void initState() {
    alleFaecherAuslesen();
    super.initState();
  }

  Future alleFaecherAuslesen() async {
    setState(() => amLaden = true);
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen(); 
    setState(() => amLaden = false);

    if (alleFaecher.length == 0) {
      Navigator.pop(context);
    }
  }

  DecoratedBox alleFaecherDropdown() {
    List<String> alleFachnamen = [];
    
    for (Fach fach in alleFaecher) {
      alleFachnamen.add(fach.name);
    }

    if (ersteMalLaden) {
      ausgewaehltesFach = alleFaecher[0];
    }
    
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Color(int.parse(ausgewaehltesFach.farbe))),
        borderRadius: BorderRadius.circular(30),
        color: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 11),
        child: DropdownButton(
          style: Theme.of(context).textTheme.headline1,
          dropdownColor: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18),
          isExpanded: true,
          underline: Container(),
          value: ausgewaehltesFach,
          onChanged: (wert) {
            ersteMalLaden = false;
            gefunden = false;
            setState(() {
              ausgewaehltesFach = wert!;
            });
          },
          items: alleFaecher.map((fach) {
            return DropdownMenuItem(
              child: Text(fach.name),
              value: fach,
            );
          }).toList(),
        ),
      ),
    );
  }

  void zeigAbgabedatumAuswahl(context) async {
    abgabeDatum = (await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2200)))!;
    setState(() {});
  }

  Future<void> gibNaechstenStundenZeitpunkt() async {
    int tagIndex = DateTime.now().weekday;
    if (tagIndex == 7) {
      tagIndex = 0;
    }

    for (var i = 0; i < 7; i++) {
      List<Schulstunde> alleStunden = await Datenbank.instance.alleStundenAuslesen(tagIndex);

      alleStunden.forEach((element) {
        if (element.fachid == ausgewaehltesFach.id) {
          if (gefunden == false) {
            print('Naechste mal am tag ' + i.toString());
            abgabeDatum = DateTime.now().add(Duration(days: i + 1));
            setState(() {});
          }     
          gefunden = true;
          return; 
        }
      });

      if (tagIndex < 6) {
        tagIndex++;
      } else {
        tagIndex = 0;
      }
    }
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

  Future<void> hausaufgabeSpeichern() async {
    Hausaufgabe hausaufgabe = Hausaufgabe(
      fachid: ausgewaehltesFach.id!, 
      erledigt: false, 
      erstellungsZeitpunkt: DateTime.now(), 
      abgabeZeitpunkt: abgabeDatum, 
      aufgabe: aufgabeTextController.value.text,
    );
    
    await Datenbank.instance.hausaufgabeErstellen(hausaufgabe);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Hausaufgabe erstellen'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100), width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zugewiesenes Fach:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),
                  amLaden
                    ? CircularProgressIndicator()
                    : alleFaecherDropdown(),
                  
                  SizedBox(height: 20,),
                  Text('Bis wann ist die Hausaufgabe:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          zeigAbgabedatumAuswahl(context);
                        }, 
                        child: Text(
                          wochentage[abgabeDatum.weekday - 1] + '  |  ' + abgabeDatum.day.toString() + '.' + abgabeDatum.month.toString() + '.' + abgabeDatum.year.toString()
                        ),
                      ),
                      gefunden
                        ? OutlinedButton(
                          onPressed: null,
                          child: Row(
                            children: 
                            [
                              Icon(Icons.redo),
                              SizedBox(width: 4,),
                              Text(
                                ausgewaehltesFach.name,
                              ),
                            ]
                          ),
                        )
                        : OutlinedButton(
                        onPressed: () {
                          gibNaechstenStundenZeitpunkt();
                        }, 
                        child: Row(
                          children: 
                          [
                            Icon(Icons.redo),
                            SizedBox(width: 4,),
                            Text(
                              ausgewaehltesFach.name,
                            ),
                          ]
                        ),
                      ),
                    ],                   
                  ),

                  SizedBox(height: 20,),
                  Text('Aufgabe:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),

                  Expanded(
                    child: TextField(
                      controller: aufgabeTextController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        isCollapsed: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).dividerColor.withAlpha(40)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).dividerColor.withAlpha(40)),
                          borderRadius: BorderRadius.circular(30),
                        )
                      ),
                    ),
                  ),

                  SizedBox(height: 15,),

                  Container(width: double.infinity, height: 65, child: ElevatedButton(
                    onPressed: () {hausaufgabeSpeichern(); 
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
                    }, 
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add),
                        SizedBox(width: 5,),
                        Text('Erstellen')
                      ],
                    ),
                    style: ButtonStyle(
                      elevation: MaterialStateProperty.all(10),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HausaufgabeBearbeiten extends StatefulWidget {
  const HausaufgabeBearbeiten({super.key, required this.hausaufgabe,});

  final Hausaufgabe hausaufgabe;

  @override
  State<HausaufgabeBearbeiten> createState() => _HausaufgabeBearbeitenState();
}

class _HausaufgabeBearbeitenState extends State<HausaufgabeBearbeiten> {
  Hausaufgabe weitergegebenenHausaufgabe = Hausaufgabe(fachid: 0, erledigt: false, erstellungsZeitpunkt: DateTime(2000), abgabeZeitpunkt: DateTime(2000), aufgabe: '');

  late List<Fach> alleFaecher;
  bool amLaden = false;
  bool ersteMalLaden = true;
  Fach ausgewaehltesFach = Fach(lehrer: '', id: 0, name: '', farbe: '');
  DateTime abgabeDatum = DateTime.now().add(Duration(days: 1));
  DateTime erstellDatum = DateTime(2000, 1, 1);
  bool gefunden = false;
  TextEditingController aufgabeTextController = TextEditingController();

  @override void initState() {
    alleFaecherAuslesen();
    weitergegebenenHausaufgabe = widget.hausaufgabe;
    abgabeDatum = weitergegebenenHausaufgabe.abgabeZeitpunkt;
    erstellDatum = weitergegebenenHausaufgabe.erstellungsZeitpunkt;
    aufgabeTextController.text = weitergegebenenHausaufgabe.aufgabe;

    super.initState();
  }

  Future alleFaecherAuslesen() async {
    setState(() => amLaden = true);
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen(); 
    setState(() => amLaden = false);

    if (alleFaecher.length == 0) {
      Navigator.pop(context);
    }
  }

  DecoratedBox alleFaecherDropdown() {
    for (var i = 0; i < alleFaecher.length; i++) {
      if (alleFaecher[i].id == widget.hausaufgabe.fachid && ersteMalLaden) {
        ausgewaehltesFach = alleFaecher[i];
      }
    }
    
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Color(int.parse(ausgewaehltesFach.farbe))),
        borderRadius: BorderRadius.circular(30),
        color: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 11),
        child: DropdownButton(
          style: Theme.of(context).textTheme.headline1,
          dropdownColor: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18),
          isExpanded: true,
          underline: Container(),
          value: ausgewaehltesFach,
          onChanged: (wert) {
            ersteMalLaden = false;
            gefunden = false;
            setState(() {
              ausgewaehltesFach = wert!;
            });
          },
          items: alleFaecher.map((fach) {
            return DropdownMenuItem(
              child: Text(fach.name),
              value: fach,
            );
          }).toList(),
        ),
      ),
    );
  }

  void zeigAbgabedatumAuswahl(context) async {
    abgabeDatum = (await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2200)))!;
    setState(() {});
  }

  Future<void> gibNaechstenStundenZeitpunkt() async {
    int tagIndex = DateTime.now().weekday;
    if (tagIndex == 7) {
      tagIndex = 0;
    }

    for (var i = 0; i < 7; i++) {
      List<Schulstunde> alleStunden = await Datenbank.instance.alleStundenAuslesen(tagIndex);

      alleStunden.forEach((element) {
        if (element.fachid == ausgewaehltesFach.id) {
          if (gefunden == false) {
            print('Naechste mal am tag ' + i.toString());
            abgabeDatum = DateTime.now().add(Duration(days: i + 1));
            setState(() {});
          }     
          gefunden = true;
          return; 
        }
      });

      if (tagIndex < 6) {
        tagIndex++;
      } else {
        tagIndex = 0;
      }
    }
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

  Future<void> hausaufgabeSpeichern() async {
    Hausaufgabe hausaufgabe = Hausaufgabe(
      id: widget.hausaufgabe.id,
      fachid: ausgewaehltesFach.id!, 
      erledigt: widget.hausaufgabe.erledigt, 
      erstellungsZeitpunkt: erstellDatum, 
      abgabeZeitpunkt: abgabeDatum, 
      aufgabe: aufgabeTextController.value.text,
    );
    
    await Datenbank.instance.hausaufgabeAktualisieren(hausaufgabe);
  }

  Future<void> hausaufgabeLoeschen() async {
    await Datenbank.instance.hausaufgabeLoeschen(widget.hausaufgabe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Hausaufgabe bearbeiten'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor.withAlpha(100), width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zugewiesenes Fach:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),
                  amLaden
                    ? CircularProgressIndicator()
                    : alleFaecherDropdown(),
                  
                  SizedBox(height: 20,),
                  Text('Bis wann ist die Hausaufgabe:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          zeigAbgabedatumAuswahl(context);
                        }, 
                        child: Text(
                          wochentage[abgabeDatum.weekday - 1] + '  |  ' + abgabeDatum.day.toString() + '.' + abgabeDatum.month.toString() + '.' + abgabeDatum.year.toString()
                        ),
                      ),
                      gefunden
                        ? OutlinedButton(
                          onPressed: null,
                          child: Row(
                            children: 
                            [
                              Icon(Icons.redo),
                              SizedBox(width: 4,),
                              Text(
                                ausgewaehltesFach.name,
                              ),
                            ]
                          ),
                        )
                        : OutlinedButton(
                        onPressed: () {
                          gibNaechstenStundenZeitpunkt();
                        }, 
                        child: Row(
                          children: 
                          [
                            Icon(Icons.redo),
                            SizedBox(width: 4,),
                            Text(
                              ausgewaehltesFach.name,
                            ),
                          ]
                        ),
                      ),
                    ],                   
                  ),

                  SizedBox(height: 20,),
                  Text('Aufgabe:', style: TextStyle(fontSize: 17),),
                  SizedBox(height: 10,),

                  Expanded(
                    child: TextField(
                      controller: aufgabeTextController,
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(20),
                        isCollapsed: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).dividerColor.withAlpha(40)),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 2, color: Theme.of(context).dividerColor.withAlpha(40)),
                          borderRadius: BorderRadius.circular(30),
                        )
                      ),
                    ),
                  ),

                  SizedBox(height: 15,),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(height: 65, child: ElevatedButton(
                        onPressed: () {hausaufgabeLoeschen(); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
                        }, 
                        child: Icon(Icons.delete),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(10),
                        ),
                      )),

                      SizedBox(width: 20,),

                      Expanded(
                        child: Container(height: 65, child: ElevatedButton(
                          onPressed: () {hausaufgabeSpeichern(); 
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
                          }, 
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.update),
                              SizedBox(width: 5,),
                              Text('Aktualisieren')
                            ],
                          ),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(10),
                          ),
                        )),
                      ),

                    ]
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}