import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LanguagesPage extends StatelessWidget {
  late List languages;

  LanguagesPage({Key? key}) : super(key: key) {
    _loadLanguages();
  }

  void _loadLanguages() async {
    final source =
        await rootBundle.loadString('assets/fixtures/languages.json');
    languages = json.decode(source)['results'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView.builder(
      key: const Key('item_list'),
      itemCount: languages.length,
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemBuilder: _listBuilder,
    ));
  }

  Widget _listBuilder(BuildContext context, int index) {
    final item = languages[index];
    return SafeArea(
      top: false,
      bottom: false,
      child: Card(
        elevation: 1.5,
        margin: const EdgeInsets.fromLTRB(6, 12, 6, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        color: Colors.white,
        child: InkWell(
            key: Key('item_$index'),
            onTap: () {
              Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          LanguagePage(index: index, language: item)));
            },
            child: LanguagePreview(index: index, language: item)),
      ),
    );
  }
}

class LanguagePreview extends StatelessWidget {
  final int index;
  final Map language;

  const LanguagePreview({Key? key, required this.index, required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = language['name'];
    final year = language['year'];
    final logo = language['logo'];
    final hello = language['hello'];
    final subtext = language['person'];
    final category = language['category'];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage('assets/images/$logo')),
              const Padding(padding: EdgeInsets.only(left: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        key: Key('item_${index}_name'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$year',
                        key: Key('item_${index}_year'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  Text(
                    subtext,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  Text(
                    category,
                    style: const TextStyle(
                        fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              )
            ],
          ),
          const Padding(padding: EdgeInsets.only(top: 16)),
          Image.asset('assets/images/$hello')
        ],
      ),
    );
  }
}

class LanguageDetail extends StatelessWidget {
  final int index;
  final Map language;

  const LanguageDetail({Key? key, required this.index, required this.language})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arguments = language['arguments'];
    final description = language['description'];

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/images/$arguments'),
          const Padding(padding: EdgeInsets.only(top: 16)),
          Text(
            description,
            style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
          ),
          const Padding(padding: EdgeInsets.only(top: 8)),
        ],
      ),
    );
  }
}

class LanguagePage extends StatefulWidget {
  final int index;
  final Map language;

  const LanguagePage({Key? key, required this.index, required this.language})
      : super(key: key);
  @override
  _LanguagePageState createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            children: [
              LanguagePreview(index: widget.index, language: widget.language),
              LanguageDetail(index: widget.index, language: widget.language),
            ],
          ),
      ),
    );
  }
}
