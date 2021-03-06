import 'dart:convert';

import 'package:flutter/material.dart';
import 'countdown.dart';
import 'datum.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'util.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countdown App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.blueGrey,
      ),
      home: const Home(),
      routes: {
        Countdown.routeName: (context) => const Countdown(),
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Countdown App'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              SizedBox(height: 20),
              Text('Apa yang ingin anda lakukan ?'),
              Expanded(
                child: InputandList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InputandList extends StatefulWidget {
  const InputandList({Key? key}) : super(key: key);

  @override
  State<InputandList> createState() => _InputandListState();
}

class _InputandListState extends State<InputandList> {
  final _inputController = TextEditingController();
  List<CountdownDatum> _countdownData = <CountdownDatum>[];
  SharedPreferences? _prefs;

  Future<List<CountdownDatum>> loadData() async {
    List<CountdownDatum> countdownDataa = <CountdownDatum>[];
    _prefs = await SharedPreferences.getInstance();
    if (_prefs!.getString('data') != null) {
      Iterable l = json.decode(_prefs!.getString('data')!);
      countdownDataa = List<CountdownDatum>.from(
          l.map((model) => CountdownDatum.fromJson(model)));
    }
    return countdownDataa;
  }

  @override
  void initState() {
    loadData().then((result) {
      setState(() {
        _countdownData = result;
      });
    });
    super.initState();
  }

  void _tambahData(BuildContext context) async {
    if (_inputController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktivitas tidak boleh kosong !'),
        ),
      );
      return;
    }

    CountdownDatum datum = CountdownDatum(_inputController.text);
    _inputController.text = '';

    final result = await Navigator.of(context).pushNamed(
      Countdown.routeName,
      arguments: CountdownArguments(datum),
    ) as CountdownPopResult;

    datum.done = result.done;
    datum.spendDuration = result.milidetikSaatIni.floor();
    datum.targetDuration = result.milidetikTarget.floor();

    setState(() {
      _countdownData.add(datum);
      _prefs!.setString('data', jsonEncode(_countdownData));
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _clearHistory() {
    setState(() {
      _countdownData = <CountdownDatum>[];
      _prefs!.setString('data', jsonEncode(_countdownData));
    });
  }

  Widget listViewGenerator() {
    _countdownData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
        itemCount: _countdownData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_countdownData[index].title),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "${(_countdownData[index].spendDuration / _countdownData[index].targetDuration).floor() == 1 ? "" : "${((_countdownData[index].spendDuration / _countdownData[index].targetDuration) * 100).floor()}% - "}${printDuration(Duration(seconds: (_countdownData[index].spendDuration / 1000).floor()))}"),
                Text(toIndonesianDateTime(_countdownData[index].createdAt)),
              ],
            ),
            leading: _countdownData[index].done
                ? const Icon(Icons.check)
                : const Icon(Icons.dangerous),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Ketikkan Aktivitas Anda",
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              ElevatedButton(
                onPressed: () => _tambahData(context),
                child: const Text("+"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _countdownData.isEmpty
            ? const Text('Tidak ada aktivitas baru baru ini')
            : const Text('Past Activities :'),
        const SizedBox(height: 10),
        _countdownData.isNotEmpty
            ? ElevatedButton(
                onPressed: _clearHistory,
                child: const Text('CLEAR HISTORY'),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        _countdownData.isNotEmpty
            ? Expanded(
                child: listViewGenerator(),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
