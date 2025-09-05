# Project 3: COBOL Transaction Validation  

Welcome to your final project!  
In the previous assignments, you mastered reading and modifying data.  
Now, you will learn the most critical skill for a financial software developer: implementing business logic and data validation.  

This project puts you in the role of the guardian of the bank's business rules.  
Your mission is to build a suite of COBOL programs that validate high-risk withdrawals, create secure audit trails using database stored procedures, and handle entire batches of transactions with guaranteed integrity.  

---

## 1. Environment Setup  

Before you can begin, you must have a correctly configured development environment.  
The setup is identical to the previous projects.  

### Step 1: Install Required Tools  

If you are on a new machine, run this single command to install the COBOL compiler, C++ compiler, PostgreSQL, and all necessary libraries and tools.  

<pre>
sudo apt-get update && sudo apt-get install -y gnucobol g++ libpq-dev postgresql postgresql-contrib make
</pre>  

### Step 2: Configure PostgreSQL  

These commands set a standard password for the main database user and change the security rules to allow your program to connect.  

**Set the password for the postgres user:**  

<pre>
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
</pre>  

**Fix Local Authentication (Critical Step):** This allows your COBOL program to log in with a password.  

<pre>
CONF_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')
sudo cp $CONF_FILE ${CONF_FILE}.bak
sudo sed -i 's/^\(local\s\+all\s\+postgres\s\+\)peer/\1md5/' $CONF_FILE
sudo sed -i 's/^\(local\s\+all\s\+all\s\+\)peer/\1md5/' $CONF_FILE
sudo systemctl reload postgresql
</pre>  

---

## 2. Project Setup & Verification  

Now that the tools are installed, you need to load the project's database schema and verify that your environment is working correctly.  

### Step 1: Create and Seed Your Database  

Navigate to your project folder in the terminal and run the following command.  
This will create the `schooldb` database and load it with the necessary tables and sample data.  

<pre>
make db-setup
</pre>  

### Step 2: Load the Stored Procedure  

This is a new step for Project 3.  
This command will load a special function called `LOG_TRANSACTION` directly into your database.  
This function will be used in a later task to create a secure audit trail.  

<pre>
make load-proc
</pre>  

**Expected Output:**  

<pre>
Loading stored procedure...
CREATE PROCEDURE
GRANT
✅ Stored procedure loaded.
</pre>  

### Step 3: Verify Your Setup with a Smoke Test  

This is the most important step.  
It proves that your entire environment is working perfectly before you start coding.  

<pre>
make smoke-test
</pre>  

**Expected Output:**  

<pre>
--- Running Environment Smoke Test ---
SMOKE TEST PASSED: Connection successful.
--- Smoke Test Complete ---
</pre>  

If you see this message, your setup is perfect. You are ready to begin the project tasks.  

---

## 3. Your Assignment & Workflow  

Your assignment is to complete the COBOL programs located in the `src/` directory.  
Before you begin, you must review the two concept pages to understand the API and the essential coding rules.  

- `CONCEPTS-1-Architecture.md`: Your high-level guide to the project architecture.  
- `CONCEPTS-2-Developers-Guide.md`: Your practical, hands-on manual with the API reference and rules.  

---

### How to Work on a Task  

**Write Your Code**  
Open the corresponding `.cob` file in the `src/` directory (e.g., `src/1-validate-withdrawal.cob`) and write your solution.  

**Compile and Run Your Task**  
To test your code for Task 1, run:  

<pre>
make run-1
</pre>  

The Makefile will automatically recompile your file only if it has changed, then run the program.  
Use `make run-2` for Task 2, `make run-3` for Task 3, and so on.  

---

### Reset the Database (Important!)  

Since every task in this project modifies the database, it is a critical professional habit to always reset the database before every test run.  
This guarantees that you are testing your code against a clean, predictable set of data.  

**Example workflow for Task 1:**  

<pre>
# First, reset the database
make db-setup

# Then, run your test
make run-1
</pre>  
