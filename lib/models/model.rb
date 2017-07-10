ActiveRecord::Base.establish_connection(
    adapter:  'mysql2', # or 'postgresql' or 'sqlite3' or 'oracle_enhanced'
    host:     'localhost',
    database: 'pdm-reverse',
    username: 'your_username',
    password: 'your_password',
    collation: 'utf8mb4_unicode_ci'
)