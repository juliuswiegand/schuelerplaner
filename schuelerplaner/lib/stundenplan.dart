import 'package:flutter/material.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/main.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:schuelerplaner/farbManipulation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StundenplanSeite extends StatefulWidget {
  const StundenplanSeite({
    super.key,
  });

  @override
  State<StundenplanSeite> createState() => _StundenplanSeiteState();
}

class _StundenplanSeiteState extends State<StundenplanSeite> {
  // lade liste mit stunden des aktuellen tages
  final int aktuellerTagIndex = DateTime.now().weekday - 1; // 0: Montag, 1: Dienstag, 2: Mittwoch ...
  int ausgewaehlterTagIndex = 0;
  bool amLaden = false;
  bool amHinzufuegen = false;
  List<String> alleFachNamen = [];
  late List<Schulstunde> stundenplan;
  late List<Fach> alleFaecher;

  @override
  void initState() {
    super.initState();

    ausgewaehlterTagIndex = aktuellerTagIndex;

    setzeAlleFaecher();
    tagAktualisert(aktuellerTagIndex);
    
  }

  Future tagAktualisert(int tag) async {
    ausgewaehlterTagIndex = tag;
    print('Tag wurde geaendert zu Tag $tag');

    // lädt eine liste mit allen stunden am aktell ausgewählten tag
    setState(() => amLaden = true);
    this.stundenplan = await Datenbank.instance.alleStundenAuslesen(ausgewaehlterTagIndex);
    setState(() => amLaden = false);
  } 

  Future setzeAlleFaecher() async {
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen();
  }

  int bekommAnzahlFaecher() {
    return alleFaecher.length;
  }

  Future<String> bekommeFachNameVonId(int id) async {
    Fach? fach = await Datenbank.instance.fachAuslesen(id);
    if (fach != null) {
      return fach.name;
    } else {
      throw Exception('Fach mit der id $id konnte nicht gefunden werden');
    }
  }

  Future<String> bekommeFachFarbeVonId(int id) async {
    Fach? fach = await Datenbank.instance.fachAuslesen(id);
    if (fach != null) {
      return fach.farbe;
    } else {
      throw Exception('Fach mit der id $id konnte nicht gefunden werden');
    }
  }

  Future<Fach> bekommeFachVonId(int id) async {
    Fach? fach = await Datenbank.instance.fachAuslesen(id);
    if (fach != null) {
      return fach;
    } else {
      throw Exception('Fach mit der id $id konnte nicht gefunden werden');
    }
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
                Text('Erstelle zuvor ein Fach bevor du Stunden zuweisen kannst'),
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (bekommAnzahlFaecher() != 0) {
                Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NeueStundeHinzufuegen(ausgewaehlterTag: ausgewaehlterTagIndex,))
              ).then((wert) => {tagAktualisert(ausgewaehlterTagIndex)});
            } else {
              print('Es gibt noch keine Faeher');
              zeigeFachFehlermeldung();
            }
          }, 
          child: Icon(Icons.add),
          heroTag: 'NeueStundeSeite',
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              children: [
                WochentagAuswahl(tagAktualisert: tagAktualisert,),
                SizedBox(height: 15,),
                amLaden
                  ? CircularProgressIndicator()
                  : stundenplan.isEmpty
                    ? Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 80, color: Theme.of(context).dividerColor.withAlpha(130),),
                            SizedBox(height: 10,),
                            Text('Noch keine Stunden hinzugefügt', style: TextStyle(fontSize: 17, color: Theme.of(context).dividerColor.withAlpha(160),),)
                          ],
                        ),
                      )
                    : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,                     
                        padding: const EdgeInsets.all(10),
                        itemCount: stundenplan.length,
                        itemBuilder: (context, index) {
                          final stunde = stundenplan[index];
                          // wartet bis der fachname anhand der id in der datenbank gefunden wurde um diesen anzuzeigen
                          return FutureBuilder(
                            future: bekommeFachVonId(stunde.fachid),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: StundenplanKarte(fach: snapshot.data!, tag: ausgewaehlterTagIndex, schulstunde: stunde,),
                                );
                              } else {
                                Fach tempFach = Fach(lehrer: 'Lädt', name: 'Lädt', farbe: '4286279837');
                                return StundenplanKarte(fach: tempFach, tag: ausgewaehlterTagIndex, schulstunde: stunde,);
                              }
                            },
                          );
                        },
                      ),
                    ),
              ]
            ),
          ),
        ),
      );
  }
}
class StundenDetails extends StatelessWidget {
  const StundenDetails({
    super.key,
    required this.wochentag,
    required this.schulstunde,
    required this.fach,
  });

  final int wochentag;
  final Schulstunde schulstunde;
  final Fach fach;

  Future loeschen(BuildContext context) async {
    print('Lösche Eintrag');
    await Datenbank.instance.stundeLoeschen(schulstunde.id, wochentag);
    Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 1,)));
  }

  @override
  Widget build(BuildContext context) {
    double berechneZeitFortschritt() {
      DateTime startzeit = schulstunde.startzeit;
      DateTime endzeit = schulstunde.endzeit;
      DateTime aktuelleZeit = DateTime(2000, 1, 1, TimeOfDay.now().hour, TimeOfDay.now().minute);

      Duration differenz = startzeit.difference(endzeit);
      int differenzInMinuten = differenz.inMinutes;

      Duration aktuelleDifferenz = startzeit.difference(aktuelleZeit);
      int aktuelleDifferenzInMinuten = aktuelleDifferenz.inMinutes;

      if (differenzInMinuten == 0) {
        return 1;
      }

      double prozentualerFortschritt = aktuelleDifferenzInMinuten / differenzInMinuten;

      if (prozentualerFortschritt > 1) {
        return 1;
      }
      if (prozentualerFortschritt < 0) {
        return 0;
      }
      return prozentualerFortschritt;
    }

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        toolbarHeight: 50,
        backgroundColor: Color(int.parse(fach.farbe)),
        leading: BackButton(
          color: Colors.white,
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            backgroundColor: Color(int.parse(fach.farbe)).withRed(255),
            child: Icon(Icons.delete, color: Colors.white,),
            onPressed: () {
              loeschen(context);
            },
            heroTag: null,
          ),
          SizedBox(height: 10,),
          FloatingActionButton(
            backgroundColor: Color(int.parse(fach.farbe)).withAlpha(150),
            child: Icon(Icons.edit, color: Colors.white,),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StundeBearbeitenSeite(ausgewaehlterTag: wochentag, schulstunde: schulstunde, fach: fach)));
            },
          ),      
        ],
      ),
      //backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0, 1],
                        colors: [
                          Color(int.parse(fach.farbe)),
                          farbeVerdunkeln(Color(int.parse(fach.farbe)), 0.1),
                        ]
                      ),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40))
                    ),
                    height: 200,
                  ),
                  Padding(
                    padding: EdgeInsets.all(45),
                    child: Center(
                      child: Column( 
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            fach.name,
                            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            fach.lehrer,
                            style: TextStyle(fontSize: 20, color: Colors.white,),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              TimerBuilder.periodic(
                Duration(minutes: 1),
                builder: (context) {
                  return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
                  child: Stack(
                    children: [ 
                      ClipRRect(
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(500), bottomRight: Radius.circular(500)),
                        child: LinearProgressIndicator(
                          minHeight: 30,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(int.parse(fach.farbe))),
                          backgroundColor: Color(int.parse(fach.farbe)).withAlpha(50),
                          value: berechneZeitFortschritt(),
                        ),
                      ),
                      Center(
                        child: Text(
                          (berechneZeitFortschritt()*100).toInt().toString() + "%",
                          style: TextStyle(fontSize: 20,),
                        )
                      ),
                    ]
                  ),
                );
                }
              ),
              SizedBox(height: 50),
              Row(
                children: [
                  Icon(Icons.room_rounded, size: 32,),
                  SizedBox(width: 10,),
                  Text(schulstunde.raum, style: TextStyle(fontSize: 25),)
                ],
              ),
              SizedBox(height: 20,),
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.schedule, size: 32,),
                  SizedBox(width: 10,),
                  Text(
                    schulstunde.startzeit.hour.toString().padLeft(2, '0') + ':' + schulstunde.startzeit.minute.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(width: 15,),
                  Icon(Icons.chevron_right),
                  SizedBox(width: 15,),
                  Text(
                    schulstunde.endzeit.hour.toString().padLeft(2, '0') + ':' + schulstunde.endzeit.minute.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: 25),
                  ),
                ],
              ),
              SizedBox(height: 5,),
              
            ],
          ),
        ),
      ),
    );
  }
}

class NeueStundeHinzufuegen extends StatefulWidget {
  const NeueStundeHinzufuegen({
    super.key,
    required this.ausgewaehlterTag,
  });

  final int ausgewaehlterTag;

  @override
  State<NeueStundeHinzufuegen> createState() => _NeueStundeHinzufuegenState();
}

class _NeueStundeHinzufuegenState extends State<NeueStundeHinzufuegen> {
  late List<Fach> alleFaecher;
  bool amLaden = false;
  bool ersteMalLaden = true;
  int ausgewaelterTagIndex = 0;
  int standardStundenLaenge = 45;

  TextEditingController raumNameController = TextEditingController();

  // werter fuer neue stunde  
  Fach ausgewaehltesFach = Fach(lehrer: '', id: 0, name: '', farbe: '');
  TimeOfDay startzeit = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endzeit = TimeOfDay(hour: 0, minute: 0);
  String raum = '';

  @override
  void initState() {
    super.initState();

    bekommeBenutzerStundenLaenge();
    alleFaecherAuslesen();
  }

  Future<void> bekommeBenutzerStundenLaenge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    standardStundenLaenge = prefs.getInt('stundenLaenge') ?? 45;
  }

  Future<void> schulstundeHinzufuegen() async {
    int ausgewaelterTagIndex = widget.ausgewaehlterTag;

    DateTime konvertierteStartzeit = DateTime(2000, 1, 1, startzeit.hour, startzeit.minute);
    DateTime konvertierteEndzeit = DateTime(2000, 1, 1, endzeit.hour, endzeit.minute);

    Schulstunde schulstunde = Schulstunde(
      fachid: ausgewaehltesFach.id!, 
      raum: raumNameController.value.text, 
      startzeit: konvertierteStartzeit, 
      endzeit: konvertierteEndzeit
    );

    await Datenbank.instance.stundeHinzufuegen(ausgewaelterTagIndex, schulstunde);
  }
  void startZeitAuswaehlen(context) async {
    startzeit = (await showTimePicker(context: context, initialTime: TimeOfDay.now()))!;
    DateTime startzeitDateTime = DateTime(2000, 1, 1, startzeit.hour, startzeit.minute);
    DateTime vorschlagEndZeitDateTime = startzeitDateTime.add(Duration(minutes: standardStundenLaenge));

    // setze endzeit automatisch auf +45min um typische stundenlaenge vorzuschlagen
    endzeit = TimeOfDay(hour: vorschlagEndZeitDateTime.hour, minute: vorschlagEndZeitDateTime.minute);

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {});
  }

  void endZeitAuswaehlen(context) async {
    endzeit = (await showTimePicker(context: context, initialTime: TimeOfDay.now()))!;
    setState(() {});
  }

  String gibZeitUnterschied() {
    DateTime startzeitDateTime = DateTime(2000, 1, 1, startzeit.hour, startzeit.minute);
    DateTime endzeitDateTime = DateTime(2000, 1, 1, endzeit.hour, endzeit.minute);

    Duration differenz = startzeitDateTime.difference(endzeitDateTime);
    return differenz.inMinutes.abs().toString();
  }

  Future alleFaecherAuslesen() async {
    setState(() => amLaden = true);
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen(); 
    setState(() => amLaden = false);
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
          style: Theme.of(context).textTheme.labelSmall,
          dropdownColor: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18),
          isExpanded: true,
          underline: Container(),
          value: ausgewaehltesFach,
          onChanged: (wert) {
            ersteMalLaden = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neue Stunde hinzufügen'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center (
            child: Column(
              children: [
                SizedBox(height: 20,),

                // Dropdown fuer Fachauswahl
                amLaden
                  ? CircularProgressIndicator()
                  : alleFaecherDropdown(),

                SizedBox(height: 30,),
                
                TextField(
                  controller: raumNameController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    labelText: 'Raum',
                  ),
                ),
                SizedBox(height: 40,),
                Text('Uhrzeit: ', style: TextStyle(fontSize: 16),),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                      ),
                      child: Text(startzeit.hour.toString().padLeft(2, '0') + ':' + startzeit.minute.toString().padLeft(2, '0'), style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        startZeitAuswaehlen(context);
                      },
                    ),

                    Column(
                      children: [
                        Icon(Icons.arrow_forward, color: Theme.of(context).dividerColor.withAlpha(150),),
                        Text(gibZeitUnterschied() + ' Minuten', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(150)),),
                      ],
                    ),
                    

                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                      ),
                      child: Text(endzeit.hour.toString().padLeft(2, '0') + ':' + endzeit.minute.toString().padLeft(2, '0'), style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        endZeitAuswaehlen(context);
                      },
                    ),
                  ],
                ),
                
                Spacer(flex: 1,),
                Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {
                    schulstundeHinzufuegen();
                    Navigator.pop(context);
                  }, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add),
                      SizedBox(width: 5,),
                      Text('Stunde hinzufügen')
                    ],
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                  ),
                )),
              ],
          ),),
        )
      ),
    );
  }
}

class StundenplanKarte extends StatefulWidget {
  const StundenplanKarte({
    super.key,
    required this.schulstunde,
    required this.fach,
    required this.tag,
  });

  final Schulstunde schulstunde;
  final Fach fach;
  final int tag;

  @override
  State<StundenplanKarte> createState() => _StundenplanKarteState();
}

class _StundenplanKarteState extends State<StundenplanKarte> {

  double berechneZeitFortschritt() {
    DateTime startzeit = widget.schulstunde.startzeit;
    DateTime endzeit = widget.schulstunde.endzeit;
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
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 10,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: ((context) => StundenDetails(wochentag: widget.tag, schulstunde: widget.schulstunde, fach: widget.fach))));
        },
        child: (
          Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            height: 55,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Positioned.fill	(
                  child: TimerBuilder.periodic(
                    Duration(minutes: 1),
                    builder: (context) {
                      return LinearProgressIndicator(
                        value: berechneZeitFortschritt(),
                        valueColor: AlwaysStoppedAnimation(Color(int.parse(widget.fach.farbe))),
                        backgroundColor: Color(int.parse(widget.fach.farbe)).withAlpha(60),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 17),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.fach.name,
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
                              widget.schulstunde.raum,
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
          )
        ),
      ),
    );
  }
}

class StundeBearbeitenSeite extends StatefulWidget {
  const StundeBearbeitenSeite({
    super.key,
    required this.ausgewaehlterTag,
    required this.schulstunde,
    required this.fach,
  });

  final int ausgewaehlterTag;
  final Schulstunde schulstunde;
  final Fach fach;

  @override
  State<StundeBearbeitenSeite> createState() => _StundeBearbeitenSeite();
}

class _StundeBearbeitenSeite extends State<StundeBearbeitenSeite> {
  late List<Fach> alleFaecher;
  bool amLaden = false;
  bool ersteMalLaden = true;
  int ausgewaelterTagIndex = 0;
  Fach fach = Fach(lehrer: '', name: '', farbe: '');
  Schulstunde schulstunde = Schulstunde(fachid: 0, raum: '', startzeit: DateTime(2000, 1, 1, 0, 0), endzeit: DateTime(2000, 1, 1, 0, 0));
  TextEditingController raumNameController = TextEditingController();

  // werter fuer neue stunde  
  Fach ausgewaehltesFach = Fach(lehrer: '', id: 0, name: '', farbe: '');
  TimeOfDay startzeit = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay endzeit = TimeOfDay(hour: 0, minute: 0);
  String raum = '';

  @override
  void initState() {
    schulstunde = widget.schulstunde;
    fach = widget.fach;
    startzeit = TimeOfDay(hour: schulstunde.startzeit.hour, minute: schulstunde.startzeit.minute);
    endzeit = TimeOfDay(hour: schulstunde.endzeit.hour, minute: schulstunde.endzeit.minute);

    raumNameController.text = schulstunde.raum;

    super.initState();

    alleFaecherAuslesen();
  }

  Future<void> schulstundeHinzufuegen() async {
    int ausgewaelterTagIndex = widget.ausgewaehlterTag;

    DateTime konvertierteStartzeit = DateTime(2000, 1, 1, startzeit.hour, startzeit.minute);
    DateTime konvertierteEndzeit = DateTime(2000, 1, 1, endzeit.hour, endzeit.minute);

    Schulstunde tempschulstunde = Schulstunde(
      id: schulstunde.id,
      fachid: ausgewaehltesFach.id!, 
      raum: raumNameController.value.text, 
      startzeit: konvertierteStartzeit, 
      endzeit: konvertierteEndzeit
    );

    await Datenbank.instance.stundeAktualisieren(ausgewaelterTagIndex, tempschulstunde);
  }
  void startZeitAuswaehlen(context) async {
    startzeit = (await showTimePicker(context: context, initialTime: TimeOfDay(hour: schulstunde.startzeit.hour, minute: schulstunde.startzeit.minute)))!;
    setState(() {});
  }

  void endZeitAuswaehlen(context) async {
    endzeit = (await showTimePicker(context: context, initialTime:TimeOfDay(hour: schulstunde.endzeit.hour, minute: schulstunde.endzeit.minute)))!;
    setState(() {});
  }

  Future alleFaecherAuslesen() async {
    setState(() => amLaden = true);
    this.alleFaecher = await Datenbank.instance.alleFaecherAuslesen(); 
    setState(() => amLaden = false);
  }

  DecoratedBox alleFaecherDropdown() {
    for (var i = 0; i < alleFaecher.length; i++) {
      if (alleFaecher[i].id == schulstunde.fachid && ersteMalLaden) {
        ausgewaehltesFach = alleFaecher[i];
      }
    }
    
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(width: 3, color: Color(int.parse(ausgewaehltesFach.farbe))),
        borderRadius: BorderRadius.circular(30),
        color: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.2)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 17, vertical: 11),
        child: DropdownButton(
          style: Theme.of(context).textTheme.labelSmall,
          dropdownColor: farbeVerdunkeln(Color(int.parse(ausgewaehltesFach.farbe)), 0.18),
          isExpanded: true,
          underline: Container(),
          value: ausgewaehltesFach,
          onChanged: (wert) {
            ersteMalLaden = false;
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

  String gibZeitUnterschied() {
    DateTime startzeitDateTime = DateTime(2000, 1, 1, startzeit.hour, startzeit.minute);
    DateTime endzeitDateTime = DateTime(2000, 1, 1, endzeit.hour, endzeit.minute);

    Duration differenz = startzeitDateTime.difference(endzeitDateTime);
    return differenz.inMinutes.abs().toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stunde bearbeiten'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center (
            child: Column(
              children: [
                SizedBox(height: 20,),

                // Dropdown fuer Fachauswahl
                amLaden
                  ? CircularProgressIndicator()
                  : alleFaecherDropdown(),

                SizedBox(height: 30,),
                
                TextField(
                  controller: raumNameController,
                  style: TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                    labelText: 'Raum',
                  ),
                ),
                SizedBox(height: 40,),
                Text('Uhrzeit: ', style: TextStyle(fontSize: 16),),
                SizedBox(height: 5,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                      ),
                      child: Text(startzeit.hour.toString().padLeft(2, '0') + ':' + startzeit.minute.toString().padLeft(2, '0'), style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        startZeitAuswaehlen(context);
                      },
                    ),
                    
                    Column(
                      children: [
                        Icon(Icons.arrow_forward, color: Theme.of(context).dividerColor.withAlpha(150),),
                        Text(gibZeitUnterschied() + ' Minuten', style: TextStyle(color: Theme.of(context).dividerColor.withAlpha(150)),),
                      ],
                    ),

                    OutlinedButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0))),
                      ),
                      child: Text(endzeit.hour.toString().padLeft(2, '0') + ':' + endzeit.minute.toString().padLeft(2, '0'), style: TextStyle(fontSize: 18),),
                      onPressed: () {
                        endZeitAuswaehlen(context);
                      },
                    ),
                  ],
                ),
                
                Spacer(flex: 1,),
                Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {
                    schulstundeHinzufuegen();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 1,)));
                  }, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.update),
                      SizedBox(width: 5,),
                      Text('Stunde aktualisieren')
                    ],
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                  ),
                )),
              ],
          ),),
        )
      ),
    );
  }
}

// stateful widgets
class WochentagAuswahl extends StatefulWidget {
  const WochentagAuswahl({
    super.key,
    required this.tagAktualisert,
  });

  final tagAktualisert;

  @override
  State<WochentagAuswahl> createState() => _WochentagAuswahlState();
}

class _WochentagAuswahlState extends State<WochentagAuswahl> {
  static const wochentage = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag'
  ];

  int ausgewaehlterTag =
      DateTime.now().weekday - 1; // 0: Montag, 1: Dienstag, 2: Mittwoch...

  void tagAddieren() {
    setState(() {
      // calculate new weekday
      if (ausgewaehlterTag != 6) {
        ausgewaehlterTag++;
      } else {
        ausgewaehlterTag = 0;
      }
      widget.tagAktualisert(ausgewaehlterTag);
    });
  }

  void oneDayDown() {
    setState(() {
      // calculate new weekday
      if (ausgewaehlterTag != 0) {
        ausgewaehlterTag--;
      } else {
        ausgewaehlterTag = 6;
      }
      widget.tagAktualisert(ausgewaehlterTag);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(onPressed: oneDayDown, child: Icon(Icons.arrow_back)),
          Opacity(opacity: 0.6, child: Text(wochentage[ausgewaehlterTag], style: TextStyle(fontSize: 18),)),
          OutlinedButton(onPressed: tagAddieren, child: Icon(Icons.arrow_forward)),
        ],
      ),
    );
  }
}