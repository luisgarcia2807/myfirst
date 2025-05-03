import 'package:flutter/material.dart';
import 'package:mifirst/util/Informacion_principal.dart';
import 'package:mifirst/util/emoticon_face.dart';
import '../theme/theme.dart';


class PacienteScreen extends StatefulWidget {
  const PacienteScreen ({super.key});

  @override
  State<PacienteScreen> createState()=> _PacienteScreen();
}

class _PacienteScreen extends State<PacienteScreen>{
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      backgroundColor: lightColorScheme.primary,
      bottomNavigationBar: BottomNavigationBar(items: [
        BottomNavigationBarItem(icon: Icon(Icons.home),label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.settings),label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.qr_code),label: ''),
      ]),

      body:Stack(
        children: [
          Image.asset('assets/images/ima2.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hola Luis",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),

                              ),
                              SizedBox(height: 8.0,),
                              Text('28/02/2025',
                                style: TextStyle(
                                    color: Colors.white54

                                ),),
                            ],
                          ),
                          Container(
                            decoration:BoxDecoration(color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.notifications_on,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      //search bar
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.blue[800],
                            borderRadius: BorderRadius.circular(12) ),
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text('Explorar',
                              style: TextStyle(
                                color: Colors.white,
                              ),),

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Como te sientes?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:16,
                              fontWeight: FontWeight.bold,
                            ),),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //fine
                          Column(
                            children: [
                              EmoticonFace(
                                emoticonface:'😃',
                                  color: Colors.green,
                              ),
                              SizedBox(
                                height: 8,),
                              Text('Excelente',
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                            ],
                          ),
                          // good
                          Column(
                            children: [
                              EmoticonFace(
                                  emoticonface: '🙂',
                              color: Colors.limeAccent,),
                              SizedBox(
                                height: 8,),
                              Text('Bien',
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                            ],
                          ),
                          Column(
                            children: [
                              EmoticonFace(
                                  emoticonface: '😐',
                              color: Colors.orangeAccent,),
                              SizedBox(
                                height: 8,),
                              Text('Regular',
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                            ],
                          ),
                          Column(
                            children: [
                              EmoticonFace(
                                  emoticonface: '😢',
                              color: Colors.red,),
                              SizedBox(
                                height: 8,),
                              Text('Mal',
                                style: TextStyle(
                                    color: Colors.white
                                ),),
                            ],
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(25),
                    color: Colors.grey[200],
                    child: Center(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Informacion reciente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),),
                              Icon(Icons.more_horiz)
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // examenes principales
                          Expanded(
                            child: ListView(
                              children: [
                                InformacionPrincipal(
                                  icon: Icons.favorite,
                                  name: 'Informacion Medica',
                                  nameSeconds: 'Informacion principal',
                                  color: Colors.red,
                                ),
                                InformacionPrincipal(
                                  icon: Icons.list_alt_rounded,
                                  name: 'Examenes',
                                  nameSeconds: 'Revisado recientemente',
                                  color: Colors.purpleAccent,
                                ),
                                InformacionPrincipal(
                                  icon: Icons.health_and_safety,
                                  name: 'Poliza De Seguro',
                                  nameSeconds: 'Nombre de seguro',
                                  color: Colors.indigo,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),),
        ],
      )


    );
  }

}