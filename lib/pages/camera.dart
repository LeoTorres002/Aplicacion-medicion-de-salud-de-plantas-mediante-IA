import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'ImageClassificationHelper.dart';
import 'package:image/image.dart' as img;


class Camera extends StatefulWidget {
  const Camera({super.key});

  @override
  State<Camera> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<Camera> {
  ImageClassificationHelper? imageClassificationHelper;
  final imagePicker = ImagePicker();
  String? imagePath;
  img.Image? image;
  Map<String, double>? classification;
  bool cameraIsAvailable = Platform.isAndroid || Platform.isIOS;

  @override
  void initState() {
    imageClassificationHelper = ImageClassificationHelper();
    imageClassificationHelper!.initHelper();
    abrircamara();
    super.initState();
  }

  Future abrircamara() async{
    cleanResult();
    final result = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    imagePath = result?.path;
    setState(() {});
    processImage();
  }

  void cleanResult() {
    imagePath = null;
    image = null;
    classification = null;
    setState(() {});
  }

  Future<void> processImage() async {
    if (imagePath != null) {
      final imageData = File(imagePath!).readAsBytesSync();
      image = img.decodeImage(imageData);
      setState(() {});
      classification = await imageClassificationHelper?.inferenceImage(image!);
      setState(() {});
    }
  }

  @override
  void dispose() {
    imageClassificationHelper?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [

          Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imagePath != null) Image.file(File(imagePath!)),
                  if (image == null)
                    const Text("Seleccione foto"),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            if (classification != null)
                              ...(classification!.entries.toList()
                                ..sort(
                                      (a, b) => a.value.compareTo(b.value),
                                ))
                                  .reversed
                                  .take(3)
                                  .map(
                                    (e) => Container(
                                  padding: const EdgeInsets.all(8),
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Text(e.key),
                                      const Spacer(),
                                      Text(e.value.toStringAsFixed(2))
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )),
        ],
      ),
    );
  }
}