# Project 1: COBOL Database Connectivity  

Welcome to your first COBOL database project!  
The goal of this assignment is to master the fundamentals of a professional development environment.  
You will learn to compile and run a COBOL program that connects to a modern PostgreSQL database, reads data, and handles errors gracefully.  

This project uses a "C Wrapper" method. This is a professional technique where a small C program acts as a bridge between our COBOL business logic and the low-level database drivers.  
This allows you, the COBOL developer, to focus 100% on writing COBOL and SQL.  

---

## 1. Environment Setup & Installation  

Before you can begin, you must set up your development environment.  
Follow these steps precisely in your WSL or Linux terminal.  

### Step 1: Install Required Tools  

This single command installs the COBOL compiler, C++ compiler, PostgreSQL, and all necessary libraries and tools.  

```bash
sudo apt-get update && sudo apt-get install -y gnucobol g++ libpq-dev postgresql postgresql-contrib make
```

---

### Step 2: Configure PostgreSQL  

These commands set a standard password for the main database user and change the security rules to allow your program to connect.  

**Set the password for the postgres user:**  

```bash
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';"
```

**Fix Local Authentication (Critical Step):** This allows your COBOL program to log in with a password.  

```bash
# Find your pg_hba.conf file
CONF_FILE=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file;')
# Back it up, then change 'peer' to 'md5' to enable password login
sudo cp $CONF_FILE ${CONF_FILE}.bak
sudo sed -i 's/^\(local\s\+all\s\+postgres\s\+\)peer/\1md5/' $CONF_FILE
sudo sed -i 's/^\(local\s\+all\s\+all\s\+\)peer/\1md5/' $CONF_FILE
# Reload PostgreSQL to apply the changes
sudo systemctl reload postgresql
```

---

## 2. Project Setup & Verification  

Now that the tools are installed, you need to load the project's database schema and verify that your environment is working correctly.  

### Step 1: Create and Seed Your Database  

Navigate to your project folder in the terminal and run the following command.  
This will create the `schooldb` database and load it with the necessary tables and sample data.  

```bash
make db-setup
```

---

### Step 2: Verify Your Setup with a Smoke Test  

This is the most important step.  
It proves that your entire environment—the compiler, the C wrapper, and the database connection—is working perfectly.  

```bash
make smoke-test
```

**Expected Output:**  

```bash
--- Running Environment Smoke Test ---
SMOKE TEST PASSED: Connection successful.
--- Smoke Test Complete ---
```

If you see this message, your setup is perfect.  
You are ready to begin the project tasks.  
If it fails, carefully review the installation steps above.  

---

## The Magic of the Makefile: How Your Code is Built  

You might be wondering, "When did the C wrapper get compiled?"  
The answer is that the Makefile did it for you automatically.  

The Makefile is a smart script that understands dependencies.  
It knows that:  

- Your COBOL program (e.g., `smoke.cob`) needs the C "engine" (`libpgcob.so`) to work.  
- The C engine (`libpgcob.so`) needs the C source code (`db-wrapper.c`) to be built.  

So, when you ran `make smoke-test`, the Makefile automatically performed the following steps in order:  

1. It saw that `libpgcob.so` did not exist, so it ran the `g++` command to compile `db-wrapper.c` first.  
2. Then, it saw that `build/smoke` did not exist, so it ran the `cobc` command to compile `src/smoke.cob` and link it to the newly created library.  
3. Finally, it ran the `./build/smoke` executable.  

This is the power of a professional build system.  
You never have to compile the C code manually.  
The Makefile handles all the dependencies for you.  

---

## 3. Your Assignment & Workflow  

Your assignment is to complete the four COBOL programs located in the `src/` directory.  
Before you begin, you must read the two concept pages in your project to understand the API and the essential coding rules. 
---

### How to Work on a Task  

**Write Your Code**  
Open the corresponding `.cob` file in the `src/` directory (e.g., `src/1-read-balances.cob`) and write your solution.  

**Compile and Run Your Task**  
To test your code for Task 1, run:  

```bash
make run-1
```
---

You are now ready to begin working on your project. ✨Good luck! 





