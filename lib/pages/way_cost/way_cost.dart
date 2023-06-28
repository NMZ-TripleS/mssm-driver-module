import 'package:flutter/material.dart';
import 'package:mssm_driver_app/database/helper.dart';
import 'package:mssm_driver_app/database/models/models.dart';
import 'package:mssm_driver_app/pages/way_cost/edit_way_cost.dart';

class WayCost extends StatefulWidget {
  const WayCost({super.key});

  @override
  State<WayCost> createState() => _WayListState();
}

class _WayListState extends State<WayCost> {
  @override
  void didUpdateWidget(WayCost oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void initState() {
    _cost = PersonDatabaseProvider.db.costs();
    super.initState();
  }

  late Future<List<Cost>> _cost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Costs"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              PersonDatabaseProvider.db.deleteAllCosts();
              setState(() => {
                    _cost = PersonDatabaseProvider.db.costs(),
                    setState(() => {})
                  });
            },
            child: const Text(
              "Delete Costs",
              style: TextStyle(color: Colors.yellow),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Cost>>(
        future: _cost,
        builder: (BuildContext context, AsyncSnapshot<List<Cost>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                Cost item = snapshot.data![index];
                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    PersonDatabaseProvider.db.deleteWay(item.id!).then(
                        (value) => {
                              _cost = PersonDatabaseProvider.db.costs(),
                              setState(() => {})
                            });
                  },
                  child: ListTile(
                    title: Text('${item.title} - ${item.amount}'),
                    subtitle: Text('${item.date} - Way ID ${item.wayId}'),
                    leading: CircleAvatar(child: Text(item.id.toString())),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(
                              builder: (context) => EditCost(
                                    true,
                                    cost: item,
                                  )))
                          .then((value) => {
                                _cost = PersonDatabaseProvider.db.costs(),
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
                    builder: (context) => EditCost(
                          false,
                          cost: Cost.empty(),
                        )))
                .then((value) => {
                      _cost = PersonDatabaseProvider.db.costs(),
                      setState(() => {})
                    });
          }),
    );
  }
}
