
import 'package:flutter/material.dart';
import 'package:rooster_app/Screens/home_page.dart';
import 'package:rooster_app/const/Sizes.dart';
import 'package:rooster_app/const/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List services=[
    {
      'service_name':'stock',
      'image':'assets/images/stock-rooster.png',
      'link':''
    },
    {
      'service_name': "pos",
      'image':"assets/images/pos.png",
      'link':'https://theravenstyle.com/pos/website/'
    }
  ];
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
      color: Primary.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width:  MediaQuery.of(context).size.width*0.5,
            child: Wrap(
              alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 15.0,
                direction: Axis.horizontal,
                children: services
                    .map((element) => ServiceCard(
                    info:element,
                ))
                    .toList()),
          )
        ],
      ),
      ),
    );
  }


}

class ServiceCard extends StatelessWidget {
  const ServiceCard({super.key, required this.info});
  final Map info;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: InkWell(
        onTap: ()async{
          if(info['link']==''){
          Navigator.pushReplacement(context,
              MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const HomePage();
                  }));
          }
          else{
            final Uri url = Uri.parse(info["link"]);
            if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
          }
          }
        },
        child: Column(
          children: [
            Container(
              // padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
              width:100,
              height: 100,
              color: Primary.darker,
              child:
                Center(
                  child: Image.asset(info['image'],fit: BoxFit.contain,  width:80,
                    height: 80,),
                ),
            ),
            gapH4,
            Text(info['service_name'],style: const TextStyle(color: Colors.white),)
          ],
        ),
      ),
    );
  }
}
