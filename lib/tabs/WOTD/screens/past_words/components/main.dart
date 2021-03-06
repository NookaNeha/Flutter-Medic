import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wallpaper/tabs/WOTD/key.dart';
import 'package:wallpaper/tabs/WOTD/models/definition.dart';
import 'package:wallpaper/tabs/WOTD/models/word.dart';
import 'dart:convert';


var now = new DateTime.now();
var formatter = new DateFormat('yyyy-MM-dd');
String one = formatter.format(now.add(Duration(days: -1)));
String two = formatter.format(now.add(Duration(days: -2)));
String three = formatter.format(now.add(Duration(days: -3)));
String four = formatter.format(now.add(Duration(days: -4)));
String five = formatter.format(now.add(Duration(days: -5)));
String six = formatter.format(now.add(Duration(days: -6)));
String seven = formatter.format(now.add(Duration(days: -7)));

Future<List<Word>> getAllWords() async {
  List<String> dates = [one, two, three, four, five, six, seven];
  final response = await Future.wait(dates.map((d) => http.get(
      'https://api.wordnik.com/v4/words.json/wordOfTheDay?date=$d&api_key=$apiKey')));

  return response.map((r) {
    if (r.statusCode == 200) {
      return Word.fromJson(json.decode(r.body));
    } else {
      throw Exception('Failed to load word of the day.');
    }
  }).toList();
}

class Main extends StatefulWidget {
  @override
  _MainState createState() => _MainState();
}

class _MainState extends State<Main> {
  Future<List<Word>> futureWord;
  @override
  void initState() {
    super.initState();
    futureWord = getAllWords();
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          FutureBuilder<List<Word>>(
            future: futureWord,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Word> words = List<Word>();
                for (int i = 0; i < 7; i++) {
                  words.add(
                    Word(
                      word: snapshot.data[i].word,
                      definitions: [
                        Definition(
                          text: snapshot.data[i].definitions[0].text,
                          partOfSpeech:
                              snapshot.data[i].definitions[0].partOfSpeech,
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  child: Column(
                    children: words.map((word) => wordTemplate(word)).toList(),
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Could not get words :('),
                );
              }
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          )
        ],
      ),
    );
  }

  Widget wordTemplate(word) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
      child: Card(
        color: Color(0xffffffff),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            5.0,
          ),
        ),
        elevation: 2.0,
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${word.word[0].toUpperCase()}${word.word.substring(1)}',
                        style: GoogleFonts.aldrich(
                          fontSize: 25.0,
                          color:Colors.deepPurple,
                          fontWeight: FontWeight.w700

                        ),
                      ),
                    ],
                  ),

                ],
              ),
              Text(
                word.definitions[0].partOfSpeech,
                style: GoogleFonts.aldrich(
                  fontSize: 16,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                word.definitions[0].text,
                style: GoogleFonts.aldrich(
                  fontSize: 18.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
