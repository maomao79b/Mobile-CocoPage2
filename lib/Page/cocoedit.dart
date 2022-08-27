import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '/coco_page.dart';

class CocoEdit extends StatefulWidget {
  const CocoEdit({Key? key,
    required this.coco_id,
    required this.cocovari_id,
    required this.coco_start,
    required this.coco_lat,
    required this.coco_long
  }) : super(key: key);

  final String coco_id, cocovari_id, coco_start, coco_lat, coco_long;

  @override
  State<CocoEdit> createState() => _CocoEditState();
}

class _CocoEditState extends State<CocoEdit> {

  Position? _currentPosition;
  LocationPermission? permission;
  TextEditingController coco_where = new TextEditingController();
  TextEditingController coco_start = new TextEditingController();
  String? coco_lat;
  String? coco_long;
  String? selectedValue;
  List categoryItemList = [];

  void setFromvalue(){
    coco_lat = widget.coco_long;
    coco_long = widget.coco_lat;
    List gfg = [widget.coco_lat, widget.coco_long];
    coco_where.text = gfg.toString();
    coco_start.text = widget.coco_start;
    selectedValue = widget.cocovari_id;

  }

  @override
  void initState() {
    coco_start.text = "";
    setFromvalue();
    getAllCategory();
    super.initState();
  }

  editBang(){
    print(widget.coco_id);
    print(coco_where.value);
    print(coco_start.value);
    print(selectedValue);
  }

  Future<List> getAllCategory() async{
    Uri url = Uri.parse('http://cocoworks.cocopatch.com/cocovari.php');
    var response = await http.get(url);
    if(response.statusCode == 200){
      var jsonData = json.decode(response.body);
      setState((){
        categoryItemList = jsonData;
      });
      return categoryItemList;
    }else{
      throw Exception("We were not able to successfully download the json data.");
    }
  }

  Future Cocoedit() async{
    Uri url = Uri.parse('http://cocoworks.cocopatch.com/cocoupdate.php');
    var response = await http.post(url, body:{
      "coco_id":widget.coco_id,
      "coco_start": coco_start.text,
      "cocovari_id":selectedValue,
      "coco_lat": coco_lat.toString(),
      "coco_long": coco_long.toString()
    });
    var data = json.decode(response.body);
    var fToast = FToast();
    fToast.init(context);
    print(data);
    if(data == "dateError"){
      Fluttertoast.showToast(
          msg:"กรุณาใส่ชื่อรายการ",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16
      );
    }else if(data == "success"){
      Fluttertoast.showToast(
          msg:"แก้ไขข้อมูลสำเร็จ",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.greenAccent,
          textColor: Colors.black,
          fontSize: 16
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context)=> Cocopage())
      );
    }else{
      print;
      Fluttertoast.showToast(
          msg:"กรุณาใส่ข้อมูลให้ครบ",
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.redAccent,
          textColor: Colors.black,
          fontSize: 16
      );
    }
  }

  Future<bool> _onWillPop() async{
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("การยืนยันแก้ไข"),
        content: const Text("คุณยืนยันที่จะแก้ไข"),
        actions: <Widget>[
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(false);
              Cocoedit();
              editBang();
            },
            child: const Text("ยืนยัน"),
          ),
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("ยกเลิก")
          )
        ],
      ),
    )) ?? false;
  }

  _getCurrentLocation(){
    Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true
    ).then((Position position){
      setState((){
        _currentPosition = position;
      });
    }).catchError((e){
      print(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.white, Colors.greenAccent],
                    stops: [0.5, 1.0]
                )
            ),
          ),
          title: const Center(
            child: Text(
              "แก้ไขข้อมูลต้นมะพร้าว",
              style: TextStyle(
                  color: Colors.black
              ),
            ),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: DropdownButtonFormField(
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "เลือกพันธุ์"
                  ),
                  value: selectedValue,
                  hint: const Text("เลือกพันธุ์"),
                  items: categoryItemList.map((list){
                    return DropdownMenuItem(
                      value: list['cocovari_id'],
                      child: Text(list['cocovari_name']),
                    );
                  }).toList(),
                  icon: const Icon(Icons.arrow_drop_down),
                  onChanged: (value){
                    setState((){
                      selectedValue = value.toString();
                      print(selectedValue);
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  readOnly: true,
                  controller: coco_where,
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: IconButton(
                      onPressed: () async{
                        permission = await Geolocator.requestPermission();
                        if(_currentPosition == null){
                          _getCurrentLocation();
                        }else{
                          coco_lat = _currentPosition!.latitude.toString();
                          coco_long = _currentPosition!.longitude.toString();
                          List gfg = [coco_lat, coco_long];
                          coco_where.text = gfg.toString();
                        }
                        _getCurrentLocation();
                      },
                      icon: const Icon(Icons.location_on),
                    ),
                    border: const OutlineInputBorder(),
                    labelText: 'พิกัด',
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: coco_start,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      labelText: "ว/ด/ป"
                  ),
                  readOnly: true,
                  onTap: () async{
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101));
                    if(pickedDate != null){
                      print(pickedDate);
                      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                      print(formattedDate);
                      setState((){
                        coco_start.text = formattedDate as String;
                      });
                    }else{
                      print("Date is not selected");
                    }
                  },
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: (){
                          _onWillPop();
                        },
                        style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white
                        ),
                        child: const Text('ยืนยัน'),
                      ),
                    ),
                    const SizedBox(
                      width: 30,
                    ),
                    Container(
                      height: 50,
                      width: 150,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            onPrimary: Colors.white
                        ),
                        child: const Text('ยกเลิก'),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
