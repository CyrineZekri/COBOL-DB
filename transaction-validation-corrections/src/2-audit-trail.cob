IDENTIFICATION DIVISION.
       PROGRAM-ID. audit-trail.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TX-FILE ASSIGN TO "transactions.dat".
       DATA DIVISION.
       FILE SECTION.
       FD  TX-FILE.
       01  TX-RECORD            PIC X(200).
       WORKING-STORAGE SECTION.
       COPY "dbapi.cpy".
       01  CONN-LIT PIC X(200) VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  L PIC 9(4) VALUE 0.
       01  TX-FILE-STATUS PIC XX.
       01  SQL-LIT              PIC X(200).
       01  TX-DATA.
           05 TX-ACTION         PIC X(8).
           05 TX-ACCOUNT-ID     PIC X(4).
           05 TX-AMOUNT         PIC X(10).
       01  CURRENT-BALANCE      PIC S9(8)V99.
       01  WITHDRAWAL-AMOUNT    PIC S9(8)V99.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).
           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.
           OPEN INPUT TX-FILE.
           PERFORM PROCESS-WITHDRAWALS UNTIL TX-FILE-STATUS NOT = "00".
           CLOSE TX-FILE.
           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.
       PROCESS-WITHDRAWALS.
           READ TX-FILE AT END SET TX-FILE-STATUS TO "10".
           IF TX-FILE-STATUS = "00" THEN
               UNSTRING TX-RECORD DELIMITED BY ","
                   INTO TX-ACTION, TX-ACCOUNT-ID, TX-AMOUNT
               PERFORM VALIDATE-AND-PROCESS
           END-IF.
       VALIDATE-AND-PROCESS.
           MOVE SPACES TO SQL-COMMAND.
           STRING "SELECT balance FROM accounts WHERE account_id = "
               FUNCTION TRIM(TX-ACCOUNT-ID) INTO SQL-LIT.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT)).
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L).
           MOVE X"00" TO SQL-COMMAND(L + 1:1).
           CALL "DB_QUERY_SINGLE"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND,
                     BY REFERENCE SINGLE-RESULT-BUFFER
               RETURNING RC.
           IF RC = 0 THEN
               MOVE FUNCTION NUMVAL(SINGLE-RESULT-BUFFER) TO CURRENT-BALANCE
               MOVE FUNCTION NUMVAL(TX-AMOUNT) TO WITHDRAWAL-AMOUNT
               IF CURRENT-BALANCE >= WITHDRAWAL-AMOUNT THEN
                   PERFORM EXECUTE-UPDATE-AND-AUDIT
               END-IF
           END-IF.
       EXECUTE-UPDATE-AND-AUDIT.
           MOVE SPACES TO SQL-COMMAND.
           STRING "UPDATE accounts SET balance = balance - "
               FUNCTION TRIM(TX-AMOUNT) " WHERE account_id = "
               FUNCTION TRIM(TX-ACCOUNT-ID) INTO SQL-LIT.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT)).
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L).
           MOVE X"00" TO SQL-COMMAND(L + 1:1).
           CALL "DB_EXEC"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING RC.
           IF RC = 0 THEN
               PERFORM LOG-TRANSACTION
           END-IF.
       LOG-TRANSACTION.
           MOVE SPACES TO SQL-COMMAND.
           STRING "CALL LOG_TRANSACTION(" FUNCTION TRIM(TX-ACCOUNT-ID)
               ", " FUNCTION TRIM(TX-AMOUNT) ", 'WITHDRAW')" INTO SQL-LIT.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT)).
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L).
           MOVE X"00" TO SQL-COMMAND(L + 1:1).
           CALL "DB_EXEC"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING RC.
           IF RC = 0 THEN
               DISPLAY "SUCCESS: Withdrawal and audit log complete for account "
                       FUNCTION TRIM(TX-ACCOUNT-ID)
           END-IF.
           