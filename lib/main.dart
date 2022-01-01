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
      body: Center(
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
    );
  }
}

class InputandList extends StatefulWidget {
  const InputandList({Key? key}) : super(key: key);

  @override
  State<InputandList> createState() => _InputandListState();
}

class _InputandListState extends State<InputandList> {
  final inputController = TextEditingController();
  List<CountdownDatum> countdownData = <CountdownDatum>[];
  SharedPreferences? prefs;

  Future<List<CountdownDatum>> loadData() async {
    List<CountdownDatum> countdownDataa = <CountdownDatum>[];
    prefs = await SharedPreferences.getInstance();
    if (prefs!.getString('data') != null) {
      Iterable l = json.decode(prefs!.getString('data')!);
      countdownDataa = List<CountdownDatum>.from(
          l.map((model) => CountdownDatum.fromJson(model)));
    }
    return countdownDataa;
  }

  @override
  void initState() {
    loadData().then((result) {
      setState(() {
        countdownData = result;
      });
    });
    super.initState();
  }

  void tambahData(BuildContext context) async {
    if (inputController.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aktivitas tidak boleh kosong !'),
        ),
      );
      return;
    }

    CountdownDatum datum = CountdownDatum(inputController.text);

    final result = await Navigator.of(context).pushNamed(
      Countdown.routeName,
      arguments: CountdownArguments(datum),
    ) as CountdownPopResult;

    datum.done = result.done;
    datum.duration = (result.milidetikTarget).floor();

    setState(() {
      countdownData.add(datum);
      prefs!.setString('data', jsonEncode(countdownData));
    });

    inputController.text = '';
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  void clearHistory() {
    setState(() {
      countdownData = <CountdownDatum>[];
      prefs!.setString('data', jsonEncode(countdownData));
    });
  }

  Widget listViewGenerator() {
    countdownData.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return ListView.builder(
        itemCount: countdownData.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(countdownData[index].title),
            subtitle: Text(
                "${printDuration(Duration(seconds: (countdownData[index].duration / 1000).floor()))} ( ${countdownData[index].createdAt.toString()} )"),
            leading: countdownData[index].done
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
                  controller: inputController,
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
                onPressed: () => tambahData(context),
                child: const Text("+"),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        countdownData.isEmpty
            ? const Text('Tidak ada aktivitas baru baru ini')
            : const Text('Past Activities :'),
        const SizedBox(height: 10),
        countdownData.isNotEmpty
            ? ElevatedButton(
                onPressed: clearHistory,
                child: const Text('CLEAR HISTORY'),
              )
            : const SizedBox.shrink(),
        const SizedBox(height: 10),
        countdownData.isNotEmpty
            ? Expanded(
                child: listViewGenerator(),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
