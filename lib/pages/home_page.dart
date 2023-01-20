import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' show get;
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _disableButton = false;
  bool _isLoading = false;
  NetworkImage? catImage;
  String catFact = "Click on generate to view a random cat fact!";
  String? catFactId;

  void generateContent() async {
    // Image
    // Returns a random cat image
    final Uri imageUrl = Uri.https("cataas.com", "cat", {'json': 'true'});
    final imageResponse = await get(imageUrl);
    final imageJson = json.decode(imageResponse.body);

    // Fact
    // Below API contains 90 facts
    final int factId = Random().nextInt(91);
    final Uri factUrl =
        Uri.https("meowfacts.herokuapp.com", "", {'id': '$factId'});
    final factResponse = await get(factUrl);
    final factJson = json.decode(factResponse.body);

    setState(() {
      _disableButton = false;
      _isLoading = false;
      catFact = factJson['data'][0];
      catFactId = factId.toString();
      catImage = NetworkImage("https://cataas.com${imageJson['url']}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cat Facts Generator")),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: const Color.fromRGBO(25, 39, 52, 1),
        child: SafeArea(
          child: Center(
            child: AnimatedOpacity(
              opacity: _isLoading ? 0.8 : 1,
              duration: const Duration(milliseconds: 200),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (catImage != null)
                    Stack(children: [
                      Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.25),
                        highlightColor: Colors.white.withOpacity(0.4),
                        child: imageHolderWidget(),
                      ),
                      imageHolderWidget(catImage)
                    ]),
                  const SizedBox(height: 10),
                  factWidget(),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _disableButton
                        ? null
                        : () {
                            generateContent();
                            setState(() {
                              _disableButton = true;
                              _isLoading = true;
                            });
                          },
                    child: const Text("GENERATE"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget imageHolderWidget([NetworkImage? image]) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 200,
        decoration: image == null
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.2),
              )
            : BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: image,
                ),
              ),
      ),
    );
  }

  Widget factWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          if (catFactId != null) ...[
            Text(
              "Cat Fact #$catFactId",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 10),
          ],
          Text(
            catFact,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
