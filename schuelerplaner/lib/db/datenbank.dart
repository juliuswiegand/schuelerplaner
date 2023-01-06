import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:schuelerplaner/modelle/datenbankmodell.dart';

class Datenbank {
  static final Datenbank instance = Datenbank._init();

  static Database? _datenbank;

  Datenbank._init();

  Future<Database> get datenbank async {
    if (_datenbank != null) {
      return _datenbank!;
    }
    _datenbank = await _initDB('datenbank.db');
    return _datenbank!;
  }

  Future<Database> _initDB(String dateiPfad) async {
    final dbPfad = await getDatabasesPath();
    final pfad = join(dbPfad, dateiPfad);

    return await openDatabase(pfad, version: 1, onCreate: _erstelleDB);
  }

  Future _erstelleDB(Database db, int version) async {
    final idTyp = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    final booleanTyp = 'BOOLEAN NOT NULL';
    final intTyp = 'INTEGER NOT NULL';
    final stringTyp = 'TEXT NOT NULL';

    //fachtabelle erstellen
    await db.execute('''
    CREATE TABLE $fachTabelle (
      ${FachFelder.id} $idTyp,
      ${FachFelder.lehrer} $stringTyp,
      ${FachFelder.name} $stringTyp,
      ${FachFelder.farbe} $stringTyp
    )''');

    // hausaufgabentabelle erstellen
    await db.execute('''
    CREATE TABLE $hausaufgabenTabelle (
      ${HausaufgabeFelder.id} $idTyp,
      ${HausaufgabeFelder.fachid} $intTyp,
      ${HausaufgabeFelder.erledigt} $booleanTyp,
      ${HausaufgabeFelder.erstellungsZeitpunkt} $stringTyp,
      ${HausaufgabeFelder.abgabeZeitpunkt} $stringTyp,
      ${HausaufgabeFelder.aufgabe} $stringTyp
    )''');

    //stundenplaene erstellen
    await db.execute('''
    CREATE TABLE $montagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )''');
    await db.execute('''
    CREATE TABLE $dienstagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
    await db.execute('''
    CREATE TABLE $mittwochTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
    await db.execute('''
    CREATE TABLE $donnerstagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
    await db.execute('''
    CREATE TABLE $freitagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
    await db.execute('''
    CREATE TABLE $samstagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
    await db.execute('''
    CREATE TABLE $sonntagTabelle (
      ${SchulstundeFelder.id} $idTyp,
      ${SchulstundeFelder.fachid} $intTyp,
      ${SchulstundeFelder.raum} $stringTyp,
      ${SchulstundeFelder.startzeit} $stringTyp,
      ${SchulstundeFelder.endzeit} $stringTyp
    )
    ''');
  }

  Future<Fach> fachErstellen(Fach fach) async {
    final db = await instance.datenbank;

    final id = await db.insert(fachTabelle, fach.zuJson());
    return fach.kopie(id: id);
  }

  Future<Hausaufgabe> hausaufgabeErstellen(Hausaufgabe hausaufgabe) async {
    final db = await instance.datenbank;

    final id = await db.insert(hausaufgabenTabelle, hausaufgabe.zuJson());
    return hausaufgabe.kopie(id: id);
  }

  Future<Schulstunde> stundeHinzufuegen(int tagIndex, Schulstunde stunde) async {
    final db = await instance.datenbank;

    if (tagIndex == 0) {
      final id = await db.insert(montagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 1) {
      final id = await db.insert(dienstagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 2) {
      final id = await db.insert(mittwochTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 3) {
      final id = await db.insert(donnerstagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 4) {
      final id = await db.insert(freitagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 5) {
      final id = await db.insert(samstagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }
    if (tagIndex == 6) {
      final id = await db.insert(sonntagTabelle, stunde.zuJson());
      return stunde.kopie(id: id);
    }

    throw Exception('Studen außerhalb des Tagindexes wurden versucht hinzuzufuegen');
  }

  Future<int> fachAktualisieren(Fach fach) async {
    final db = await instance.datenbank;

    return db.update(
      fachTabelle,
      fach.zuJson(),
      where: '${FachFelder.id} = ?',
      whereArgs: [fach.id],
    );
  }

  Future<int> hausaufgabeAktualisieren(Hausaufgabe hausaufgabe) async {
    final db = await instance.datenbank;

    return db.update(
      hausaufgabenTabelle,
      hausaufgabe.zuJson(),
      where: '${HausaufgabeFelder.id} = ?',
      whereArgs: [hausaufgabe.id],
    );
  }

  Future<int> stundeAktualisieren(int tagIndex, Schulstunde stunde) async {
    final db = await instance.datenbank;

    if (tagIndex == 0) {
      return db.update(
        montagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 1) {
      return db.update(
        dienstagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 2) {
      return db.update(
        mittwochTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 3) {
      return db.update(
        donnerstagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 4) {
      return db.update(
        freitagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 5) {
      return db.update(
        samstagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }
    if (tagIndex == 6) {
      return db.update(
        sonntagTabelle,
        stunde.zuJson(),
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [stunde.id],
      );
    }

    throw Exception('Studen außerhalb des Tagindexes wurden versucht hinzuzufuegen');
  }

  Future<int> stundeLoeschen(int? id, int tagIndex) async {
    final db = await instance.datenbank;

    if (tagIndex == 0) {
      return await db.delete(
        montagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 1) {
      return await db.delete(
        dienstagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 2) {
      return await db.delete(
        mittwochTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 3) {
      return await db.delete(
        donnerstagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 4) {
      return await db.delete(
        freitagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 5) {
      return await db.delete(
        samstagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }
    if (tagIndex == 6) {
      return await db.delete(
        sonntagTabelle,
        where: '${SchulstundeFelder.id} = ?',
        whereArgs: [id],
      );
    }

    throw Exception('Studen außerhalb des Tagindexes wurden versucht zu loeschen');
  }
  

  Future<int> fachLoeschen(int? id) async {
    final db = await instance.datenbank;

    return await db.delete(
      fachTabelle,
      where: '${FachFelder.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> hausaufgabeLoeschen(int? id) async {
    final db = await instance.datenbank;

    return await db.delete(
      hausaufgabenTabelle,
      where: '${HausaufgabeFelder.id} = ?',
      whereArgs: [id],
    );
  }

  Future<Fach?> fachAuslesen(int id) async {
    final db = await instance.datenbank;

    final maps = await db.query(
      fachTabelle,
      columns: FachFelder.werte,
      where: '${FachFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Fach.vonJson(maps.first);
    } else {
      return null;
    }
  }

  Future<Hausaufgabe?> hausaufgabeAuslesen(int id) async {
    final db = await instance.datenbank;

    final maps = await db.query(
      hausaufgabenTabelle,
      columns: HausaufgabeFelder.werte,
      where: '${HausaufgabeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Hausaufgabe.vonJson(maps.first);
    } else {
      return null;
    }
  }

  Future<List<Fach>> alleFaecherAuslesen() async {
    final db = await instance.datenbank;
    final ergebniss = await db.query(fachTabelle);
    return ergebniss.map((json) => Fach.vonJson(json)).toList();
  }

  Future<List<Hausaufgabe>> alleNichtErledigtenHausaufgabenAuslesen() async {
    final db = await instance.datenbank;
    final ergebniss = await db.query(
      hausaufgabenTabelle, 
      where: '${HausaufgabeFelder.erledigt} = ?',
      whereArgs: [0],
    );
    return ergebniss.map((json) => Hausaufgabe.vonJson(json)).toList();
  }

  Future<List<Hausaufgabe>> alleErledigtenHausaufgabenAuslesen() async {
    final db = await instance.datenbank;
    final ergebniss = await db.query(
      hausaufgabenTabelle, 
      where: '${HausaufgabeFelder.erledigt} = ?',
      whereArgs: [1],
    );
    return ergebniss.map((json) => Hausaufgabe.vonJson(json)).toList();
  }

  Future<List<Schulstunde>> alleStundenAuslesen(int tagIndex) async {
    final db = await instance.datenbank;

    // sortiert die schulstunden nach aufsteigend nach der startzeit
    final sortierenNach = '${SchulstundeFelder.startzeit} ASC';

    if (tagIndex == 0) {
      final ergebniss = await db.query(montagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 1) {
      final ergebniss = await db.query(dienstagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 2) {
      final ergebniss = await db.query(mittwochTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 3) {
      final ergebniss = await db.query(donnerstagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 4) {
      final ergebniss = await db.query(freitagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 5) {
      final ergebniss = await db.query(samstagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }
    if (tagIndex == 6) {
      final ergebniss = await db.query(sonntagTabelle, orderBy: sortierenNach);
      return ergebniss.map((json) => Schulstunde.vonJson(json)).toList();
    }

    throw Exception('Studen außerhalb des Tagindexes wurden ausgelsen');
  }

  Future<Schulstunde> schulstundeAuslesen(int tagIndex, int id) async {
    final db = await instance.datenbank;

    if (tagIndex == 0) {
      final maps = await db.query(
      montagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 1) {
      final maps = await db.query(
      dienstagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 2) {
      final maps = await db.query(
      mittwochTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 3) {
      final maps = await db.query(
      donnerstagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 4) {
      final maps = await db.query(
      freitagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 5) {
      final maps = await db.query(
      samstagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    if (tagIndex == 6) {
      final maps = await db.query(
      sonntagTabelle,
      columns: SchulstundeFelder.werte,
      where: '${SchulstundeFelder.id} = ?', // fragezeichen statt $id um sql injection zu vermeiden
      whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Schulstunde.vonJson(maps.first);
      }
    }
    throw Exception('Konnte das Fach mit der id $id nicht finden');
  }

  Future schliessen() async {
    print('datenbank wird geschlossen');
    final db = await instance.datenbank;
    db.close();
  }

  Future loeschen() async {
    print('Datenbank wird gelöscht');
    
    final db = await instance.datenbank;
    db.delete(fachTabelle);
    db.delete(montagTabelle);
    db.delete(dienstagTabelle);
    db.delete(mittwochTabelle);
    db.delete(donnerstagTabelle);
    db.delete(freitagTabelle);
    db.delete(samstagTabelle);
    db.delete(sonntagTabelle);
  }
}