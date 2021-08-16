import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/movie_helper.dart';

class MoviePage extends StatefulWidget {
  final Movie movie;
  MoviePage({this.movie});

  @override
  _MoviePageState createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final _nameController  = TextEditingController();
  final _dirController = TextEditingController();
  final _nameFocus = FocusNode();
  final _dirFocus = FocusNode();

  bool _userEdited = false;
  Movie _editedMovie;

  @override
  void initState() {
    super.initState();
    if (widget.movie == null) {
      _editedMovie = Movie();
    } else {
      _editedMovie = Movie.fromMap(widget.movie.toMap());
    }

    _nameController.text  = _editedMovie.name;
    _dirController.text = _editedMovie.director;
    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: Colors.blueGrey.shade900,
        appBar: AppBar(
          title: Text('Movie'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true
        ),
        floatingActionButton: FloatingActionButton(

          onPressed: () {
            if (_editedMovie.name != null && _editedMovie.director != null && _editedMovie.name.isNotEmpty && _editedMovie.director.isNotEmpty) {
              Navigator.pop(context, _editedMovie);
            } if(_editedMovie.director == null || _editedMovie.director.isEmpty ) {
              FocusScope.of(context).requestFocus(_dirFocus);
            }
            if(_editedMovie.name == null || _editedMovie.name.isEmpty ) {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.lightGreen,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    image: DecorationImage(
                      image: _editedMovie.img != null
                        ? FileImage(File(_editedMovie.img))
                        : AssetImage('assets/images/poster.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: () async {
                  await ImagePicker()
                    .getImage(source: ImageSource.gallery)
                    .then((file) {
                  if (file == null) return;
                    setState(() {
                      _editedMovie.img = file.path;
                    });
                  });
                },
              ),

              SizedBox(height: 40),
              TextField(
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.white38, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.white70, width: 2),
                    ),
                    labelText: 'Movie Name',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedMovie.name = text;
                  });
                },
              ),

              SizedBox(height: 20),

              TextField(
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                controller: _dirController,
                focusNode: _dirFocus,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.white38, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.white70, width: 2),
                    ),
                    labelText: 'Movie Director',
                    labelStyle: TextStyle(color: Colors.white)),
                onChanged: (text) {
                  _userEdited = true;
                  _editedMovie.director = text;
                },

              ),

            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Discard changes?'),
            content: Text('If you exit, your changes will be lost.'),
            actions: <Widget>[
              TextButton(
                child: Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      );
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
