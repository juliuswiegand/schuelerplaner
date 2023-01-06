final String fachTabelle = 'faecher';
final String hausaufgabenTabelle = 'hausaufgaben';
final String montagTabelle = 'montag';
final String dienstagTabelle = 'dienstag';
final String mittwochTabelle = 'mittwoch';
final String donnerstagTabelle = 'donnerstag';
final String freitagTabelle = 'freitag';
final String samstagTabelle = 'samstag';
final String sonntagTabelle = 'sonntag';

class FachFelder {
  static final List<String> werte = [
    id, lehrer, name, farbe
  ];

  static final String id = '_id';
  static final String lehrer = 'lehrer';
  static final String name = 'name';
  static final String farbe = 'farbe';
}

class SchulstundeFelder {
  static final List<String> werte = [
    id, fachid, raum, startzeit, endzeit
  ];

  static final String id = '_id';
  static final String fachid = 'fachid';
  static final String raum = 'raum';
  static final String startzeit = 'startzeit';
  static final String endzeit = 'endzeit';
}

class HausaufgabeFelder {
  static final List<String> werte = [
    id, fachid, erledigt, erstellungsZeitpunkt, abgabeZeitpunkt, aufgabe
  ];

  static final String id = '_id';
  static final String fachid = 'fachid';
  static final String erledigt = 'erledigt';
  static final String erstellungsZeitpunkt = 'erstellungsZeitpunkt';
  static final String abgabeZeitpunkt = 'abgabeZeitpunkt';
  static final String aufgabe = 'aufgabe';
}

class Fach {
  final int? id;
  final String lehrer;
  final String name;
  final String farbe;

  const Fach ({
    this.id,
    required this.lehrer,
    required this.name,
    required this.farbe,
  });

  Map<String, Object?> zuJson() => {
    FachFelder.id: id,
    FachFelder.lehrer: lehrer,
    FachFelder.name: name,
    FachFelder.farbe: farbe,
  };

  static Fach vonJson(Map<String, Object?> json) => Fach(
    id: json[FachFelder.id] as int,
    lehrer: json[FachFelder.lehrer] as String,
    name: json[FachFelder.name] as String,
    farbe: json[FachFelder.farbe] as String,
  );

  Fach kopie({
    int? id,
    String? lehrer,
    String? name,
    String? farbe,
  }) =>
  Fach(
    id: id ?? this.id,
    lehrer: lehrer ?? this.lehrer,
    name: name ?? this.name,
    farbe: farbe ?? this.farbe,
  );
}

class Schulstunde {
  final int? id;
  final int fachid;
  final String raum;
  final DateTime startzeit;
  final DateTime endzeit;

  const Schulstunde ({
    this.id,
    required this.fachid,
    required this.raum,
    required this.startzeit,
    required this.endzeit
  });

  static Schulstunde vonJson(Map<String, Object?> json) => Schulstunde(
    id: json[SchulstundeFelder.id] as int,
    fachid: json[SchulstundeFelder.fachid] as int,
    raum: json[SchulstundeFelder.raum] as String,
    startzeit: DateTime.parse(json[SchulstundeFelder.startzeit] as String),
    endzeit: DateTime.parse(json[SchulstundeFelder.endzeit] as String),
  );

  Map<String, Object?> zuJson() => {
    SchulstundeFelder.id: id,
    SchulstundeFelder.fachid: fachid,
    SchulstundeFelder.raum: raum,
    SchulstundeFelder.startzeit: startzeit.toIso8601String(),
    SchulstundeFelder.endzeit: endzeit.toIso8601String(),
  };

  Schulstunde kopie({
    int? id,
    int? fachid,
    String? raum,
    DateTime? startzeit,
    DateTime? endzeit,
  }) =>
  Schulstunde(
    id: id ?? this.id,
    fachid: fachid ?? this.fachid,
    raum: raum ?? this.raum,
    startzeit: startzeit ?? this.startzeit,
    endzeit: endzeit ?? this.endzeit,
  );
}

class Hausaufgabe {
  final int? id;
  final int fachid;
  final bool erledigt;
  final DateTime erstellungsZeitpunkt;
  final DateTime abgabeZeitpunkt;
  final String aufgabe;

  const Hausaufgabe ({
    this.id,
    required this.fachid,
    required this.erledigt,
    required this.erstellungsZeitpunkt,
    required this.abgabeZeitpunkt,
    required this.aufgabe,
  });

  static Hausaufgabe vonJson(Map<String, Object?> json) => Hausaufgabe(
    id: json[HausaufgabeFelder.id] as int,
    fachid: json[HausaufgabeFelder.fachid] as int,
    aufgabe: json[HausaufgabeFelder.aufgabe] as String,
    erstellungsZeitpunkt: DateTime.parse(json[HausaufgabeFelder.erstellungsZeitpunkt] as String),
    abgabeZeitpunkt: DateTime.parse(json[HausaufgabeFelder.abgabeZeitpunkt] as String),
    erledigt: json[HausaufgabeFelder.erledigt] == 1,
  );

  Map<String, Object?> zuJson() => {
    HausaufgabeFelder.id: id,
    HausaufgabeFelder.fachid: fachid,
    HausaufgabeFelder.aufgabe: aufgabe,
    HausaufgabeFelder.erledigt: erledigt ? 1 : 0,
    HausaufgabeFelder.erstellungsZeitpunkt: erstellungsZeitpunkt.toIso8601String(),
    HausaufgabeFelder.abgabeZeitpunkt: abgabeZeitpunkt.toIso8601String(),
  };

  Hausaufgabe kopie({
    int? id,
    int? fachid,
    String? aufgabe,
    DateTime? erstellungsZeitpunkt,
    DateTime? abgabeZeitpunkt,
    bool? erledigt,
  }) =>
  Hausaufgabe(
    id: id ?? this.id,
    fachid: fachid ?? this.fachid,
    aufgabe: aufgabe ?? this.aufgabe,
    erstellungsZeitpunkt: erstellungsZeitpunkt ?? this.erstellungsZeitpunkt,
    abgabeZeitpunkt: abgabeZeitpunkt ?? this.abgabeZeitpunkt,
    erledigt: erledigt ?? this.erledigt,
  );
}