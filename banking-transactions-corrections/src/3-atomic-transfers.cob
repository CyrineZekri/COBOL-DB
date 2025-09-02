IDENTIFICATION DIVISION.
       PROGRAM-ID. atomic-transfers.
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
           05 TX-FROM-ACCT      PIC X(4).
           05 TX-TO-ACCT        PIC X(4).
           05 TX-AMOUNT         PIC X(10).
       01  RC-WITHDRAW          PIC S9(9) COMP-5.
       01  RC-DEPOSIT           PIC S9(9) COMP-5.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).

           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.

           OPEN INPUT TX-FILE.
           PERFORM PROCESS-TRANSFERS UNTIL TX-FILE-STATUS NOT = "00".
           CLOSE TX-FILE.

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.

       PROCESS-TRANSFERS.
           READ TX-FILE AT END SET TX-FILE-STATUS TO "10".
           IF TX-FILE-STATUS = "00" THEN
               UNSTRING TX-RECORD DELIMITED BY ","
                   INTO TX-ACTION, TX-FROM-ACCT, TX-TO-ACCT, TX-AMOUNT
               IF FUNCTION UPPER-CASE(FUNCTION TRIM(TX-ACTION)) = "TRANSFER"
                   PERFORM HANDLE-TRANSFER
               END-IF
           END-IF.

       HANDLE-TRANSFER.
           CALL STATIC "DB_BEGIN" USING BY VALUE DBH RETURNING RC.
           IF RC NOT = 0 THEN
               DISPLAY "ERROR: Could not begin transaction."
               EXIT PARAGRAPH
           END-IF.

           MOVE SPACES TO SQL-COMMAND.
           STRING "UPDATE accounts SET balance = balance - "
               FUNCTION TRIM(TX-AMOUNT) " WHERE account_id = "
               FUNCTION TRIM(TX-FROM-ACCT) ";"
               DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC" USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING RC-WITHDRAW.

           MOVE SPACES TO SQL-COMMAND.
           STRING "UPDATE accounts SET balance = balance + "
               FUNCTION TRIM(TX-AMOUNT) " WHERE account_id = "
               FUNCTION TRIM(TX-TO-ACCT) ";"
               DELIMITED BY SIZE INTO SQL-COMMAND.
           CALL STATIC "DB_EXEC" USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING RC-DEPOSIT.

           IF RC-WITHDRAW = 0 AND RC-DEPOSIT = 0 THEN
               CALL STATIC "DB_COMMIT" USING BY VALUE DBH RETURNING RC
               DISPLAY "SUCCESS: Transfer of " FUNCTION TRIM(TX-AMOUNT)
                       " from " FUNCTION TRIM(TX-FROM-ACCT)
                       " to " FUNCTION TRIM(TX-TO-ACCT) " committed."
           ELSE
               CALL STATIC "DB_ROLLBACK" USING BY VALUE DBH RETURNING RC
               DISPLAY "FAILURE: Transfer rolled back."
           END-IF.
           