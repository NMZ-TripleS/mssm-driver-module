import 'package:flutter/material.dart';
import 'package:mssm_driver_app/database/helper.dart';
import 'package:mssm_driver_app/database/models/way.dart';
import 'package:mssm_driver_app/pages/way/view/edit_way.dart';

class WayList extends StatefulWidget {
  const WayList({super.key});

  @override
  State<WayList> createState() => _WayListState();
}

class _WayListState extends State<WayList> {
  @override
  void didUpdateWidget(WayList oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void initState() {
    _ways = PersonDatabaseProvider.db.ways();
    super.initState();
  }

  late Future<List<Way>> _ways;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ways"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              PersonDatabaseProvider.db.deleteAllWays();
              setState(() => {
                    _ways = PersonDatabaseProvider.db.ways(),
                    setState(() => {})
                  });
            },
            child: const Text(
              "Delete Ways",
              style: TextStyle(color: Colors.yellow),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Way>>(
        future: _ways,
        builder: (BuildContext context, AsyncSnapshot<List<Way>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Way item = snapshot.data![index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    PersonDatabaseProvider.db.deleteWay(item.id!).then(
                        (value) => {
                              _ways = PersonDatabaseProvider.db.ways(),
                              setState(() => {})
                            });
                  },
                  child: ListTile(
                    title: Text('${item.from} - ${item.to}'),
                    subtitle: Text(item.date),
                    leading: CircleAvatar(child: Text(item.id.toString())),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => EditWay(
                                    true,
                                    way: item,
                                  )))
                          .then((value) => {
                                _ways = PersonDatabaseProvider.db.ways(),
                                setState(() => {})
                              });
                    },
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => EditWay(
                          false,
                          way: Way.empty(),
                        )))
                .then((value) => {
                      _ways = PersonDatabaseProvider.db.ways(),
                      setState(() => {})
                    });
          }),
    );
  }
}
