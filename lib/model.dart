import './strings.dart';

class Song {
  final String id;
  final String title;
  final String? subtitle;
  final String number;
  final String slug;
  final bool isOrdinary;

  Song(this.id, this.title, this.subtitle, this.number, this.slug,
      [this.isOrdinary = false]);

  Song.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        subtitle = json['subtitle'],
        number = json['number'],
        slug = json['slug'],
        isOrdinary = json['isOrdinary'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'number': number,
        'slug': slug,
        'isOrdinary': isOrdinary,
      };
}

abstract class OrdinaryItems {
  static Song kyrie = Song(
      'a583dc8a31c94d2f9f5272ec7fa46710', 'Kyrie eleison', null, '', '', true);
  static Song sanctus =
      Song('a48d891417ee457aaa32218834128eab', 'Sanctus', null, '', '', true);
  static Song agnus =
      Song('46d9557071eb45e5bd325c981d46bb09', 'Agnus Dei', null, '', '', true);
}

abstract class DeckItem {
  String get id;
  String get title;
  String? get subtitle;
  String get number;

  String get removedMessage;

  Map<String, dynamic> toJson();
  Map<String, dynamic> toFullJson();
}

class SongDeckItem implements DeckItem {
  SongDeckItem(this.song);

  Song song;
  @override
  String get id => song.id;
  @override
  String get title => song.title;
  @override
  String? get subtitle => song.subtitle;
  @override
  String get number => song.number;
  bool get isOrdinary => song.isOrdinary;

  List<String>? rawVerses;
  List<bool>? selectedVerses;

  List<int>? get order {
    if (selectedVerses == null) {
      return null;
    }

    List<int> order = [];

    for (int i = 0; i < selectedVerses!.length; i++) {
      if (selectedVerses![i]) {
        order.add(i);
      }
    }

    return order;
  }

  @override
  String get removedMessage =>
      strings['itemRemovedSong']!.replaceFirst("{}", song.title);

  @override
  Map<String, dynamic> toJson() => {'id': id, 'order': order};
  @override
  Map<String, dynamic> toFullJson() => {'type': 'SONG'}..addAll(song.toJson());
}

abstract class LiturgyHolder {
  Liturgy? liturgy;
}

abstract class LiturgyDeckItem implements DeckItem {
  LiturgyDeckItem(this.state);

  LiturgyHolder state;
  Liturgy? get liturgy => state.liturgy;
}

class PsalmDeckItem extends LiturgyDeckItem {
  PsalmDeckItem(state) : super(state);

  @override
  String get id => 'PSALM';
  @override
  String get title => strings['psalm']!;
  @override
  String? get subtitle => liturgy?.psalm;
  @override
  String get number => '';

  @override
  String get removedMessage => strings['itemRemovedPsalm']!;

  @override
  Map<String, dynamic> toJson() => {'type': 'PSALM'};
  @override
  Map<String, dynamic> toFullJson() => toJson();
}

class AcclamationDeckItem extends LiturgyDeckItem {
  AcclamationDeckItem(state) : super(state);

  @override
  String get id => 'ACCLAMATION';
  @override
  String get title =>
      liturgy?.acclamation.replaceFirst(", alleluja, alleluja", "") ??
      strings['acclamation']!;
  @override
  String? get subtitle => liturgy?.acclamationVerse.replaceAll("\n", " ");
  @override
  String get number => '';

  @override
  String get removedMessage => strings['itemRemovedAcclamation']!;

  @override
  Map<String, dynamic> toJson() => {'type': 'ACCLAMATION'};
  @override
  Map<String, dynamic> toFullJson() => toJson();
}

class UnresolvedDeckItem implements DeckItem {
  UnresolvedDeckItem(this.title);

  @override
  String title;
  @override
  String get subtitle => '';
  @override
  String get id => title.hashCode.toString();
  @override
  final String number = '?';
  final bool isOrdinary = false;

  @override
  String get removedMessage =>
      strings['itemRemovedSong']!.replaceFirst("{}", title);

  @override
  Map<String, dynamic> toJson() => {};
  @override
  Map<String, dynamic> toFullJson() => {'type': 'UNRESOLVED', 'title': title};
}

class TextDeckItem implements DeckItem {
  TextDeckItem(this.contents);

  String contents;

  @override
  String get id => contents.hashCode.toString();
  @override
  String get title => getTitle();
  @override
  String get subtitle => '';
  @override
  String get number => '';

  @override
  String get removedMessage =>
      strings['itemRemovedSong']!.replaceFirst("{}", title);

  @override
  Map<String, dynamic> toJson() => {'contents': contents.split("\n\n")};
  @override
  Map<String, dynamic> toFullJson() => {'type': 'TEXT', 'contents': contents};

  String getTitle() {
    final lines = contents.split("\n");
    final firstLine = lines[0];
    final firstLineLength = firstLine.length;
    final slice = firstLineLength > 30 ? firstLine.substring(0, 30) : firstLine;
    final isTruncated = contents.length > 30 || firstLineLength > 30;

    return isTruncated ? "$slice..." : slice;
  }
}

class DeckRequest {
  final DateTime date;
  final List<DeckItem> items;
  final bool? hints;
  final String? ratio;
  final int? fontSize;
  final String? format;

  DeckRequest({
    required this.date,
    required this.items,
    this.hints,
    this.ratio,
    this.fontSize,
    this.format,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String().substring(0, 10),
        'items': items.map((item) => item.toJson()).toList(),
        'hints': hints,
        'ratio': ratio,
        'fontSize': fontSize,
        'format': format,
      };
}

class DeckResponse {
  final String url;

  DeckResponse(this.url);

  DeckResponse.fromJson(Map<String, dynamic> json) : url = json['url'];
}

class Manual {
  final List<String> steps;
  final String image;

  Manual(this.steps, this.image);

  Manual.fromJson(Map<String, dynamic> json)
      : steps = List<String>.from(json['steps']),
        image = json['image'];
}

class BootstrapResponse {
  final String currentVersion;
  final String appDownloadUrl;

  BootstrapResponse(this.currentVersion, this.appDownloadUrl);

  BootstrapResponse.fromJson(Map<String, dynamic> json)
      : currentVersion = json['currentVersion'],
        appDownloadUrl = json['appDownloadUrl'];
}

class Liturgy {
  final String psalm;
  final String acclamation;
  final String acclamationVerse;

  Liturgy(this.psalm, this.acclamation, this.acclamationVerse);

  Liturgy.fromJson(Map<String, dynamic> json)
      : psalm = json['psalm'],
        acclamation = json['acclamation'],
        acclamationVerse = json['acclamationVerse'];
}

class LiveResponse {
  final String url;

  LiveResponse(this.url);

  LiveResponse.fromJson(Map<String, dynamic> json) : url = json['url'];
}
