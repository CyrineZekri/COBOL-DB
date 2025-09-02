IDENTIFICATION DIVISION.
       PROGRAM-ID. close-accounts.
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
           05 TX-ACTION         PIC X(6).
           05 TX-ID             PIC X(4).
       01  CURRENT-BALANCE      PIC S9(8)V99.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).

           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.

           OPEN INPUT TX-FILE.
           PERFORM PROCESS-CLOSURES UNTIL TX-FILE-STATUS NOT = "00".
           CLOSE TX-FILE.

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.

       PROCESS-CLOSURES.
           READ TX-FILE AT END SET TX-FILE-STATUS TO "10".
           IF TX-FILE-STATUS = "00" THEN
               UNSTRING TX-RECORD DELIMITED BY ","
                   INTO TX-ACTION, TX-ID
               IF FUNCTION UPPER-CASE(FUNCTION TRIM(TX-ACTION)) = "CLOSE"
                   PERFORM HANDLE-CLOSE
               END-IF
           END-IF.

       HANDLE-CLOSE.
           MOVE SPACES TO SQL-COMMAND.
           STRING "SELECT balance FROM accounts WHERE customer_id = "
               FUNCTION TRIM(TX-ID) ";" DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_QUERY_SINGLE"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND,
                     BY REFERENCE SINGLE-RESULT-BUFFER
               RETURNING RC.

           IF RC = 0 THEN
               MOVE FUNCTION NUMVAL(SINGLE-RESULT-BUFFER) TO CURRENT-BALANCE
               IF CURRENT-BALANCE > 0 THEN
                   DISPLAY "SKIPPED: Cannot close account for customer "
                           FUNCTION TRIM(TX-ID) ", balance is not zero."
               ELSE
                   PERFORM DELETE-RECORDS
               END-IF
           ELSE
               DISPLAY "SKIPPED: Could not find account for customer "
                       FUNCTION TRIM(TX-ID)
           END-IF.

       DELETE-RECORDS.
           MOVE SPACES TO SQL-COMMAND.
           STRING "DELETE FROM accounts WHERE customer_id = "
               FUNCTION TRIM(TX-ID) ";" DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND RETURNING RC.

           MOVE SPACES TO SQL-COMMAND.
           STRING "DELETE FROM customers WHERE customer_id = "
               FUNCTION TRIM(TX-ID) ";" DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND RETURNING RC.
           DISPLAY "SUCCESS: Closed account for customer "
                   FUNCTION TRIM(TX-ID).
                   