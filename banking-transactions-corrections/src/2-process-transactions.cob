IDENTIFICATION DIVISION.
       PROGRAM-ID. process-transactions.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TX-FILE ASSIGN TO "transactions.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS TX-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  TX-FILE.
       01  TX-RECORD            PIC X(200).
       WORKING-STORAGE SECTION.
       COPY "dbapi.cpy".
       01  CONN-LIT PIC X(200)
           VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  L PIC 9(4) VALUE 0.
       01  TX-FILE-STATUS PIC XX.
       01  TX-DATA.
           05 TX-ACTION         PIC X(8).
           05 TX-ID             PIC X(4).
           05 TX-NAME-OR-TYPE   PIC X(20).
           05 TX-ACCOUNT        PIC X(4).
           05 TX-AMOUNT         PIC X(10).

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).

           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.

           OPEN INPUT TX-FILE.
           IF TX-FILE-STATUS NOT = "00" THEN
               DISPLAY "ERROR: Could not open transactions.dat"
               CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC
               STOP RUN
           END-IF.

           PERFORM PROCESS-RECORDS UNTIL TX-FILE-STATUS NOT = "00".

           CLOSE TX-FILE.
           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.

       PROCESS-RECORDS.
           READ TX-FILE AT END SET TX-FILE-STATUS TO "10".
           IF TX-FILE-STATUS = "00" THEN
               UNSTRING TX-RECORD DELIMITED BY ","
                   INTO TX-ACTION, TX-ID, TX-NAME-OR-TYPE,
                        TX-ACCOUNT, TX-AMOUNT
               EVALUATE FUNCTION UPPER-CASE(FUNCTION TRIM(TX-ACTION))
                   WHEN "INSERT"
                       PERFORM HANDLE-INSERT
                   WHEN "UPDATE"
                       PERFORM HANDLE-UPDATE
               END-EVALUATE
           END-IF.

       HANDLE-INSERT.
           MOVE SPACES TO SQL-COMMAND.
           STRING "INSERT INTO customers (customer_id, name) VALUES ("
               FUNCTION TRIM(TX-ID) ", '" FUNCTION TRIM(TX-NAME-OR-TYPE) "');"
               DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC" USING BY VALUE DBH, BY REFERENCE SQL-COMMAND RETURNING RC.
           IF RC = 0 THEN
               DISPLAY "Processed INSERT for " FUNCTION TRIM(TX-NAME-OR-TYPE)
           END-IF.

           MOVE SPACES TO SQL-COMMAND.
           STRING "INSERT INTO accounts (account_id, customer_id, balance) VALUES ("
               FUNCTION TRIM(TX-ACCOUNT) ", " FUNCTION TRIM(TX-ID) ", "
               FUNCTION TRIM(TX-AMOUNT) ");"
               DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC" USING BY VALUE DBH, BY REFERENCE SQL-COMMAND RETURNING RC.

       HANDLE-UPDATE.
           MOVE SPACES TO SQL-COMMAND.
           IF FUNCTION UPPER-CASE(FUNCTION TRIM(TX-NAME-OR-TYPE)) = "DEPOSIT" THEN
               STRING "UPDATE accounts SET balance = balance + "
                   FUNCTION TRIM(TX-AMOUNT) " WHERE account_id = "
                   FUNCTION TRIM(TX-ID) ";"
                   DELIMITED BY SIZE INTO SQL-COMMAND
           ELSE
               STRING "UPDATE accounts SET balance = balance - "
                   FUNCTION TRIM(TX-AMOUNT) " WHERE account_id = "
                   FUNCTION TRIM(TX-ID) ";"
                   DELIMITED BY SIZE INTO SQL-COMMAND
           END-IF.
           CALL STATIC "DB_EXEC" USING BY VALUE DBH, BY REFERENCE SQL-COMMAND RETURNING RC.
           IF RC = 0 THEN
               DISPLAY "Processed " FUNCTION TRIM(TX-NAME-OR-TYPE)
                       " for account " FUNCTION TRIM(TX-ID)
           END-IF.
           