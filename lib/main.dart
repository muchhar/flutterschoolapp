import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_picker/file_picker.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}
var result_updata;
User? user = FirebaseAuth.instance.currentUser;

class teacher {
  final String? photo;
  final String about;
  final String name;
  final String key;

  teacher({this.photo, required this.about, required this.name, required this.key});

  factory teacher.fromMap(Map<dynamic, dynamic> map, String key) {
    return teacher(
      photo: map['photo'],
      about: map['about'] ?? '',
      name: map['name'] ?? '',
      key: key
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'about': about,
      'photo': photo,

    };
  }
}

class Post {
  final String? image;
  final String description;
  final String time;
  final String title;
  final String key;



  Post({this.image,required this.key, required this.description, required this.time, required this.title});

  factory Post.fromMap(Map<dynamic, dynamic> map, String key) {

    return Post(
      image: map['image'],
      description: map['description'] ?? '',
      time: map['time'] ?? '',
      title: map['title'] ?? '',
      key: key,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'image': image,
      'time': time,

    };
  }
}
class StudentResult {
  final String name;
  final int number;
  final int obtainMarks;
  final int totalMarks;
  final String percentage;
  final Map<dynamic, dynamic> subject;
   int rank;
    final String std;
    final String title;
    final String date;


  StudentResult({
    required this.name,
    required this.number,
    required this.obtainMarks,
    required this.totalMarks,
    required this.percentage,
    required this.subject,
    required this.rank,
    required this.std,
    required this.title,
    required this.date
  });

  factory StudentResult.fromMap(Map<dynamic, dynamic> map) {
    return StudentResult(
      name: map['name'],
      number: map['number'],
      obtainMarks: map['obtain_marks'],
      totalMarks: map['total_marks'],
      percentage: map['percentage'],
      subject: Map<String, int>.from(map['subject']),
      rank: map['rank'],
      std: map['std'],
      title: map['title'],
      date: map['date']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'number': number,
      'obtain_marks': obtainMarks,
      'total_marks': totalMarks,
      'percentage': percentage,
      'subject': subject,
      'rank': rank,
      'std':std,
      'title':title,
      'date': date
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    routes: {
      ResultPage.routeName: (context) => ResultPage(),
      AdminLogin.routeName: (context) => AdminLogin(),
      AdminMain.routeName: (context) => AdminMain(),
      AdminPost.routeName: (context) => AdminPost(),
      AdminPostUpdate.routeName: (context) => AdminPostUpdate(),
      AdminAboutUpdate.routeName: (context) => AdminAboutUpdate(),
      AdminTeacher.routeName: (context) => AdminTeacher(),
      AdminTeacherUpdate.routeName: (context) => AdminTeacherUpdate(),
      AdminResult.routeName: (context) => AdminResult()
    }
    );
  }
}
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double appBarHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return

              AppBar(
                backgroundColor: Colors.white,
                elevation: 2,
                title: Text('ઓરડીધામ',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
                leading: Container(
                //  color: myTheme.appbar_color,
                  height: 56,
                  width: MediaQuery.of(context).size.width,
                  child:
                  Row(
                    children: [
                      Container(
                        height: 56,
                        width: 56,
                        child: FittedBox(
                          fit:BoxFit.none,
                          child: Image.asset('assets/favicon.png',height: 56,width: 56,),
                        ),
                      ),

                    ],
                  )
                   ),
                actions: <Widget>[
                  IconButton(
                    icon: Icon(Icons.admin_panel_settings,color: Colors.blueAccent,),
                    onPressed: () {
                      //print('Search icon pressed');
                      if(user!=null){
                        Navigator.pushNamed(context, AdminMain.routeName);

                      }
                      else {
                        Navigator.pushNamed(context, AdminLogin.routeName);
                      } },
                  ),

                ],



              );


  }

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;


  final List<Widget> _pages = [
    HomeTab(),
    TextFieldTab(),
    CircleImageTab(),
  ];
  @override
  Widget build(BuildContext context) {

    return
      Scaffold(
          resizeToAvoidBottomInset: false,

          appBar: MyAppBar(),
          body:
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container (


            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
            //  backgroundColor: mytheme.bottom_nav_color,
              currentIndex: _currentIndex,
              selectedItemColor: Color.fromRGBO(184, 184, 184, 1.0),
              unselectedItemColor: Color.fromRGBO(107, 106, 106, 1.0),
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;

                });
              },
                   items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.newspaper),
                       label: 'પોસ્ટ',
                     ),
                     BottomNavigationBarItem(
                       icon: Icon(Icons.book),
                       label: 'વિદ્યાર્થીનું પરિણામ',
                     ),
                     BottomNavigationBarItem(
                       icon: Icon(Icons.school),
                       label: 'શાળાની માહિતી',
                     ),
                   ],

            ),
          ));

  }
}

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}
class _HomeTabState extends State<HomeTab> {
  List<ListItem> main_post=[];
  late Timer _timer;
  bool is_loading=true;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void showNoInternetDialog(BuildContext context,String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void get_firebasepost() async{
    final url = Uri.parse('https://www.google.com');
    try {
      final response = await http.get(url);
    }catch(e){
      showNoInternetDialog(context, "No Internet", "Please check your internet and try again!");

    }
    try {
      _database
          .child('Post')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value;

          List<Post> posts = [];
          if (data is List) {
          } else if (data is Map) {
            data.forEach((key, value) {
              if (value != null) {
                posts.add(Post.fromMap(value as Map<dynamic, dynamic>,key));
              }
            });
          }
          main_post.clear();

          //if (!mounted) return
          posts.sort((a, b) => DateFormat('yyyy-MM-dd hh:mm a').parse(a.time).compareTo(DateFormat('yyyy-MM-dd hh:mm a').parse(b.time)));

          setState(() {
            for (var post in posts) {
              main_post.add(ListItem(title: post.title.toString(),
                  text_large: post.description.toString(),
                  image: post.image.toString(),
                  time: post.time.toString(),
                  id: post.time.toString()));
            }
            is_loading = false;
          });
        }
        else {
          print('No data available');
        }
      });


    }catch(e){
      showNoInternetDialog(context, "Error", e.toString());
      setState(() {
        is_loading=false;
      });

    }

}
  @override
  void initState() {
    super.initState();
    get_firebasepost();
    }
  @override
  void dispose() {
   super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!is_loading){
      return Center(
        child:ListView.builder(
             itemCount: main_post.length,
          itemBuilder: (context, index) {
            final reversedIndex = main_post.length - 1 - index;
            final item = main_post[reversedIndex];
            return Container(
              key: Key(item.title + index.toString()),
              child: buildListItem(item),
            );

          },
        ),
         );
    }else{
      return Center(
        child: CircularProgressIndicator(

        )
      );

    }

  }

  Widget buildListItem(item) {
    return
                  Center(
                          child: Column(
                           crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 20,),
                              Container(
                                margin: EdgeInsets.only(left: 5,right: 5),
                                child:   Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 5,
                                  softWrap: true,
                                ),

                              ),
                              Container(
                                margin: EdgeInsets.only(right: 5),
                                child: Align(
                                  alignment: Alignment.topRight,

                                  child:
                                  Text(
                                    '('+item.time+')',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,

                                    ),
                                    textAlign: TextAlign.end,
                                    //overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    softWrap: true,
                                  ),

                                ),

                              ),
                              SizedBox(height: 10,),
                              Image.network(
                                item.image,
                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                  return Text(
                                      'Fail to load image. Check your internet connection.',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 18),);
                                },
                                fit: BoxFit.fill,
                                height: 300,
                                width: MediaQuery.of(context).size.width*0.98,

                                loadingBuilder: (BuildContext context, Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: Text(
                                  item.text_large,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,

                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1000,
                                  softWrap: true,
                                ),
                              ),



                              SizedBox(height: 10,),
                              Divider(color: Colors.black,height: 5,),
                              SizedBox(height: 10,)
                             ],
                          ),

              );
          }


}

class TextFieldTab extends StatefulWidget {
  @override
  _TextFieldTab createState() => _TextFieldTab();
}
class _TextFieldTab extends State<TextFieldTab> {
  TextEditingController _phoneNumberController = TextEditingController();
  String error_text='';
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
          return
            WillPopScope(child:Dialog(
              elevation: 0,

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)
              ),
              backgroundColor: Colors.transparent,

              child: Column(

                mainAxisSize: MainAxisSize.min,

                children: <Widget>[
                  Align(
                    alignment: Alignment.center,
                    child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                    ),

                  ),

                ],
              ),

            ) , onWillPop: ()=> Future.value(false));


      },
    );
  }
  void showNoInternetDialog(BuildContext context,String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  void fetchResult(String number) async {
    _loading_dialog();
    final url = Uri.parse('https://www.google.com');
    try {
      final response = await http.get(url);
    }catch(e){
      Navigator.of(context).pop();
      showNoInternetDialog(context, "No Internet", "Please check your internet and try again!");

    }
    try{
    _database.child('Results').orderByChild('number').equalTo(int.parse(number)).onValue.listen((event) {
      if (event.snapshot.value != null && event.snapshot.value is Map) {
        var rawList = event.snapshot.value;
        print(rawList);

        Map<String, dynamic> data = Map<String, dynamic>.from(event.snapshot.value as Map);

        List<MapEntry<String, dynamic>> entries = data.entries.toList();
        entries.sort((a, b) {
          DateTime dateA = DateFormat('yyyy-MM-dd HH:mm:ss').parse(a.value['date']);
          DateTime dateB = DateFormat('yyyy-MM-dd HH:mm:ss').parse(b.value['date']);
          return dateB.compareTo(dateA); // For descending order
        });

        result_updata = Map.fromEntries(entries);

        if (rawList is List) {
          print("object");
        } else if (rawList is Map) {

        }
        Navigator.of(context).pop();
         Navigator.pushNamed(context, ResultPage.routeName);


      } else {
        Navigator.of(context).pop();
        print('No data available');
        setState(() {
          error_text= 'આ નંબર પર પરિણામ મળ્યું નથી. તમારો નંબર જાણવા માટે શાળા નો સંપર્ક કરો';
        });
      }

    });}catch(e){
          setState(() {
            error_text='Network error: $e';

          });
          Navigator.of(context).pop();
    }
  }
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(height: 20,),
          Text("વિદ્યાર્થીનું પરિણામ",style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
          SizedBox(height: 20,),
          Container(
            margin: EdgeInsets.only(left: 50,right: 50),
            child:TextField(
              controller: _phoneNumberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'ફોન નંબર દાખલ કરો',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),

          ),
          SizedBox(height: 20,),
          Row(
            children: [
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width*0.90,
                child: Text('તમારા બાળકનું પરિણામ જોવા માટે તમે શાળાને આપેલ ફોન નંબર દાખલ કરો.',overflow: TextOverflow.visible,),

              ),
              Spacer()

            ],
          ),
          SizedBox(height: 20,),
          Container(
            width: 150,
          height: 40,
          child: ElevatedButton(

            onPressed: () {
              String phoneNumber = _phoneNumberController.text;
              if(phoneNumber.length<10){
                setState(() {
                  error_text='*કૃપા કરીને તમારો દસ અંકનો ફોન નંબર દાખલ કરો!';
                });
              }else{
                setState(() {
                  error_text='';
                });
                fetchResult(phoneNumber);
              }
            },
            child: Text('પરિણામ જુઓ'),
          ),
          ),
          SizedBox(height: 10,),

          Row(
            children: [
              Spacer(),
              Container(
                width: MediaQuery.of(context).size.width*0.90,
                child: Text( error_text ,style: TextStyle(color: Colors.red) ,overflow: TextOverflow.visible,),

              ),
              Spacer()

            ],
          ),

        ],
      ),

    );
  }
}

class CircleImageTab extends StatefulWidget {
  @override
  _CircleImageTab createState() => _CircleImageTab();
}
class _CircleImageTab extends State<CircleImageTab> {
  List<ListItem> main_post=[];
  List<ListItem> shcool_info=[];
  bool is_loading=true;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  void get_teacher() async{
    _database.child('Teacher').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value;

        List<teacher> posts = [];
        if (data is Map) {
          data.forEach((key, value) {
            if (value != null) {
              posts.add(teacher.fromMap(value as Map<dynamic, dynamic>,key));
            }
          });
        }


        setState(() {
          main_post.clear();

          is_loading=false;
          for (var post in posts) {
            main_post.add(ListItem(title: post.name.toString(), text_large: post.about.toString(), image: post.photo.toString(),time: "",id: post.photo.toString()));

          }
        });
      } else {

        is_loading=false;
        print('No data available');
      }
    });

  }
  void get_school() async{
    _database.child('Schools').onValue.listen((event) {
      if (event.snapshot.value != null) {
        List<dynamic> rawList = event.snapshot.value as List<dynamic>;
        print(rawList);
        shcool_info.clear();
        setState(() {
          for(var i in rawList){
            if(i!=null){
              shcool_info.add(ListItem(title: "", text_large: i["about"], image: i["image"], time: '', id:i["image"] ));
            }
          }
        });
      } else {
        print('No data available');
      }
    });

  }
  @override
  void initState() {
    super.initState();

    get_teacher();
    get_school();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(!is_loading){
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 15,),
            Row(
              children: [
                SizedBox(width: 10,),
                Text("શિક્ષકોની માહિતી",style: TextStyle(fontSize: 22,color: Colors.black,fontWeight: FontWeight.bold),),
              ],
            ),
            SizedBox(height: 10,),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: main_post.length,
              itemBuilder: (context, index) {
                final reversedIndex = main_post.length - 1 - index;
                final item = main_post[reversedIndex];
                return Container(
                  key: Key(item.title + index.toString()),
                  child: buildListItemTeacher(item),
                );
              },
            ),
            Divider(color: Colors.black,),
           SizedBox(height: 10,),
            Row(
              children: [
                SizedBox(width: 10,),
                Text("શાળા વિશે",style: TextStyle(fontSize: 22,color: Colors.black,fontWeight: FontWeight.bold),),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: shcool_info.length,
              itemBuilder: (context, index) {
                final reversedIndex = shcool_info.length - 1 - index;
                final item = shcool_info[reversedIndex];
                return Container(
                  key: Key(item.text_large + index.toString()),
                  child: buildListItem(item),
                );
              },
            ),
          ],
        ),
      );



    }
    else
    {
      return Center(
          child: CircularProgressIndicator(

          )
      );

    }

  }

  Widget buildListItemTeacher(item) {
    return
      Center(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10,height: MediaQuery.of(context).size.width*0.35,),
                ClipOval(

                  child:
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.width*0.3,
                    width: MediaQuery.of(context).size.width*0.3,

                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),

                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20,right: 10),
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),

                    ),
                    SizedBox(height: 10,),

                    Container(
                      width: MediaQuery.of(context).size.width*0.55,
                      margin: EdgeInsets.only(left: 20,right: 10),
                      child: Text(
                        item.text_large,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 6,
                        softWrap: true,
                      ),
                    ),




                  ],
                ),
                SizedBox(width: 10,)
              ],
            ),
            SizedBox(height: 20,)
          ],
        )


      );
  }
  Widget buildListItem(item) {
    return
      Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20,),

            Image.network(
              item.image,
              fit: BoxFit.cover,
              height: 300,
              width: MediaQuery.of(context).size.width*0.98,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                item.text_large,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,

                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1000,
                softWrap: true,
              ),
            ),



            SizedBox(height: 10,),
            Divider(color: Colors.black,height: 5,),
            SizedBox(height: 10,)
          ],
        ),

      );
  }


}

class ResultPage extends StatefulWidget {
  static const routeName = '/showresult';

  @override
  _resultpage createState() => _resultpage();
}
class _resultpage extends State<ResultPage> {

  @override
  void initState() {
    super.initState();
    print(result_updata);
    for(var i in result_updata.keys){
      result_updata[i]['color'] = Colors.yellowAccent;
      result_updata[i]['font'] = Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('પરિણામ',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20,),
            for(var i in result_updata.keys)
            Container(
              margin: EdgeInsets.only(left:10,right:10,top:10,bottom: 30),

              padding: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: result_updata[i]['color'] ,
                border: Border.all(
                  color: Colors.black,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  SizedBox(height: 10,),
                  Text("વિદ્યાર્થીનું નામ: "+ result_updata[i]["name"],style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: result_updata[i]['font'] ),),
                  Divider(height: 2,color: Colors.grey,),
                  SizedBox(height: 5,),
                  Text("ધોરણ: "+ result_updata[i]["std"],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),
                  Divider(height: 4,color: Colors.black,),
                  SizedBox(height: 20,),
                  Row(
                    children: [
                      Spacer(),
                      Text(result_updata[i]["title"],style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),
                      Spacer()
                    ],
                  ),
                  SizedBox(height: 20,),
                  Divider(height: 4,color: Colors.black,),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width*0.3,
                        child:
                        Align(
                          alignment: Alignment.centerLeft, // Aligns text to the left

                          child: Text("વિષય",style: TextStyle(fontSize: 18,color: result_updata[i]['font']),),
                        )
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width*0.3,
                        child:Align(
                          alignment: Alignment.center, // Aligns text to the left

                          child: Text("કુલ ગુણ",style: TextStyle(fontSize: 18,color: result_updata[i]['font']),),

                        )

                      ),
                      Container(
                        width: MediaQuery.of(context).size.width*0.3,
                        child:Align(
                          alignment: Alignment.centerRight,
                          child: Text("મેળવેલ ગુણ",style: TextStyle(fontSize: 18,color: result_updata[i]['font'])),
                      )

                      ),

                    ],
                  ),
                  Divider(height: 3,color: Colors.black,),
                  SizedBox(height: 15,),

                  for(var pi in result_updata[i]['subject'].keys)
                    Column(
                      children: [
                        Row(
                          children: [


                            Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child:
                                Align(
                                  alignment: Alignment.centerLeft, // Aligns text to the left

                                  child: Text(pi,style: TextStyle(fontSize: 18,color: result_updata[i]['font']),),
                                )
                            ),

                            Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child:Align(
                                  alignment: Alignment.center, // Aligns text to the left

                                  child: Text((result_updata[i]['total_marks']/result_updata[i]['subject'].keys.length).toStringAsFixed(0),style: TextStyle(fontSize: 18,color: result_updata[i]['font']),),

                                )

                            ),
                            Container(
                                width: MediaQuery.of(context).size.width*0.3,
                                child:Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(result_updata[i]['subject'][pi].toString(),style: TextStyle(fontSize: 18,color: result_updata[i]['font'])),
                                )

                            ),

                          ],
                        ),
                        Divider(height: 3,color: Colors.black,),
                        SizedBox(height: 5,)
                      ],
                    ),

                  SizedBox(height: 20,),
                  Divider(color: Colors.black,height: 4,),
                  Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child:
                          Align(
                            alignment: Alignment.centerLeft, // Aligns text to the left

                            child: Text("કુલ",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),
                          )
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child:Align(
                            alignment: Alignment.center, // Aligns text to the left

                            child: Text(result_updata[i]['total_marks'].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),

                          )

                      ),
                      Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child:Align(
                            alignment: Alignment.centerRight,
                            child: Text(result_updata[i]['obtain_marks'].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font'])),
                          )

                      ),

                    ],
                  ),
                  Divider(color: Colors.black,height: 4,),
                  SizedBox(height: 30,),

                  Divider(height: 4,color: Colors.black,),
                  SizedBox(height: 10,),
                  Row(
                    children: [

                      Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child:
                          Align(
                            alignment: Alignment.centerLeft, // Aligns text to the left

                            child: Text("ટકા:  "+result_updata[i]['percentage'].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),
                          )
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          child:Align(
                            alignment: Alignment.center, // Aligns text to the left

                            child: Text("રેન્ક:  "+result_updata[i]['rank'].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: result_updata[i]['font']),),

                          )

                      ),

                    ],
                  ),
                  SizedBox(height: 10,)

                ],
              ),
            )
          ],
        )

      ),
    );
  }
}
class AdminLogin extends StatefulWidget {
  static const routeName = '/adminlogin';

  @override
  _AdminLogin createState() => _AdminLogin();
}
class _AdminLogin extends State<AdminLogin> {

   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String error_msg='';
   void _loading_dialog() {

     showDialog(
       context: context,

       builder: (BuildContext context) {
         return
           WillPopScope(child:Dialog(
             elevation: 0,

             shape: RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(10.0)
             ),
             backgroundColor: Colors.transparent,

             child: Column(

               mainAxisSize: MainAxisSize.min,

               children: <Widget>[
                 Align(
                   alignment: Alignment.center,
                   child:LoadingAnimationWidget.hexagonDots(

                       size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                   ),

                 ),

               ],
             ),

           ) , onWillPop: ()=> Future.value(false));


       },
     );
   }

   Future<void> _signIn() async {
    print(user);
    if(user==null){
      _loading_dialog();
      print("Not login");
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print(userCredential);
      user = userCredential.user;
      Navigator.of(context).pop();
      Navigator.pushNamed(context, AdminMain.routeName);

      // return userCredential;
    } on FirebaseAuthException catch (e) {
      Navigator.of(context).pop();

      if (e.code == 'user-not-found') {
        setState(() {
          error_msg ='No user found for that email.';
        });
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        setState(() {
          error_msg = 'Wrong password provided for that user.';
        });
      }else{
        setState(() {
          error_msg = 'Invalid email or password.';
        });
      }
     // return null;
    }}
    else{
      Navigator.pushNamed(context, AdminMain.routeName);

      print("Login");
    }
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Login',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child:
              Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _signIn,
                child: Text('      Sign In      '),
              ),
             SizedBox(height: 10,),
              Text(error_msg,style: TextStyle(color: Colors.red),)
              ],
          )
              )
      ),
    );
  }
}

class AdminMain extends StatefulWidget {
  static const routeName = '/adminmain';

  @override
  _AdminMain createState() => _AdminMain();
}
class _AdminMain extends State<AdminMain> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Admin Panel',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
         child: Padding(
              padding: const EdgeInsets.all(24.0),

              child: Column(
                children: [
                  SizedBox(height: 20,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, AdminPost.routeName);

                    },
                    child: Text('    Add/Delete Post      ',style: TextStyle(fontSize: 18),),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, AdminAboutUpdate.routeName);

                    },
                    child: Text('      About School        ',style: TextStyle(fontSize: 18),),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, AdminTeacher.routeName);

                    },
                    child: Text('         Teachers           ',style: TextStyle(fontSize: 18),),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pushNamed(context, AdminResult.routeName);

                    },
                    child: Text('            Result              ',style: TextStyle(fontSize: 18),),
                  ),
                  ],
              )
          ))
      ),
    );
  }
}


class AdminPost extends StatefulWidget {
  static const routeName = '/adminpost';

  @override
  _AdminPost createState() => _AdminPost();
}
class _AdminPost extends State<AdminPost> {
  Future<void> addPost(String title, String description, String imageUrl) async {
    // Get the current user
    DateTime now = DateTime.now();
    if (user != null) {
      // Create a new post
      Post newPost = Post(
          title: title,
          description: description,
          image: imageUrl,
          time: DateFormat('yyyy-MM-dd h:mm a').format(now),
        key: ""
      );

      // Get a reference to the database
      DatabaseReference postRef = FirebaseDatabase.instance.ref().child('Post');

      // Create a new entry with a unique key
      DatabaseReference newPostRef = postRef.push();

      // Set the value of the new entry
      await newPostRef.set(newPost.toMap());

      print('Post added successfully');
    } else {
      print('No user is currently signed in');
    }
  }
  List<ListItem> main_post=[];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Post> _posts = [];
  bool is_loading =true;

  void get_firebasepost() async{
    try {
      _database
          .child('Post')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value;

          List<Post> posts = [];
          if (data is List) {
            // posts = data
            //     .where((item) => item != null)
            //     .map((item) => Post.fromMap(item as Map<dynamic, dynamic>))
            //     .toList();
          } else if (data is Map) {
            data.forEach((key, value) {
              if (value != null) {
                posts.add(Post.fromMap(value as Map<dynamic, dynamic>,key));
              }
            });
          }
          if (!mounted) return

            _posts.clear();
          setState(() {
            _posts =posts;
            is_loading=false;
          });

        }
        else {
          print('No data available');
        }
      });
    }catch(e){
      //showNoInternetDialog(context, "Error", e.toString());
    }

  }
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  void _deletePost(Post post) async {
    // Delete image from Firebase Storage if it exists
    _loading_dialog();
    if (post.image != null) {
      try {
        await FirebaseStorage.instance.refFromURL(post.image!).delete();
      } catch (e) {
        print('Failed to delete image: $e');
      }
    }

    // Delete post from Firebase Realtime Database
    try{
    _database.child('Post').child(post.key).remove();
    Navigator.of(context).pop();

    }catch(e){
      Navigator.of(context).pop();

    }
  }

  @override
  void initState() {
    super.initState();
    get_firebasepost();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Post',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: (){
                          Navigator.pushNamed(context, AdminPostUpdate.routeName);
                          
                        },
                        child: Text('    Add New Post      ',style: TextStyle(fontSize: 18),),
                      ),
                      SizedBox(height: 30,),
                      Text("Delete Post:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      SizedBox(height: 10,),
                      if(is_loading)
                        Center(
                            child: CircularProgressIndicator(

                            )
                        ),
                      for(var i in _posts)
                        Container(
                          color: Colors.grey[200],  // Set the background color here
                          padding: EdgeInsets.all(10),
                          margin: EdgeInsets.all(5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  i.title,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  i.time,
                                  overflow: TextOverflow.visible,
                                  style: TextStyle(color: Colors.blueAccent,fontSize: 14),
                                ),
                              ),

                              IconButton(onPressed: (){
                                _deletePost(i);
                              }, icon: Icon(Icons.delete,color: Colors.red,))
                            ],
                          ),
                        )
                       ],
                  )
              ))

    );
  }
}

class AdminPostUpdate extends StatefulWidget {
  static const routeName = '/adminpostupdate';

  @override
  _AdminPostUpdate createState() => _AdminPostUpdate();
}
class _AdminPostUpdate extends State<AdminPostUpdate> {
  TextEditingController _title = TextEditingController();
  TextEditingController _des = TextEditingController();
  String error_msg='';
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  var image_path;
  Future<void> addPost() async {
    // Get the current user
    DateTime now = DateTime.now();
    String downloadURL="";
    print(user);
    if (user != null) {
      // Create a new post
      _loading_dialog();
      try {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('uploads/${DateTime.now().millisecondsSinceEpoch}')
            .putFile(image_path);

        TaskSnapshot snapshot = await uploadTask;
        downloadURL = await snapshot.ref.getDownloadURL();
        //return downloadURL;
      } catch (e) {
        print('Error uploading image: $e');
        setState(() {
          error_msg = "Fail to post. please try again.";
        });
        Navigator.of(context).pop();

        return null;
      }
      Post newPost = Post(
          title: _title.text,
          description: _des.text,
          image: downloadURL,
          time: DateFormat('yyyy-MM-dd h:mm a').format(now),
          key: ""
      );

      try{
      // Get a reference to the database
      DatabaseReference postRef = FirebaseDatabase.instance.ref().child('Post');

      // Create a new entry with a unique key
      DatabaseReference newPostRef = postRef.push();

      // Set the value of the new entry
      await newPostRef.set(newPost.toMap());
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      }catch(e){
        setState(() {
          error_msg = "Fail to post. please try again.";
        });
        Navigator.of(context).pop();

      }
      print('Post added successfully');
    } else {
      print('No user is currently signed in');
    }
  }
  Future<void> _pickImage(ImageSource source) async{
    try{
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        // Crop the image after it's selected
        ImageCropper imageCropper = ImageCropper();

        final croppedFile = await imageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [CropAspectRatioPreset.original],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color.fromRGBO(32, 36, 47, 1),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Crop Image',
          ),
        );
        if(croppedFile!=null){
          setState(() {
            image_path = croppedFile;
          });
        }
      }


    }catch(e){
      print(e);
    }
   // Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Add/Update Post',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      TextField(
                        controller: _title,
                        decoration: InputDecoration(labelText: 'Title'),
                        ),

                      TextField(
                        controller: _des,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(labelText: 'Description'),
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 50, // when user presses enter it will adapt to it
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Spacer(),
                          Text("Choose Image:  "),
                          IconButton(onPressed: (){_pickImage(ImageSource.gallery);}, icon: Icon(Icons.image)),
                          Spacer()
                        ],
                      ),
                      if(image_path!=null)
                      Image.file(image_path),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: (){
                          if(_title.text.length<2){
                            setState(() {
                              error_msg ="Please add post title.";
                            });
                          }else if(_des.text.length<2){
                            setState(() {
                              error_msg = "Please add post descriptions.";
                            });
                          }else if(image_path==null){
                            setState(() {
                              error_msg = "Please choose post image.";
                            });
                          }
                          else{
                          addPost();}
                        },
                        child: Text('    Done      ',style: TextStyle(fontSize: 18),),
                      ),
                      SizedBox(height: 10,),
                      Text(error_msg,style: TextStyle(color: Colors.red),)
                    ],
                  )
              ))
      ),
    );
  }
}

class AdminAboutUpdate extends StatefulWidget {
  static const routeName = '/adminabout';

  @override
  _AdminAboutUpdate createState() => _AdminAboutUpdate();
}
class _AdminAboutUpdate extends State<AdminAboutUpdate> {
  TextEditingController _about = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  List<ListItem> shcool_info=[];
  String img_path="";
  var image_path;
  String key='1';
  String error_msg='';
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  void upate() async{
    _loading_dialog();
    String downloadURL = img_path;
    if(image_path!=null){
    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref('uploads/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(image_path);

      TaskSnapshot snapshot = await uploadTask;
      downloadURL = await snapshot.ref.getDownloadURL();
      try {
        await FirebaseStorage.instance.refFromURL(img_path!).delete();
      }catch(e){

      }
      //return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      Navigator.of(context).pop();
      setState(() {
        error_msg = "Fail to update about. please try again.";
      });

      return null;
    }
    }
    try {
      _database.child('Schools').child(key).update(
          {"about": _about.text, "image": downloadURL});
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Success!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

    }catch(e){
      Navigator.of(context).pop();
      setState(() {
        error_msg = "Fail to update about. please try again.";
      });

    }
    }
  Future<void> _pickImage(ImageSource source) async{
    try{
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        // Crop the image after it's selected
        ImageCropper imageCropper = ImageCropper();

        final croppedFile = await imageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [CropAspectRatioPreset.original],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color.fromRGBO(32, 36, 47, 1),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Crop Image',
          ),
        );
        if(croppedFile!=null){
          setState(() {
            image_path = croppedFile;
          });
        }
      }


    }catch(e){
      print(e);
    }
    // Navigator.of(context).pop();
  }
  void get_school() async{
    _database.child('Schools').onValue.listen((event) {
      if (event.snapshot.value != null ) {

        List<dynamic> rawList = event.snapshot.value as List<dynamic>;
        print(event.snapshot.key);
        print(rawList);

        shcool_info.clear();
        setState(() {
          for(var i=0; i<rawList.length;i++){
            print("i ==  "+i.toString());
            if(rawList[i]!=null){
              _about.text =rawList[i]["about"];
              img_path = rawList[i]['image'];
            }
          }
        });
      } else {
        print('No data available');
      }
    });
    }

  @override
  void initState() {
    super.initState();
    get_school();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Add/Update Post',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      Text("Update Info:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      SizedBox(height: 20,),

                      TextField(
                        controller: _about,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(labelText: 'Description'),
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 50, // when user presses enter it will adapt to it
                      ),
                      Row(
                        children: [
                        Spacer(),
                          Text("Choose Image:  "),
                          IconButton(onPressed: (){_pickImage(ImageSource.gallery);}, icon: Icon(Icons.image)),

                          Spacer()  
                        ],
                      ),
                      if(img_path!="" && image_path==null)
                        Image.network(img_path),
                      if(image_path!=null)
                        Image.file(image_path),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: (){
                          upate();

                        },
                        child: Text('    Save      ',style: TextStyle(fontSize: 18),),
                      ),
                      SizedBox(height: 10,),
                      Text(error_msg,style: TextStyle(color: Colors.red),)
                    ],
                  )
              ))
      ),
    );
  }
}


class AdminTeacher extends StatefulWidget {
  static const routeName = '/adminteacher';

  @override
  _AdminTeacher createState() => _AdminTeacher();
}
class _AdminTeacher extends State<AdminTeacher> {
  Future<void> addPost(String title, String description, String imageUrl) async {
    // Get the current user
    DateTime now = DateTime.now();
    if (user != null) {
      // Create a new post
      Post newPost = Post(
          title: title,
          description: description,
          image: imageUrl,
          time: DateFormat('yyyy-MM-dd h:mm a').format(now),
          key: ""
      );

      // Get a reference to the database
      DatabaseReference postRef = FirebaseDatabase.instance.ref().child('Post');

      // Create a new entry with a unique key
      DatabaseReference newPostRef = postRef.push();

      // Set the value of the new entry
      await newPostRef.set(newPost.toMap());

      print('Post added successfully');
    } else {
      print('No user is currently signed in');
    }
  }
  List<ListItem> main_post=[];
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<teacher> _posts = [];
  bool is_loading = true;
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  void get_firebasepost() async{

    try {
      _database
          .child('Teacher')
          .onValue
          .listen((event) {
        if (event.snapshot.value != null) {
          final data = event.snapshot.value;

          List<teacher> posts = [];
          if (data is List) {
            // posts = data
            //     .where((item) => item != null)
            //     .map((item) => Post.fromMap(item as Map<dynamic, dynamic>))
            //     .toList();
          } else if (data is Map) {
            data.forEach((key, value) {
              if (value != null) {
                posts.add(teacher.fromMap(value as Map<dynamic, dynamic>,key));
              }
            });
          }
          if (!mounted) return

            _posts.clear();
          setState(() {
            _posts =posts;
            is_loading =false;
          });



          // });
        }
        else {
          print('No data available');
          setState(() {
            is_loading =false;
          });
        }
      });
    }catch(e){
      setState(() {
        is_loading =false;
      });
      //showNoInternetDialog(context, "Error", e.toString());
    }

  }
  void _deletePost(teacher post) async {
    // Delete image from Firebase Storage if it exists
    _loading_dialog();
    if (post.photo != null) {
      try {
        await FirebaseStorage.instance.refFromURL(post.photo!).delete();
      } catch (e) {
        print('Failed to delete image: $e');
      }
    }

    // Delete post from Firebase Realtime Database
    try {
      _database.child('Teacher').child(post.key).remove();
      Navigator.of(context).pop();

    }catch(e){
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    get_firebasepost();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          title: Text('Teacher',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20,),
                    ElevatedButton(
                      onPressed: (){
                        Navigator.pushNamed(context, AdminTeacherUpdate.routeName);

                      },
                      child: Text('    Add New Teacher      ',style: TextStyle(fontSize: 18),),
                    ),
                    SizedBox(height: 30,),
                    Text("Delete Teacher:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 10,),
                    if(is_loading)
                      Center(
                          child: CircularProgressIndicator(

                          )
                      ),
                    for(var i in _posts)
                      Container(
                        color: Colors.grey[200],  // Set the background color here
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                i.name,
                                overflow: TextOverflow.visible,
                              ),
                            ),


                            IconButton(onPressed: (){
                              _deletePost(i);
                            }, icon: Icon(Icons.delete,color: Colors.red,))
                          ],
                        ),
                      )
                  ],
                )
            ))

    );
  }
}

class AdminTeacherUpdate extends StatefulWidget {
  static const routeName = '/adminteacherupdate';

  @override
  _AdminTeacherUpdate createState() => _AdminTeacherUpdate();
}
class _AdminTeacherUpdate extends State<AdminTeacherUpdate> {
  TextEditingController _title = TextEditingController();
  TextEditingController _des = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.reference();
  String error_msg='';
  var image_path;

  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  Future<void> addPost() async {
    // Get the current user
    DateTime now = DateTime.now();
    String downloadURL="";
    print(user);
    if (user != null) {
      // Create a new post
      _loading_dialog();
      try {
        UploadTask uploadTask = FirebaseStorage.instance
            .ref('uploads/${DateTime.now().millisecondsSinceEpoch}')
            .putFile(image_path);

        TaskSnapshot snapshot = await uploadTask;
        downloadURL = await snapshot.ref.getDownloadURL();
        //return downloadURL;
      } catch (e) {
        print('Error uploading image: $e');
        Navigator.of(context).pop();
        setState(() {
          error_msg = "Fail to add teacher. please try again.";
        });
        return null;
      }
      teacher newPost = teacher(
          name: _title.text,
          about: _des.text,
          photo: downloadURL,
          key: ""
      );

      try {
        // Get a reference to the database
        DatabaseReference postRef = FirebaseDatabase.instance.ref().child(
            'Teacher');

        // Create a new entry with a unique key
        DatabaseReference newPostRef = postRef.push();

        // Set the value of the new entry
        await newPostRef.set(newPost.toMap());
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Success!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

      }catch(e){
        Navigator.of(context).pop();
        setState(() {
          error_msg = "Fail to add teacher. please try again.";
        });
      }
      print('Post added successfully');
    } else {
      print('No user is currently signed in');
      setState(() {
        error_msg = "Fail to add teacher. please try again.";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async{
    try{
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        // Crop the image after it's selected
        ImageCropper imageCropper = ImageCropper();

        final croppedFile = await imageCropper.cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [CropAspectRatioPreset.original],
          androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Color.fromRGBO(32, 36, 47, 1),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          iosUiSettings: IOSUiSettings(
            title: 'Crop Image',
          ),
        );
        if(croppedFile!=null){
          setState(() {
            image_path = croppedFile;
          });
        }
      }


    }catch(e){
      print(e);
    }
    // Navigator.of(context).pop();
  }


  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        title: Text('Add/Update Teacher',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24.0),

                  child: Column(
                    children: [
                      SizedBox(height: 20,),
                      TextField(
                        controller: _title,
                        decoration: InputDecoration(labelText: 'Name'),
                      ),

                      TextField(
                        controller: _des,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(labelText: 'About'),
                        minLines: 1, //Normal textInputField will be displayed
                        maxLines: 50, // when user presses enter it will adapt to it
                      ),
                      SizedBox(height: 10,),
                      Row(
                        children: [
                          Spacer(),
                          Text("Choose photo: "),
                          IconButton(onPressed: (){_pickImage(ImageSource.gallery);}, icon: Icon(Icons.image)),

                          Spacer()
                        ],
                      ),
                      if(image_path!=null)
                        Image.file(image_path),
                      SizedBox(height: 20,),
                      ElevatedButton(
                        onPressed: (){
                          if(_title.text.length<2){
                            setState(() {
                              error_msg = "Please add teacher name.";
                            });
                          }else if(_des.text.length<2){
                            setState(() {
                              error_msg = "Please add about teacher.";
                            });
                          }else if(image_path==null){
                            setState(() {
                              error_msg = "Please add teacher photo.";
                            });
                          }else{
                          addPost();}
                        },
                        child: Text('    Done      ',style: TextStyle(fontSize: 18),),
                      ),
                      SizedBox(height: 10,),
                      Text(error_msg,style: TextStyle(color: Colors.red),)
                    ],
                  )
              ))
      ),
    );
  }
}


class AdminResult extends StatefulWidget {
  static const routeName = '/adminresult';

  @override
  _AdminResult createState() => _AdminResult();
}
class _AdminResult extends State<AdminResult> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
   String points_int='';
  var subject_row=[];
  var total_marks=0;
  var student_result =[];
  var file_path;
  String error_msg='';
  TextEditingController _title = TextEditingController();
  List<StudentResult> student_data=[];
  void _loading_dialog() {

    showDialog(
      context: context,

      builder: (BuildContext context) {
        return
          WillPopScope(child:Dialog(
            elevation: 0,

            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
            backgroundColor: Colors.transparent,

            child: Column(

              mainAxisSize: MainAxisSize.min,

              children: <Widget>[
                Align(
                  alignment: Alignment.center,
                  child:LoadingAnimationWidget.hexagonDots(

                      size: 50,color: Color.fromRGBO(36, 150, 243, 1)
                  ),

                ),

              ],
            ),

          ) , onWillPop: ()=> Future.value(false));


      },
    );
  }

  Future<void> uploadStudentResults(List<StudentResult> results) async {
    _loading_dialog();
    log(results.toString());
   // try{
    Map<String, Map<String, dynamic>> resultsMap = {};
    for (int i = 0; i < results.length; i++) {
      resultsMap[_database.child('Results').push().key!] = results[i].toMap();
    }

    await _database.child('Results').update(resultsMap);
    Navigator.of(context).pop();
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Success!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
    // }catch(e){
    //   print(e);
    //   Navigator.of(context).pop();
    //   setState(() {
    //     error_msg = "Fail to upload result. try again";
    //   });
    // }
  }

  Future<void> pickAndReadXlsxFile() async {
     subject_row=[];
    total_marks=0;
     student_result =[];
    student_data=[];

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null) {
        setState(() {
          file_path= result.files.single.name;

        });

        File file = File(result.files.single.path!);
        RegExp regExpnumber = RegExp(r'\b\d{10}\b');

        // Read the file as bytes
        var bytes = file.readAsBytesSync();
        var decoder = SpreadsheetDecoder.decodeBytes(bytes);

        // Read data from the first sheet
        for (var table in decoder.tables.keys) {
          // print(table); // Sheet Name
          // print(decoder.tables[table]?.maxCols);
          // print(decoder.tables[table]?.maxRows);
          var header_row =[];

          for (var row in decoder.tables[table]!.rows) {
            //print('$row');
            bool containsTenDigitNumber = regExpnumber.hasMatch(row[0].toString());
            if(containsTenDigitNumber){
              break;
            }else{


              header_row = row;
            }
            //print(row[0]);

          }
          print(header_row);
          var to_marks = '';

          var ptc=0;
          for(var i in header_row){
            if(ptc==0 || ptc==1){

            }else{
              bool add_a= false;
              for(var p=0; p<i.length; p++){
                //print(i[p]);

                if(i[p]==")"){
                  add_a =false;
                  break;
                }
                if(add_a){
                  to_marks=to_marks+i[p];
                }
                if(i[p]=="("){
                  add_a =true;
                }
              }
              break;
            }
            ptc+=1;

          }
          total_marks = int.parse(to_marks);
          print(total_marks);

          var exe = 0;
          for(var i in header_row){
            if(exe==0 || exe==1){

            }else{
              var pin ='';
              for(var p=0; p<i.length; p++){
                //print(i[p]);
                if(i[p]=="("){
                  break;
                }
                pin = pin+ i[p];
              }
              subject_row.add(pin);
            }
            exe+=1;
          }

          print(subject_row);
          for (var row in decoder.tables[table]!.rows){
            bool containsTenDigitNumber = regExpnumber.hasMatch(row[0].toString());
            if(containsTenDigitNumber){
             student_result.add(row);
            }
          }

          break;
        }

      } else {
        // User canceled the picker
        print('User canceled the picker');
      }
    } catch (e) {
      print('Error reading Excel file: $e');
    }
    print(student_result);
    for(var i in student_result){
      var obtain_m = 0;
      var test_t=0;
      for(var p in i){
        if(test_t==0 || test_t==1){

        }
        else{
          obtain_m=obtain_m+ int.parse(p.toString());
        }
        test_t=test_t+1;
      }
      var t_m = subject_row.length*total_marks;
      var percent = 100*obtain_m/t_m;
      String formattedNumber = percent.toStringAsFixed(2);

      var sub_mark=[];
      var i_e = 0;
      for(var p in i){
        if(i_e==0 || i_e==1){

        }else{
          sub_mark.add(p);
        }
        i_e=i_e+1;
      }

      var sub_data={};
      for(var k=0; k<subject_row.length;k++){
        sub_data[subject_row[k]]=sub_mark[k];
      }


      student_data.add(StudentResult
        (
          name: i[1],
          number: i[0],
          obtainMarks: obtain_m, totalMarks: t_m,
          percentage: formattedNumber,
          subject: sub_data,
          rank: 0,
          std: points_int,
          title: _title.text,
          date:  DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString()
      ));
    }
     student_data.sort((a, b) => b.obtainMarks.compareTo(a.obtainMarks));
     // Assign ranks
     // Assign ranks
     int o_m =0;
     int currentRank = 1;

      for(var j=0;j<student_data.length;j++){

       if(o_m!=0){
         if(o_m==student_data[j].obtainMarks){
           student_data[j].rank=currentRank;
         }else{
           currentRank++;
           student_data[j].rank=currentRank;
           o_m = student_data[j].obtainMarks;
         }

       }else{
         o_m = student_data[j].obtainMarks;
         student_data[j].rank=currentRank;
       }

      }


     log(student_data.toString());
  }
  @override
  void initState() {
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    List<String> numbers = ['1','2','3','4','5','6','7','8','9','10','11 આર્ટસ','12 આર્ટસ','11 કૉમર્સ','12 કૉમર્સ'];

    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          title: Text('Upload Result',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold,color: Colors.black),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.black,size: 28,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(24.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Result:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                    SizedBox(height: 20,),
                    TextField(
                      controller: _title,
                      decoration: InputDecoration(labelText: 'Title'),

                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        DropdownButton<String>(
                          hint: Text('Select Standard'),
                          //value: points_int.toString(), // Initially no value selected
                          onChanged: (String? newValue) {
                            print(newValue);
                            setState(() {
                              points_int=newValue.toString();

                            });
                            // Add your code to handle the selected value
                          },
                          items: numbers.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                        Text("  "+points_int,style: TextStyle(fontWeight: FontWeight.bold),)

                      ],
                    ),
                    SizedBox(height: 30,),
                    Row(
                      children: [
                        IconButton(onPressed: (){
                          if(_title.text.length<2 || points_int==''){
                            setState(() {
                              error_msg = "Please add title and standard first.";
                            });
                          }else{
                          pickAndReadXlsxFile();}

                        }, icon: Icon(Icons.file_upload_sharp)),
                        TextButton(onPressed: (){
                          if(_title.text.length<2 || points_int==''){
                            setState(() {
                              error_msg = "Please add title and standard first.";
                            });
                          }else{
                            pickAndReadXlsxFile();}
                        }, child: Text("Choose File",style: TextStyle(color: Colors.black),)),


                      ],
                    ),
                    if(file_path!=null)
                      Text("      "+file_path,style: TextStyle(color: Colors.blue),),

                    SizedBox(height: 20,),
                    ElevatedButton(onPressed: (){
                      if(_title.text.length<2){
                        setState(() {
                          error_msg = "Please add title";
                        });
                      }else if(points_int==''){
                        setState(() {
                          error_msg="Please select standard.";
                        });
                      }else if(file_path==null){
                        setState(() {
                          error_msg = "Please select excel result file.";
                        });
                      }else{
                        uploadStudentResults(student_data);

                      }
                    }, child: Text("Upload")),
                    SizedBox(height: 10,),
                    Text(error_msg,style: TextStyle(color: Colors.red),)
                    ],
                )
            ))

    );
  }
}


class ListItem {
  final String title;
  final String text_large;
  final String image;
  final String time;
  final String id;
  ListItem({
    required this.title,
    required this.text_large,
    required this.image,
    required this.time,
    required this.id
  });
}

