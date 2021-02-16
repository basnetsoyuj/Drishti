import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget{
  HistoryPage(this.historyList);
  final List<String> historyList;
  final String title = "HISTORY";
  final textStyle = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title,),
        centerTitle: true,
      ),
          body: getHistoryListView(),
    );
  }

  Widget getHistoryListView(){

    List<String> historyListItems = historyList == null ? ["Empty"] : historyList;
    var listView = ListView.builder(
      itemCount: historyListItems.length,
      itemBuilder: (context, index)
      {
        return Card(
            child: ListTile(
                title: Text(historyListItems[index], style: textStyle),

            )
        );
      },
    );
    return listView;
  }

}