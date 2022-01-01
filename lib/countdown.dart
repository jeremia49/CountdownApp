import 'package:flutter/material.dart';
import 'dart:async';
import 'datum.dart';
import 'util.dart';

class CountdownPopResult {
  final int milidetikTarget;
  final int milidetikSaatIni;
  final bool done;
  CountdownPopResult(this.milidetikSaatIni, this.milidetikTarget, this.done);
}

class CountdownArguments {
  final CountdownDatum data;

  CountdownArguments(this.data);
}

class Countdown extends StatelessWidget {
  const Countdown({Key? key}) : super(key: key);

  static const routeName = '/count';
  static const initialTimerValue = 5000;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as CountdownArguments;
    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              args.data.title,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const TimerCountdown(),
          ],
        ),
      ),
    );
  }
}

class TimerCountdown extends StatefulWidget {
  const TimerCountdown({Key? key}) : super(key: key);

  @override
  _TimerCountdownState createState() => _TimerCountdownState();
}

class _TimerCountdownState extends State<TimerCountdown> {
  static Duration hundredMiliSec = const Duration(milliseconds: 100);
  Timer? timer;
  int miliDetikSaatIni = 0;
  int miliDetikSelesai = Countdown.initialTimerValue;
  bool done = false;

  int get detikSisa {
    return ((miliDetikSelesai - miliDetikSaatIni) / 1000).round();
  }

  String get clock {
    return printDuration(Duration(seconds: detikSisa));
  }

  void tick(context) {
    setState(() {
      miliDetikSaatIni += 100;
    });
    if (miliDetikSelesai - miliDetikSaatIni == -100) {
      done = true;
      timer?.cancel();
      deactivate();
      Navigator.of(context)
          .pop(CountdownPopResult(miliDetikSaatIni, miliDetikSelesai, done));
    }
  }

  @override
  void initState() {
    timer = Timer.periodic(hundredMiliSec, (Timer t) => tick(context));
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void setTime(int time) {
    setState(() {
      miliDetikSelesai += time * 1000;
    });
  }

  Future<bool> _onWillPop() async {
    var response = ((await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Apakah kamu yakin?'),
            content:
                const Text('Apakah kamu yakin ingin menghentikan countdown ?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Tidak, tetap lanjutkan countdown'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Ya, hentikan countdown'),
              ),
            ],
          ),
        )) ??
        false);
    if (response) {
      Navigator.of(context)
          .pop(CountdownPopResult(miliDetikSaatIni, miliDetikSelesai, done));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: done
              ? [
                  const Text(
                    'Selesai !',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  )
                ]
              : [
                  Text(
                    clock,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  LinearProgressIndicator(
                    value: miliDetikSaatIni / miliDetikSelesai,
                    semanticsLabel: 'Waktu yang dibutuhkan',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => setTime(1 * 60),
                        child: const Text('+1 min.'),
                      ),
                      ElevatedButton(
                        onPressed: () => setTime(5 * 60),
                        child: const Text('+5 min.'),
                      ),
                      ElevatedButton(
                        onPressed: () => setTime(10 * 60),
                        child: const Text('+10 min.'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => setTime(30 * 60),
                        child: const Text('+30 min.'),
                      ),
                      ElevatedButton(
                        onPressed: () => setTime(60 * 60),
                        child: const Text('+1 hr.'),
                      ),
                      ElevatedButton(
                        onPressed: () => setTime(120 * 60),
                        child: const Text('+2 hr.'),
                      ),
                    ],
                  )
                ],
        ),
      ),
      onWillPop: _onWillPop,
    );
  }
}
