import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sharing_option/yaru_title_bar_gesture_detector.dart';
import 'custom_styled_scaffold.dart';


bool AbraCadabra = true;

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomStyledScaffold(body: Container(
                              
                              color:baseColor,
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.green,
                                  ),
                                  Container( height: 44,),
                                  ColorFiltered( colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),child: SizedBox()),
                                    Container(
                                      color: Colors.yellow,
                                      height: 400,
                                    ),
                                    Container(
                                      color: Colors.blue,
                                      height: 400,
                                    ),
                                    Container(
                                      color: const Color.fromARGB(255, 20, 212, 49),
                                      height: 400,
                                    ),
                                    CupertinoNavigationBar(
                                                enableBackgroundFilterBlur: false,
                                                backgroundColor: baseColor.withAlpha(220),
                                                leading: YaruTitleBarGestureDetector(
                                                  
                                                  child: AppBar(
                                                    backgroundColor: Colors.transparent,
                                                    actions: [
                              ElevatedButton(onPressed: (){
                              }, child: Container(),), 
                              ],
                                                    centerTitle: true,
                                                    title: SizedBox(
                                        height: 34,
                                        width: 500,
                                        child: CupertinoSearchTextField(
                                          
                                          prefixIcon: const Padding(
                                            padding: EdgeInsets.fromLTRB(4,6,4,4),
                                            child: ColorFiltered( colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcATop),
                                              child: SizedBox(),
                                            ),
                                          ),
                                          placeholder: 'Ayer me llamo una niña',
                                          style: TextStyle(
                                            color: Theme.of(context).hintColor,
                                          ),
                                        ),
                                      ),
                                                  ),
                                                ),
                                              ),
                                  
                                ],
                              ),
                                                    ),);
  }
}