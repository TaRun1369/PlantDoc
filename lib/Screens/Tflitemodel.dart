import 'dart:io';
import 'package:screens_for_touristapp/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class TfliteModel extends StatefulWidget {
  const TfliteModel({Key? key}) : super(key: key);

  @override
  State<TfliteModel> createState() => _TfliteModelState();
}

class _TfliteModelState extends State<TfliteModel> {
  late File _image;
  late List _results;
  bool imageSelect = false;

  void initState(){
    super.initState();
    loadModel();
  }
  Future loadModel() async {
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(model: "assets/plant_disease_model.tflite",labels: "assets/plant_disease.txt"))!;
    print("Models loading status $res");
  }
  Future imageClassification(File image) async{

    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _results = recognitions!;
      _image = image;
      imageSelect = true;
    });
  }
  Future printImagecamera() async {
    final ImagePicker _picker = ImagePicker();
    final XFile ? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,

    );
    File image = File(pickedFile!.path);
    imageClassification(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wanna know What's the Problem?"),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: mainGradient(context)),
        child: ListView(
          children: [
            (imageSelect)?Container(
              margin: EdgeInsets.all(10.0),
              child: Image.file(_image),

            ):Container(
              margin : const EdgeInsets.all(10.0),
              child: const Opacity(
                opacity: 0.8,
                child: Center(
                  child: Text("Capture and see What's hurting your plant",style: TextStyle(fontWeight: FontWeight.w800),),
                ),
              ),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () {
                printImagecamera();
              },
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: const Icon(Icons.camera,size: 50,),
                ),
                style: ElevatedButton.styleFrom(shape: StadiumBorder()),
              ),


            ),
            SingleChildScrollView(
              child: Column(
                children: (imageSelect)?_results.map((result){
                  return Card(
                    child: Text("${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.black,backgroundColor: Colors.greenAccent,
                          fontSize: 20
                      ),
                    ),
                  );
                }).toList():[],
              ) ,
            )

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickImagegallery,
        tooltip: "Pick Image",
        child: const Icon(Icons.image),
      ),
    );
  }
  Future pickImagegallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile ? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,

    );
    File image = File(pickedFile!.path);
    imageClassification(image);


  }

}


