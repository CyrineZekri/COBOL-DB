📘 Installation & Requirements

Welcome! Before starting the COBOL + PostgreSQL projects, you need to set up your environment.
Follow these steps carefully — once complete, you’ll be ready to compile COBOL programs, connect to PostgreSQL, and run the tasks.

1. Install Required Tools 

sudo apt-get update
sudo apt-get install -y gnucobol gcc libpq-dev postgresql postgresql-contrib make

2. Configure PostgreSQL
we’ll use a shared default password so that every student work with the same setup.

⚠️ Security Note:

In real-world projects, you would never hardcode or reuse passwords like this.
Proper security practice is to create unique DB users per application, use strong passwords, and never commit them to a repo.
Here, we deliberately use postgres/postgres because this is a local, isolated learning environment and consistency is more important than security.

Set the password for the postgres user: 
<pre>
sudo -H -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
</pre>
once you’ve successfully set the password, test the login:
<pre>
PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -d postgres -c "SELECT 1;"
</pre>
you should see : 
 ?column? 
----------
        1
(1 row)
Create the course database:

PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -c "CREATE DATABASE schooldb;"

Verify your connection:
PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -d schooldb -c "SELECT 1;"
If you see 1, the connection works.

PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -c "CREATE DATABASE schooldb;" || true

Seed the Database
<pre>
DB_PASSWORD=postgres ./reset_db.sh
</pre>
This loads the schema and sample data from bootstrap.sql.
Check that tables exist:
<pre>
PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -d schooldb -c "\dt"

</pre>

3. Build the wrapper (if you intend to ship the .c as part of the skeleton)
<pre>
gcc -shared -fPIC -o lib/libpgcob.so db_wrapper.c -I/usr/include/postgresql -lpq
ls -l lib/libpgcob.so
</pre>
lib/libpgcob.so