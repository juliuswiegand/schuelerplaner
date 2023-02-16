import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/main.dart';
import 'package:schuelerplaner/farbManipulation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

void speicherStandardLaenge(laenge) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt('stundenLaenge', laenge);
}

void speicherName(name) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('benutzername', name);
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  List<bool> farbThemenAuswahl = <bool>[true, false];
  TextEditingController stundenLaengeController = TextEditingController();
  TextEditingController benutzernameController = TextEditingController();
  int stundenLaenge = 45;
  String benutzername = 'Benutzer';

  @override
  void initState() {
    textfelderVorausfuellen();
    super.initState();
  }

  Future<void> datenbankLeeren() async {
    Datenbank datenbank = await Datenbank.instance;
    datenbank.loeschen();
  }

  void debugErstesMal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('erstesMal', true);
  }

  void textfelderVorausfuellen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    stundenLaenge = prefs.getInt('stundenLaenge') ?? 45;
    stundenLaengeController.text = stundenLaenge.toString();

    benutzername = prefs.getString('benutzername') ?? 'Benutzer';
    benutzernameController.text = benutzername;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Standard Stundenlänge (in Minuten)', style: TextStyle(fontSize: 17),),
              SizedBox(height: 10,),
              TextField(
                controller: stundenLaengeController,
                onChanged: (value) {           
                  speicherStandardLaenge(int.parse(value));
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 30,),
              Text('Dein Name:', style: TextStyle(fontSize: 17),),
              SizedBox(height: 10,),
              TextField(
                controller: benutzernameController,
                onChanged: (value) {
                  speicherName(value);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 40,),
              Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {
                    datenbankLeeren();
                  }, 
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_forever, color: Colors.white,),
                      SizedBox(width: 5,),
                      Text('Appdaten löschen', style: TextStyle(color: Colors.white,),)
                    ],
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 180, 0, 0)),
                    elevation: MaterialStateProperty.all(10),
                  ),
                )),

                //Container(width: double.infinity, height: 65, child: ElevatedButton(
                //  onPressed: () {
                //    debugErstesMal();
                //  }, 
                //  child: Row(
                //    mainAxisAlignment: MainAxisAlignment.center,
                //    children: [
                //      Icon(Icons.delete_forever, color: Colors.white,),
                //      SizedBox(width: 5,),
                //      Text('debug erstes mal', style: TextStyle(color: Colors.white,),)
                //    ],
                //  ),
                //  style: ButtonStyle(
                //    backgroundColor: MaterialStatePropertyAll(Color.fromARGB(255, 180, 0, 0)),
                //    elevation: MaterialStateProperty.all(10),
                //  ),
                //)),
            ]
              ),
          ),
        )
      );
  }
}