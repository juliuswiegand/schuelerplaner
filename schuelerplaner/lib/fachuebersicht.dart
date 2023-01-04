import 'package:flutter/material.dart';
import 'package:schuelerplaner/modelle/stundenplanmodell.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/main.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class FachUebersicht extends StatefulWidget {
  const FachUebersicht({super.key});

  @override
  State<FachUebersicht> createState() => _FachUebersichtState();
}

class _FachUebersichtState extends State<FachUebersicht> {
  late List<Fach> faecher;
  bool amLaden = false;

  @override
  void initState() {
    super.initState();

    faecherAktualisieren();
  }

  //@override
  //void dispose() {
  //  Datenbank.instance.schliessen();
  //  super.dispose();
  //}

  Future faecherAktualisieren() async {
    setState(() => amLaden = true);
    this.faecher = await Datenbank.instance.alleFaecherAuslesen();
    print(faecher);
    setState(() => amLaden = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NeuesFachSeite())).then((value) => faecherAktualisieren());
        }, 
        child: Icon(Icons.add),
      ),
      body: Container(
        alignment: Alignment.topLeft,
        child: SafeArea(
            child: ( 
              amLaden
              ? CircularProgressIndicator()
              : faecher.isEmpty
                ? Text('Keine Fächer')
                : ListView.builder(
                  padding: const EdgeInsets.all(25),
                  itemCount: faecher.length,
                  itemBuilder: (context, index) {
                    final fach = faecher[index];
                    return FachKarte(fach: fach, listeAktualisieren: faecherAktualisieren);
                  },
                )

                
            ),
        )
      ),
    );
  }
}

class NeuesFachSeite extends StatefulWidget {
  const NeuesFachSeite({super.key});

  @override
  State<NeuesFachSeite> createState() => _NeuesFachSeiteState();
}

class _NeuesFachSeiteState extends State<NeuesFachSeite> {
  Color fachFarbe = Color(4286279837);
  String fachFarbeString = '4286279837'; // mit int.parse(STRING) in farbe umwandelbar

  TextEditingController fachNameController = TextEditingController();
  TextEditingController fachLehrerController = TextEditingController();

  Widget FarbauswahlWidgetBauen() => ColorPicker(
    paletteType: PaletteType.hueWheel,
    enableAlpha: false,
    pickerColor: fachFarbe, 
    onColorChanged: (color) => setState(() => this.fachFarbe = color),
  );

  void farbAuswahlAnzeigen(BuildContext context) => showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Center(child: Text('Farbe auswählen')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FarbauswahlWidgetBauen(),

          TextButton(
            child: Text(
              'Auswählen',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              fachFarbeString = fachFarbe.value.toString();
              print(fachFarbeString);
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    )
  );

  Future<void> fachSpeichern() async {
    String fachName = fachNameController.value.text;
    String fachLehrer = fachLehrerController.value.text;
    String fachFarbe = fachFarbeString;

    Fach fach = Fach(
      lehrer: fachLehrer, 
      name: fachName, 
      farbe: fachFarbe
    );

    await Datenbank.instance.fachErstellen(fach);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Neues Fach erstellen'),
              TextField(
                controller: fachNameController,
                decoration: InputDecoration(
                  label: Text('Name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              TextField(
                controller: fachLehrerController,
                decoration: InputDecoration(
                  label: Text('Lehrer'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Container(
                
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: fachFarbe,
                  borderRadius: BorderRadius.circular(100),
                  border: Border(
                    left: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    bottom: BorderSide(color: Colors.white),
                    top: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {farbAuswahlAnzeigen(context);},
                child: Icon(Icons.color_lens)
              ),
              FloatingActionButton(onPressed: () {fachSpeichern(); Navigator.pop(context);}, child: Icon(Icons.save))

            ],
          ),
        ),
      ),
    );
  }
}

class FachKarte extends StatelessWidget {
  const FachKarte({
    super.key,
    required this.fach,
    required this.listeAktualisieren,
  });

  Future delete() async {
    print('Lösche Eintrag');
    await Datenbank.instance.fachLoeschen(fach.id);
    listeAktualisieren();
  }

  final Fach fach;
  final listeAktualisieren;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FachDetails(fach: fach)));
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fach.name,
                style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                fach.lehrer,
                style: TextStyle(fontSize: 15, color: Color.fromARGB(255, 212, 212, 212)),
              ),
              Text(fach.id.toString()),
              IconButton(onPressed: delete, icon: Icon(Icons.delete), color: Color.fromARGB(255, 255, 193, 193),)
            ]
          )
        ),
        color: Color(int.parse(fach.farbe)),
        
      ),
    );
  }
}

class FachBearbeitenSeite extends StatefulWidget {
  const FachBearbeitenSeite({super.key, required this.fach});

  final Fach fach;

  @override
  State<FachBearbeitenSeite> createState() => _FachBearbeitenSeite();
}

class _FachBearbeitenSeite extends State<FachBearbeitenSeite> {

  Color fachFarbe = Color(0xAAAAAAAA);
  String fachFarbeString = '';
  int id = 0;

  TextEditingController fachNameController = TextEditingController();
  TextEditingController fachLehrerController = TextEditingController();

  @override
  void initState() {
    fachFarbe = Color(int.parse(widget.fach.farbe));
    fachFarbeString = widget.fach.farbe;

    id = widget.fach.id!;

    fachNameController.text = widget.fach.name;
    fachLehrerController.text = widget.fach.lehrer;
    super.initState();
  }

  Widget FarbauswahlWidgetBauen() => ColorPicker(
    paletteType: PaletteType.hueWheel,
    enableAlpha: false,
    pickerColor: fachFarbe, 
    onColorChanged: (color) => setState(() => this.fachFarbe = color),
  );

  void farbAuswahlAnzeigen(BuildContext context) => showDialog(
    context: context, 
    builder: (context) => AlertDialog(
      title: Center(child: Text('Farbe auswählen')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FarbauswahlWidgetBauen(),

          TextButton(
            child: Text(
              'Auswählen',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () {
              fachFarbeString = fachFarbe.value.toString();
              print(fachFarbeString);
              Navigator.of(context).pop();
            },
          ),
        ],
      )
    )
  );

  Future<void> fachSpeichern() async {
    int fachId = id;
    String fachName = fachNameController.value.text;
    String fachLehrer = fachLehrerController.value.text;
    String fachFarbe = fachFarbeString;

    Fach fach = Fach(
      id: fachId,
      lehrer: fachLehrer, 
      name: fachName, 
      farbe: fachFarbe
    );

    await Datenbank.instance.fachAktualisieren(fach);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Text('Neues Fach erstellen'),
              TextField(
                controller: fachNameController,
                decoration: InputDecoration(
                  label: Text('Name'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              TextField(
                controller: fachLehrerController,
                decoration: InputDecoration(
                  label: Text('Lehrer'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Container(
                
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: fachFarbe,
                  borderRadius: BorderRadius.circular(100),
                  border: Border(
                    left: BorderSide(color: Colors.white),
                    right: BorderSide(color: Colors.white),
                    bottom: BorderSide(color: Colors.white),
                    top: BorderSide(color: Colors.white),
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () {farbAuswahlAnzeigen(context);},
                child: Icon(Icons.color_lens)
              ),
              FloatingActionButton(onPressed: () {fachSpeichern(); Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));}, child: Icon(Icons.save))
            ],
          ),
        ),
      ),
    );
  }
}

class FachDetails extends StatefulWidget {
  const FachDetails({
    super.key,
    required this.fach,
  });

  final Fach fach;

  @override
  State<FachDetails> createState() => _FachDetailsState();
}

class _FachDetailsState extends State<FachDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0, 0.3, 1],
          colors: [
            Color(int.parse(widget.fach.farbe)),
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor,
          ]
        )
      ),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FachBearbeitenSeite(fach: widget.fach)));
          },
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.fach.name,
                  style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 150,),
                Text('Lehrer:', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                Text(widget.fach.lehrer, style: TextStyle(fontSize: 20),),
                SizedBox(height: 20,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}