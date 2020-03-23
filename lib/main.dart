import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coronavirus SMS',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'Coronavirus SMS 13033'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final List<Message> reasons = [
  Message('1', 'Μετάβαση σε φαρμακείο ή επίσκεψη στον γιατρό.'),
  Message('2', 'Μετάβαση σε κατάστημα προμηθειών αγαθών πρώτης ανάγκης.'),
  Message('3', 'Μετάβαση στην τράπεζα.'),
  Message('4', 'Κίνηση για παροχή βοήθειας σε ανθρώπους που βρίσκονται σε ανάγκη.'),
  Message('5', 'Μετάβαση σε τελετή ή μετάβαση διαζευγμένων γονέων.'),
  Message('6', 'Σωματική άσκηση σε εξωτερικό χώρο ή κίνηση με κατοικίδιο ζώο.')
  ];

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _message = '';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  var nameController = TextEditingController();
  var addressController = TextEditingController();

  void _sendSMS(String message) async {
    String name = await _read('name');
    String address = await _read('address');
    if (name == "" || address == "") {
      _showDialog();
    } else {
      List<String> recipents = ['13033'];
      String smsMessage = message + " " + name + " " + address;
      try {
        String _result =
        await sendSMS(message: smsMessage, recipients: recipents);
        setState(() => _message = _result);
      } catch (error) {
        setState(() => _message = error.toString());
      }
    }
  }

  Future<String> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(key) ?? "";
    return value;
  }

  _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  void _showDialog() async {
    String name = await _read('name');
    String address = await _read('address');
    nameController.text = name;
    addressController.text = address;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Στοιχεία"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                      hintText: 'Το όνομά σας'
                  ),
                  onChanged: (value) {
                    _save('name', value);
                    //nameController.text = value;
                  },
                  controller: nameController,
                ),
                TextField(
                  decoration: InputDecoration(
                    //border: InputBorder.none,
                      hintText: 'Η διεύθυνσή σας'
                  ),
                  onChanged: (value) {
                    _save('address', value);
                    //nameController.text = value;
                  },
                  controller: addressController,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Κλείσιμο"),
              onPressed: () {

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
          icon: Icon(Icons.account_circle),
          onPressed: () {
           _showDialog();
          },
      )
        ]
    ),
      body:
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: false,
              // Let the ListView know how many items it needs to build.
              itemCount: widget.reasons.length,
              // Provide a builder function. This is where the magic happens.
              // Convert each item into a widget based on the type of item it is.
              itemBuilder: (context, index) {
                final item = widget.reasons[index];


                return ListTile(
                  title: Text(item.description),
                  onTap: (){_sendSMS(item.id);},
                  //subtitle: item.buildSubtitle(context),
                );
              },
            ),

    );
  }
}

class Message {
  final String id;
  final String description;

  Message(this.id, this.description);
}
