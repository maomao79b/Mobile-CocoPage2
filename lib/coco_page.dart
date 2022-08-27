import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Page/cocoadd.dart';
import 'Page/cocoedit.dart';

class Cocopage extends StatefulWidget {
  const Cocopage({Key? key}) : super(key: key);

  @override
  State<Cocopage> createState() => _CocopageState();
}

class _CocopageState extends State<Cocopage> {
  var categoryItemList = [];
  late String _selectedItem;
  static const menuItems = <String>["แก้ไข", "ลบ"];

  final List<PopupMenuItem<String>> _popupMenuItems = menuItems
      .map((String val) => PopupMenuItem<String>(
    value: val,
    child: Text(val),
  ))
      .toList();

  @override
  void initState() {
    getAllCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        titleSpacing: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(),
        ),
        title: const Text("สวนของฉัน", style: TextStyle(color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                  width: 360,
                  height: 450,
                  child: Container(
                    decoration:
                    BoxDecoration(border: Border.all(color: Colors.green)),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    child: FutureBuilder(
                        future: getAllCategory(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List> snapshot) {
                          if (ConnectionState.active != null &&
                              !snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView.builder(
                              itemCount: categoryItemList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  subtitle: Text(
                                      categoryItemList[index]['coco_start']),
                                  title: Text(
                                      categoryItemList[index]['cocovari_name']),
                                  trailing: PopupMenuButton(
                                    itemBuilder: (context) => _popupMenuItems,
                                    onSelected: (String val) {
                                      _selectedItem = val;
                                      if (_selectedItem == "แก้ไข") {
                                        String coco_id =
                                        categoryItemList[index]['coco_id'];
                                        String cocovari_id =
                                        categoryItemList[index]
                                        ['cocovari_id'];
                                        String coco_start =
                                        categoryItemList[index]
                                        ['coco_start'];
                                        String coco_lat =
                                        categoryItemList[index]['coco_lat'];
                                        String coco_long =
                                        categoryItemList[index]
                                        ['coco_long'];
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => CocoEdit(
                                                    coco_id: coco_id,
                                                    cocovari_id: cocovari_id,
                                                    coco_start: coco_start,
                                                    coco_lat: coco_lat,
                                                    coco_long: coco_long)));
                                        print(cocovari_id);
                                      }
                                      else{
                                        setState((){
                                          Uri url = Uri.parse('http://cocoworks.cocopatch.com/cocodelete.php');
                                          http.post(url, body:{
                                            'coco_id':categoryItemList[index]['coco_id'],
                                          });
                                        });
                                        print("ลบ");
                                      }
                                    },
                                  ),
                                  isThreeLine: true,
                                  onTap: () {},
                                );
                              });
                        }),
                  )),
              Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                height: 50,
                width: 300,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => cocoadding()));
                  },
                  icon: const Icon(
                    Icons.add,
                    size: 24,
                  ),
                  label: const Text("เพิ่มต้นมะพร้าว"),
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green, onPrimary: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<List> getAllCategory() async {
    Uri url = Uri.parse('http://cocoworks.cocopatch.com/cocotree.php');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      setState(() {
        categoryItemList = jsonData;
      });
      return categoryItemList;
    } else {
      throw Exception(
          "We were not able to successfully download the json data.");
    }
  }
}
