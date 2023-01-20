import 'package:flutter/material.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/main.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text/auto_size_text.dart';

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
    setState(() => amLaden = false);
  }

  Future<bool> zureuck() async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 0,)));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: zureuck,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fachübersicht'),
        ),
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
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sentiment_dissatisfied, size: 80, color: Theme.of(context).dividerColor.withAlpha(160),),
                        SizedBox(height: 10,),
                        Text('Noch keine Fächer erstellt', style: TextStyle(fontSize: 17, color: Theme.of(context).dividerColor.withAlpha(180),),)
                      ],
                    ),
                  )
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
          OutlinedButton(
            child: Text(
              'Farbe auswählen',
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Neues Fach erstellen'),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                TextField(
                  controller: fachNameController,
                  decoration: InputDecoration(
                    label: Text('Name'),
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                TextField(
                  controller: fachLehrerController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    label: Text('Lehrer'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    farbAuswahlAnzeigen(context);
                  },
                  child: Container(
                    height: 65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: fachFarbe,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey),
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Icon(Icons.color_lens, color: Colors.white,),
                  ),
                ),
                SizedBox(height: 55,),
                Spacer(flex: 1,),
                Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {fachSpeichern(); 
                  Navigator.pop(context);}, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.save),
                      SizedBox(width: 5,),
                      Text('Speichern')
                    ],
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                  ),
                )),
                //FloatingActionButton(onPressed: () {fachSpeichern(); Navigator.pop(context);}, child: Icon(Icons.save))
          
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
    ueberpruefeAufStundenOhneFach();
    ueberpruefeAufHausaufgabenOhneFach();
    listeAktualisieren();
  }

  Future ueberpruefeAufStundenOhneFach() async {
    List<Fach> alleFaecher = await Datenbank.instance.alleFaecherAuslesen();

    for (int tag = 0; tag < 7; tag++) {
      List<Schulstunde> stundenplan = await Datenbank.instance.alleStundenAuslesen(tag);

      for (var i = 0; i < stundenplan.length; i++) {
        
        int stundeFachId = stundenplan[i].fachid;
        bool gefunden = false;

        alleFaecher.forEach((element) {
          if (element.id == stundeFachId) {
            gefunden = true;
          }
        });

        if (!gefunden) {
          await Datenbank.instance.stundeLoeschen(stundenplan[i].id, tag);
        }
      }
    }
  }

  Future ueberpruefeAufHausaufgabenOhneFach() async {
    List<Fach> alleFaecher = await Datenbank.instance.alleFaecherAuslesen();
    List<Hausaufgabe> alleHausaufgaben = await Datenbank.instance.alleHausaufgabenAuslesen();

    for (var i = 0; i < alleHausaufgaben.length; i++) {
      
      int hausaufgabeFachId = alleHausaufgaben[i].fachid;
      bool gefunden = false;

      alleFaecher.forEach((element) {
        if (element.id == hausaufgabeFachId) {
          gefunden = true;
        }
      });

      if (!gefunden) {
        await Datenbank.instance.hausaufgabeLoeschen(alleHausaufgaben[i].id);
      }
    }
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
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      fach.name,
                      style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      fach.lehrer,
                      style: TextStyle(fontSize: 15, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
              
              IconButton(onPressed: delete, icon: Icon(Icons.delete, size: 30,), color: Color.fromARGB(255, 255, 255, 255),)
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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Fach bearbeiten'),
      ),
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                TextField(
                  controller: fachNameController,
                  decoration: InputDecoration(
                    label: Text('Name'),
                    prefixIcon: Icon(Icons.drive_file_rename_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                TextField(
                  controller: fachLehrerController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    label: Text('Lehrer'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 25,),
                InkWell(
                  onTap: () {
                    FocusManager.instance.primaryFocus?.unfocus();
                    farbAuswahlAnzeigen(context);
                  },
                  child: Container(
                    height: 65,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: fachFarbe,
                      borderRadius: BorderRadius.circular(30),
                      border: Border(
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey),
                        bottom: BorderSide(color: Colors.grey),
                        top: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Icon(Icons.color_lens, color: Colors.white,),
                  ),
                ),
                SizedBox(height: 55,),
                Spacer(flex: 1,),
                Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {fachSpeichern();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FachUebersicht()));
                  }, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.update),
                      SizedBox(width: 5,),
                      Text('Speichern')
                    ],
                  ),
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                  ),
                )),
                //FloatingActionButton(onPressed: () {fachSpeichern(); Navigator.pop(context);}, child: Icon(Icons.save))
          
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
          stops: [0.1, 0.4, 1],
          colors: [
            Color(int.parse(widget.fach.farbe)),
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor,
          ]
        )
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(int.parse(widget.fach.farbe)),
          leading: BackButton(
            color: Colors.white,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.edit),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FachBearbeitenSeite(fach: widget.fach)));
          },
        ),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  widget.fach.name,
                  style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                SizedBox(height: 180,),
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