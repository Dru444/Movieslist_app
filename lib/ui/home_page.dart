import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/movie_helper.dart';
import 'movie_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MovieHelper helper = MovieHelper();
  List<Movie> movies = [];


  @override
  void initState() {
    super.initState();
    _getAllMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movie List'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        // centerTitle: true,

      ),
      backgroundColor: Colors.blueGrey.shade900,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          _showMoviePage();
        },
        child: Icon(Icons.add),

      ),
      body:Center(
        child: movies.isEmpty
            ? Text(
          'No Movies',
          style: TextStyle(color: Colors.white, fontSize: 24),
        )
            : ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: movies.length,
            itemBuilder: _movieCard
        ),
      ),


    );
  }
  final _lightColors = [
    Colors.amber.shade300,
    Colors.lightGreen.shade300,
    Colors.lightBlue.shade300,
    Colors.orange.shade300,
    Colors.pinkAccent.shade100,
    Colors.tealAccent.shade100
  ];

  Widget _movieCard(BuildContext context, int index) {
    final color = _lightColors[index % _lightColors.length];
    return GestureDetector(
      child: Card(
        color: color,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 100.0,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  image: DecorationImage(
                    image: movies[index].img != null
                      ? FileImage(File(movies[index].img))
                      : AssetImage('assets/images/poster.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      movies[index].name ?? '',
                      style: TextStyle(
                        fontSize: 24.0, fontWeight: FontWeight.bold)),
                    Text('Director : '+
                      movies[index].director ?? '',
                      style: TextStyle(fontSize: 18.0)),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(

          onClosing: () {},
          builder: (context) {
            return Container(
              color: Colors.blueGrey.shade800,

              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text(
                        'Edit',
                        style: TextStyle(color: Colors.blue, fontSize: 20.0),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showMoviePage(movie: movies[index]);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red, fontSize: 20.0),
                      ),
                      onPressed: () {
                        helper.deleteMovie(movies[index].id);
                        setState(() {
                          movies.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMoviePage({Movie movie}) async {
    final recMovie = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MoviePage(movie: movie)));
    if (recMovie != null) {
      if (movie != null) {
        await helper.updateMovie(recMovie);
      } else {
        await helper.saveMovie(recMovie);
      }
      _getAllMovies();
    }
  }

  void _getAllMovies() {

    helper.getAllMovies().then((list) {
      setState(() {
        movies = list;

      });
    });
  }

  }