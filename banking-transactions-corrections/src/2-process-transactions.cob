# Project 2: COBOL Banking Transactions

Welcome to your second project! In this assignment, you will build a suite of COBOL programs to simulate a realistic, end-of-day batch processing job for a bank.  
You will move beyond simply reading data and will learn to master the full spectrum of CRUD (Create, Read, Update, Delete) operations.  

This project is your first step into writing COBOL that modifies a modern database — a critical skill for any enterprise developer.  

---

## Prerequisites & Setup  

Before you can begin the tasks, you must set up and verify your development environment. Follow these steps precisely.  

### Step 1: Install Required Tools  
Open a terminal and run the following command to install the GnuCOBOL compiler, the C++ compiler, the PostgreSQL database, and other essential build tools:  

<pre>
sudo apt-get update && sudo apt-get install -y gnucobol g++ libpq-dev postgresql postgresql-contrib make
</pre>  

### Step 2: Configure the PostgreSQL Database  
These commands will create a dedicated database for your project (`schooldb`) and set a standard password (`postgres`) for the main database user.  

Set the password for the `postgres` user:  

<pre>
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
</pre>  

Fix Local Authentication (critical step):  

<pre>
# Find your pg_hba.conf file
CONF_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')

# Back it up, then change 'peer' to 'md5' to enable password login
sudo cp $CONF_FILE ${CONF_FILE}.bak
sudo sed -i 's/^\(local\s\+all\s\+all\s\+\)peer/\1md5/' $CONF_FILE

# Reload PostgreSQL to apply the changes
sudo systemctl reload postgresql
</pre>  

### Step 3: Create and Seed Your Database  
Run the following command from the project root to create the `schooldb` database and load it with the necessary tables and sample data:  

<pre>
make db-setup
</pre>  

**Expected Output:**  
You should see a series of database commands (`DROP TABLE`, `CREATE TABLE`, `INSERT`, etc.), followed by:  

<pre>
BOOTSTRAP OK
</pre>  

### Step 4: Verify Your Setup with a Smoke Test  
Run the smoke test command to verify your environment (compiler, C wrapper, linker, and DB connection):  

<pre>
make smoke-test
</pre>  

**Expected Output:**  

<pre>
--- Running Environment Smoke Test ---
SMOKE TEST PASSED: Connection successful.
--- Smoke Test Complete ---
</pre>  

If you see this message, your setup is correct. If not, carefully review the installation steps above.  

---

## Project Tasks & Workflow  

Your assignment is to complete the five COBOL programs located in the `src/` directory. Each task is described in detail on the project page.  

### How to Work on a Task  

1. **Write Your Code**  
   Open the corresponding `.cob` file in the `src/` directory (e.g., `src/1-initial-report.cob`) and write your solution.  

2. **Compile and Run Your Task**  
   To test your code for Task 1, run:  
   <pre>
   make run-1
   </pre>  

   The Makefile will automatically recompile your file if it has changed, then run the program.  
   Use `make run-2` for Task 2, `make run-3` for Task 3, and so on.  

3. **Reset the Database (Important)**  
   Since some tasks modify the database, always reset it before testing a task that writes or deletes data:  

   <pre>
   make db-setup
   </pre>  

---

# Project 2: COBOL Banking Transactions

Welcome to your second project! In this assignment, you will build a suite of COBOL programs to simulate a realistic, end-of-day batch processing job for a bank.  
You will move beyond simply reading data and will learn to master the full spectrum of CRUD (Create, Read, Update, Delete) operations.  

This project is your first step into writing COBOL that modifies a modern database — a critical skill for any enterprise developer.  

---

## Prerequisites & Setup  

Before you can begin the tasks, you must set up and verify your development environment. Follow these steps precisely.  

### Step 1: Install Required Tools  
Open a terminal and run the following command to install the GnuCOBOL compiler, the C++ compiler, the PostgreSQL database, and other essential build tools:  

```bash
sudo apt-get update && sudo apt-get install -y gnucobol g++ libpq-dev postgresql postgresql-contrib make
```  

### Step 2: Configure the PostgreSQL Database  
These commands will create a dedicated database for your project (`schooldb`) and set a standard password (`postgres`) for the main database user.  

Set the password for the `postgres` user:  

```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```  

Fix Local Authentication (critical step):  

```bash
# Find your pg_hba.conf file
CONF_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')

# Back it up, then change 'peer' to 'md5' to enable password login
sudo cp $CONF_FILE ${CONF_FILE}.bak
sudo sed -i 's/^\(local\s\+all\s\+all\s\+\)peer/\1md5/' $CONF_FILE

# Reload PostgreSQL to apply the changes
sudo systemctl reload postgresql
```  

### Step 3: Create and Seed Your Database  
Run the following command from the project root to create the `schooldb` database and load it with the necessary tables and sample data:  

```bash
make db-setup
```  

**Expected Output:**  
You should see a series of database commands (`DROP TABLE`, `CREATE TABLE`, `INSERT`, etc.), followed by:  

```bash
BOOTSTRAP OK
```  

### Step 4: Verify Your Setup with a Smoke Test  
Run the smoke test command to verify your environment (compiler, C wrapper, linker, and DB connection):  

```bash
make smoke-test
```  

**Expected Output:**  

```bash
--- Running Environment Smoke Test ---
SMOKE TEST PASSED: Connection successful.
--- Smoke Test Complete ---
```  

If you see this message, your setup is correct. If not, carefully review the installation steps above.  

---

## Project Tasks & Workflow  

Your assignment is to complete the five COBOL programs located in the `src/` directory. Each task is described in detail on the project page.  

### How to Work on a Task  

1. **Write Your Code**  
   Open the corresponding `.cob` file in the `src/` directory (e.g., `src/1-initial-report.cob`) and write your solution.  

2. **Compile and Run Your Task**  
   To test your code for Task 1, run:  
   ```bash
   make run-1
   ```  

   The Makefile will automatically recompile your file if it has changed, then run the program.  
   Use `make run-2` for Task 2, `make run-3` for Task 3, and so on.  

3. **Reset the Database (Important)**  
   Since some tasks modify the database, always reset it before testing a task that writes or deletes data:  

   ```bash
   make db-setup
   ```  

---

You are now ready to begin the project tasks. ✨ Good Luck!  































