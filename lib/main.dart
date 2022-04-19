import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool loading = false;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    //
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            //
            //
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              if (loading)
                const Center(
                  child: CircularProgressIndicator(),
                )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            setState(() {
              loading = true;
            });
            await copyFirestoreDb()
                .then((value) => setState(() {
                      loading = false;
                    }))
                .catchError((error) {
              print(error);
            });
          },
          tooltip: 'Increment',
          child: const Icon(Icons.sync),
        ));
  }
}

Future copyFirestoreDb() async {
  FirebaseFirestore firestoreDestination = FirebaseFirestore.instance;

  final FirebaseApp sharedApp = await Firebase.initializeApp(
    name: 'shared-project',
    options: const FirebaseOptions(
      apiKey: '',
      appId: '',
      messagingSenderId: '',
      projectId: '',
    ),
  );

  FirebaseFirestore firestoreSource =
      FirebaseFirestore.instanceFor(app: sharedApp);

  for (var item in collections) {
    final snapshot = (await firestoreSource.collection(item).get());
    for (var element in snapshot.docs) {
      try {
        final result = await firestoreDestination
            .collection(item)
            .doc(element.id)
            .set(element.data());

        await runCopy(
          firestoreSource.collection(item),
          firestoreDestination.collection(item),
          snapshot.docs,
        );
        // final result = await firestoreDestination
        //         .collection(item)
        //         .doc(element.id)
        //         .set(element.data()

      } catch (error) {
        print(error);
      }
    }

    // snapshot.docs.forEach((element) async {
    // });
  }
}

List<String> collections = [
  'Requested Services',
  'Service Providers',
  'services',
  'userdetails',
  'userlocations',
  'orders',
  'Requested',
  'history',
  'Painting',
  'External Painting',
  'internal Painting',
  'blocked',
  'unblocked',
];

// const schema = {
//   'Requested Services': {
//     friends: {
//       messages: {},
//     },
//     groups: {
//       messages: {},
//     },
//   },
//   'Service Providers': {},
// };

Future runCopy(
    CollectionReference<Map<String, dynamic>> sourceApp,
    CollectionReference<Map<String, dynamic>> destinationApp,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> aux) async {
  for (var document in aux) {
    for (var item in collections) {
      final snapshot =
          (await sourceApp.doc(document.id).collection(item).get());
      if (snapshot.docs.isNotEmpty) {
        for (var element in snapshot.docs) {
          try {
            final result = await destinationApp
                .doc(document.id)
                .collection(item)
                .doc(element.id)
                .set(element.data());

            await runCopy(
              destinationApp.doc(document.id).collection(item),
              destinationApp.doc(document.id).collection(item),
              snapshot.docs,
            );
          } catch (error) {
            print(error);
          }
        }
      }
    }
  }
}

// Future runCopy(
//     CollectionReference<Map<String, dynamic>> sourceApp,
//     CollectionReference<Map<String, dynamic>> destinationApp,
//     List<QueryDocumentSnapshot<Map<String, dynamic>>> aux) async {
//   for (var e in aux) {
//     for (var collection in e.data().keys) {
//       // final result = await firestoreDestination
//       //         .collection(item)
//       //         .doc(element.id)
//       //         .set(element.data()

//       for (var item in collections) {
//         final snapshot = (await firestoreSource.collection(item).get());
//         // for (var element in snapshot.docs) {
//         try {
//           return await runCopy(
//             firestoreSource.collection(item),
//             firestoreDestination.collection(item),
//             snapshot.docs,
//           );
//           // final result = await firestoreDestination
//           //         .collection(item)
//           //         .doc(element.id)
//           //         .set(element.data()

//         } catch (error) {
//           print(error);
//         }

//         // }

//         // snapshot.docs.forEach((element) async {
//         // });
//       }

//       // final _data = await sourceApp.get();
//       // sourceApp.snapshots().map((element) async {
//       //   for (var doc in element.docs) {
//       //     final data = doc.data();
//       //     final result = await destinationApp.doc(doc.id).set(data);
//       //     // .then((value) async {
//       //     for (var item in collections) {
//       //       final snapshot =
//       //           (await sourceApp.doc(doc.id).collection(item).get());
//       //       // for (var element in snapshot.docs) {
//       //       if (snapshot.docs.isNotEmpty) {
//       //         try {
//       //           return await runCopy(
//       //             sourceApp.doc(doc.id).collection(collection),
//       //             destinationApp.doc(doc.id).collection(collection),
//       //             snapshot.docs,
//       //           );
//       //           // final result = await firestoreDestination
//       //           //         .collection(item)
//       //           //         .doc(element.id)
//       //           //         .set(element.data()

//       //         } catch (error) {
//       //           print(error);
//       //         }
//       //       }

//       //       // }

//       //       // snapshot.docs.forEach((element) async {
//       //       // });
//       //     }
//       //   }
//       //   return null;
//       // });
//       // .then((data) async {
//       // List<Future> promises = [];
//       // for (var doc in _data.docs) {

//       // }
//     }
//   }
//   // aux.map((e) => e.data().keys.map((collection) async {

//   //         // });
//   //       // return await Future.wait(promises);
//   //     // });
//   // }));
// }

void printCopy(source, destination, aux) {
  print('copied: $source $destination $aux');
}
