import 'package:flutter/material.dart';
import 'package:duration/duration.dart';
import 'package:quiver/async.dart';

enum EPomodoroActions {
  work,
  shortBreak,
  longBreak,
}

class PomodoroConfig {
  String type;
  int interval;
}

class Pomodoro {
  final _speed = 1;
  var _status = {
    'type': 'none',
    'timer': 0,
    'next': 'work',
  };
  var _timer;
  var _results = {
    'work': 0,
    'shortBreak': 0,
    'longBreak': 0,
  };

  final _config = {
    'work': {
      'duration': 25,
    },
    'shortBreak': {
      'duration': 5,
    },
    'longBreak': {
      'duration': 15,
    },
  };

  start(String type, cb) {
    final duration = _config[type]['duration'];
    final durationInMinutes = Duration(minutes: duration);
    final Duration speed = Duration(seconds: _speed);

    _timer =
        CountdownTimer(durationInMinutes, speed).listen((CountdownTimer t) {
      print(t.remaining);
      cb(t);
    });
  }

  pause(String type) {}

  stop() {
    _timer?.cancel();
  }

  onData(cb) {
    _timer.onData(cb);
  }

  getNext() {
    return _status['next'];
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _remaningTime = '25m:0s';
  bool _started = false;
  EPomodoroActions type = EPomodoroActions.work;
  Pomodoro _pomodoro = Pomodoro();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pomodoro.stop();
    super.dispose();
  }

  _updateTimer(CountdownTimer t) {
    setState(() {
      var dur = t.remaining;
      _remaningTime = printDuration(
        dur,
        abbreviated: true,
        delimiter: ':',
        tersity: DurationTersity.second,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          PopupMenuButton<EPomodoroActions>(
            onSelected: (EPomodoroActions result) {
              print(result);
              _pomodoro.stop();
              _pomodoro.start("${result.toString().split('.').last}", _updateTimer);
              setState(() {
                _started = true;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuItem<EPomodoroActions>>[
              const PopupMenuItem<EPomodoroActions>(
                value: EPomodoroActions.work,
                  child: Text('Inicia un Pomodoro'),
              ),
              const PopupMenuItem<EPomodoroActions>(
                value: EPomodoroActions.shortBreak,
                  child: Text('Inicia un descanso')
              ),
              const PopupMenuItem<EPomodoroActions>(
                  value: EPomodoroActions.longBreak,
                  child: Text('Inicia un descanso largo')
              )
            ],
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$_remaningTime',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          DrawerHeader(
            child: Text('Pomodoro'),
            decoration: BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('data_repo/tomate.png'),
                fit: BoxFit.contain,
              )
            ),
          ),
          ListTile(
            leading: Icon(Icons.data_usage),
            title: Text('Resultados'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Volver'),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      )),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Start',
        child: Icon(_started ? Icons.stop : Icons.play_arrow),
        onPressed: () {
          setState(() {
            if (_started) {
              _pomodoro.stop();
              _remaningTime = '25m:0s';
            } else {
              _pomodoro.start(_pomodoro.getNext(), _updateTimer);
            }
            _started = !_started;;

          });
        },
      ),
    );
  }
}
