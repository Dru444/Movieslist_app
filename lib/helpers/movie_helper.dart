import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

final String movieTable = 'movieTable';
final String idColumn = 'idColumn';
final String nameColumn = 'nameColumn';
final String directorColumn = 'directorColumn';
final String imgColumn = 'imgColumn';

class MovieHelper {

  static final MovieHelper _instance = MovieHelper.internal();
  factory MovieHelper() => _instance;
  MovieHelper.internal();
  Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = p.join(databasesPath, 'movies.db');
    return await openDatabase(path, version: 1,
        onCreate: (db, newerVersion) async {
      await db.execute(
        'CREATE TABLE $movieTable('
          '$idColumn INTEGER PRIMARY KEY,'
          '$nameColumn TEXT,'
          '$directorColumn TEXT,'           
          '$imgColumn TEXT)'
      );
    });
  }

  Future<Movie> saveMovie(Movie movie) async {
    var dbMovie = await db;
    movie.id = await dbMovie.insert(movieTable, movie.toMap());
    return movie;
  }

  Future<Movie> getMovie(int id) async {
    var dbMovie = await db;
    List<Map> maps = await dbMovie.query(movieTable,
      columns: [idColumn, nameColumn, directorColumn,imgColumn],
      where: '$idColumn = ?',
      whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Movie.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> deleteMovie(int id) async {
    var dbMovie = await db;
    return await dbMovie
      .delete(movieTable, where: '$idColumn = ?', whereArgs: [id]);
  }

  Future<int> updateMovie(Movie movie) async {
    var dbMovie = await db;
    return await dbMovie.update(movieTable, movie.toMap(),
      where: '$idColumn = ?', whereArgs: [movie.id]);
  }

  Future<List> getAllMovies() async {
    var dbMovie = await db;
    List listMap = await dbMovie.rawQuery('SELECT * FROM $movieTable');
    var listMovie = <Movie>[];
    for (Map m in listMap) {
      listMovie.add(Movie.fromMap(m));
    }
    return listMovie;
  }

  Future<int> getNumber() async {
    var dbMovie = await db;
    return Sqflite.firstIntValue(
      await dbMovie.rawQuery('SELECT COUNT(*) FROM $movieTable'));
  }

  Future close() async {
    var dbMovie = await db;
    dbMovie.close();
  }
}

class Movie {
  int id;
  String name;
  String director;
  String img;

  Movie();

  Movie.fromMap(Map map) {
    id    = map[idColumn];
    name  = map[nameColumn];
    director = map[directorColumn];
    img   = map[imgColumn];
  }

  Map toMap() {
    var map = <String, dynamic>{
      nameColumn: name,
      directorColumn: director,
      imgColumn: img
    };
    if (id != null) {
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return 'Movie('
    'id: $id,' 
    'name: $name, '
    'director: $director, '
    'img: $img)';
  }
}