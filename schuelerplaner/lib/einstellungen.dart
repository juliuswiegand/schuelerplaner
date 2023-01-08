import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';
import 'package:schuelerplaner/db/datenbank.dart';
import 'package:schuelerplaner/main.dart';
import 'package:schuelerplaner/farbManipulation.dart';
import 'package:flutter/services.dart';

class EinstellungenSeite extends StatefulWidget {
  const EinstellungenSeite({super.key});

  @override
  State<EinstellungenSeite> createState() => _EinstellungenSeiteState();
}

class _EinstellungenSeiteState extends State<EinstellungenSeite> {
  List<bool> farbThemenAuswahl = <bool>[true, false, false, false];

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
              Text('OLED Dark Mode', style: TextStyle(fontSize: 17),),
              SizedBox(height: 10,),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ToggleButtons(
                    borderRadius: BorderRadius.circular(30),
                    constraints:
                      BoxConstraints.expand(width: constraints.maxWidth / 4.06),
                    children: [
                      Text('Hell'),
                      Text('Dunkel'),
                      Text('System'),
                      Text('OLED'),
                    ], 
                    isSelected: farbThemenAuswahl,
                    onPressed: (int index) {
                      setState(() {
                        for (var i = 0; i < farbThemenAuswahl.length; i++) {
                          farbThemenAuswahl[i] = i == index;
                        }
                      });
                  });
                },         
              ),
              SizedBox(height: 40,),
              Text('Standard Stundenlänge (in Minuten)', style: TextStyle(fontSize: 17),),
              SizedBox(height: 10,),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 40,),
              Container(width: double.infinity, height: 65, child: ElevatedButton(
                  onPressed: () {null; 
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Homescreen(seiteWeiterleiten: 2,)));
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
            ]
              ),
          ),
        )
      );
  }
}