part of 'sqlite_data_source.dart';

final class SampleDataSource extends SqliteDataSource {
  SampleDataSource(super.config, {required super.database}) : super._();

  static final Logger _logger = Logger('SampleDataSource');

  /// Connect to an existing SQLite database from the database pool.
  static Future<SampleDataSource> connect({
    required DatabasePool dbPool,
    required DataSourceConfig config,
  }) async {
    assert(config.type == DataSourceType.sample);

    final db = await dbPool.open('sample.db');
    final dataSource = SampleDataSource(config, database: db);
    await dataSource._createSampleSchema();
    await dataSource._initialize();
    return dataSource;
  }

  /// Create sample schema with demo data for testing purposes
  Future<void> _createSampleSchema() async {
    _logger.finest('Creating sample schema with demo data');

    try {
      // Create a sample movies table with various data types
      await _database!.execute('''
        CREATE TABLE IF NOT EXISTS movies (
          id INTEGER PRIMARY KEY,
          title TEXT NOT NULL,
          release_year INTEGER,
          rating REAL,
          is_favorite BOOLEAN DEFAULT FALSE,
          release_date DATE,
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
          description TEXT,
          revenue INTEGER
        )
        ''');

      // Insert sample data with proper parameter binding
      final sampleMovies = [
        {
          'id': 1,
          'title': 'The Shawshank Redemption',
          'release_year': 1994,
          'rating': 9.3,
          'is_favorite': 1,
          'release_date': '1994-09-23',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
          'revenue': 16000000,
        },
        {
          'id': 2,
          'title': 'The Godfather',
          'release_year': 1972,
          'rating': 9.2,
          'is_favorite': 1,
          'release_date': '1972-03-24',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
          'revenue': 246120974,
        },
        {
          'id': 3,
          'title': 'The Dark Knight',
          'release_year': 2008,
          'rating': 9.0,
          'is_favorite': 1,
          'release_date': '2008-07-18',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.',
          'revenue': 1004558444,
        },
        {
          'id': 4,
          'title': 'Pulp Fiction',
          'release_year': 1994,
          'rating': 8.9,
          'is_favorite': 0,
          'release_date': '1994-10-14',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
          'revenue': 214179088,
        },
        {
          'id': 5,
          'title': 'Schindler\'s List',
          'release_year': 1993,
          'rating': 8.9,
          'is_favorite': 1,
          'release_date': '1993-12-15',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'In German-occupied Poland during World War II, industrialist Oskar Schindler gradually becomes concerned for his Jewish workforce.',
          'revenue': 322161405,
        },
        {
          'id': 6,
          'title': 'Inception',
          'release_year': 2010,
          'rating': 8.8,
          'is_favorite': 0,
          'release_date': '2010-07-16',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea.',
          'revenue': 836836967,
        },
        {
          'id': 7,
          'title': 'Fight Club',
          'release_year': 1999,
          'rating': 8.8,
          'is_favorite': 0,
          'release_date': '1999-10-15',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'An insomniac office worker and a devil-may-care soap maker form an underground fight club.',
          'revenue': 100853753,
        },
        {
          'id': 8,
          'title': 'Forrest Gump',
          'release_year': 1994,
          'rating': 8.8,
          'is_favorite': 1,
          'release_date': '1994-07-06',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The presidencies of Kennedy and Johnson, the Vietnam War, and other historical events unfold from the perspective of an Alabama man.',
          'revenue': 677387716,
        },
        {
          'id': 9,
          'title': 'The Matrix',
          'release_year': 1999,
          'rating': 8.7,
          'is_favorite': 1,
          'release_date': '1999-03-31',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'When a beautiful stranger leads computer hacker Neo to a forbidding underworld, he discovers the shocking truth.',
          'revenue': 467222824,
        },
        {
          'id': 10,
          'title': 'Goodfellas',
          'release_year': 1990,
          'rating': 8.7,
          'is_favorite': 0,
          'release_date': '1990-09-21',
          'created_at': '2024-01-01 12:00:00',
          'description':
              'The story of Henry Hill and his life in the mob, covering his relationship with his wife Karen Hill and his mob partners.',
          'revenue': 46836394,
        },
      ];

      for (final movie in sampleMovies) {
        await _database!.execute(
          'INSERT OR REPLACE INTO movies (id, title, release_year, rating, is_favorite, release_date, created_at, description, revenue) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            movie['id'],
            movie['title'],
            movie['release_year'],
            movie['rating'],
            movie['is_favorite'],
            movie['release_date'],
            movie['created_at'],
            movie['description'],
            movie['revenue'],
          ],
        );
      }

      _logger.info('Sample schema created with ${sampleMovies.length} movies');
    } catch (e) {
      _logger.severe('Failed to create sample schema', e);
      throw DataSourceException(
        'Failed to create sample schema: ${e.toString()}',
        sourceType: type,
        cause: e,
      );
    }
  }
}
