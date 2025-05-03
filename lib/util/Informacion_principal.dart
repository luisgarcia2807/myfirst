import 'package:flutter/material.dart';

class InformacionPrincipal extends StatelessWidget {
  final icon;
  final String name;
  final String nameSeconds;
  final Color? color;
  const InformacionPrincipal({
    Key? key,
    required this.icon,
    required this.name,
    required this.nameSeconds,
    this.color,

  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
          padding:EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color!,
                        ),


                        child: Icon(
                          icon,
                          color: Colors.white,)),
                  ),
                  SizedBox(width: 12,),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,

                        ),),
                      SizedBox(
                        height: 5,
                      ),
                      Text(nameSeconds,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.more_horiz),
            ],
          )
      ),
    );
  }
}
