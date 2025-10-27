       IDENTIFICATION DIVISION.
       PROGRAM-ID. batch-validation.

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
       01  CONN-LIT             PIC X(200)
           VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  L                    PIC 9(4) VALUE 0.
       01  TX-FILE-STATUS       PIC XX  VALUE "00".
       01  SQL-LIT              PIC X(200).
       01  TX-DATA.
           05 TX-ACTION         PIC X(20).
           05 TX-ACCOUNT-ID     PIC X(20).
           05 TX-AMOUNT         PIC X(30).
       01  CURRENT-BALANCE      PIC S9(9)V99 VALUE 0.
       01  WITHDRAWAL-AMOUNT    PIC S9(9)V99 VALUE 0.
       01  BATCH-FAILED-FLAG    PIC X VALUE "N".
       01  PROCESSED-COUNT      PIC 9(9) VALUE 0.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT))
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L)
           MOVE X"00" TO DB-CONNSTR(L + 1:1)
           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH
           IF DBH = NULL-PTR
              STOP RUN
           END-IF

           CALL "DB_BEGIN" USING BY VALUE DBH RETURNING RC

           OPEN INPUT TX-FILE

           PERFORM UNTIL TX-FILE-STATUS NOT = "00" OR BATCH-FAILED-FLAG = 'Y'
              READ TX-FILE
                 AT END
                    MOVE "10" TO TX-FILE-STATUS
                 NOT AT END
                    MOVE SPACES TO TX-ACTION
                    MOVE SPACES TO TX-ACCOUNT-ID
                    MOVE SPACES TO TX-AMOUNT
                    UNSTRING TX-RECORD
                      DELIMITED BY ","
                      INTO TX-ACTION
                           TX-ACCOUNT-ID
                           TX-AMOUNT
                    END-UNSTRING
                    IF FUNCTION TRIM(TX-ACTION) = "WITHDRAW"
                       PERFORM VALIDATE-AND-APPLY
                       ADD 1 TO PROCESSED-COUNT
                    END-IF
              END-READ
              IF TX-FILE-STATUS NOT = "00" AND TX-FILE-STATUS NOT = "10"
                 MOVE 'Y' TO BATCH-FAILED-FLAG
              END-IF
           END-PERFORM

           CLOSE TX-FILE

           IF BATCH-FAILED-FLAG = 'Y' OR PROCESSED-COUNT = 0
              CALL "DB_ROLLBACK" USING BY VALUE DBH RETURNING RC
              DISPLAY "FAILURE: Batch rejected due to invalid transaction. Database has been rolled back."
           ELSE
              CALL "DB_COMMIT" USING BY VALUE DBH RETURNING RC
              DISPLAY "SUCCESS: All withdrawals applied. Database committed."
           END-IF

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC
           GOBACK.

       VALIDATE-AND-APPLY.
           MOVE SPACES TO SQL-COMMAND
           MOVE SPACES TO SQL-LIT
           STRING
              "SELECT balance FROM accounts WHERE account_id = "
              FUNCTION TRIM(TX-ACCOUNT-ID)
              INTO SQL-LIT
           END-STRING
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT))
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L)
           MOVE X"00" TO SQL-COMMAND(L + 1:1)

           CALL "DB_QUERY_SINGLE"
                USING BY VALUE DBH
                      BY REFERENCE SQL-COMMAND
                      BY REFERENCE SINGLE-RESULT-BUFFER
                RETURNING RC
           END-CALL
           IF RC NOT = 0
              MOVE 'Y' TO BATCH-FAILED-FLAG
              EXIT PARAGRAPH
           END-IF

           MOVE FUNCTION NUMVAL(SINGLE-RESULT-BUFFER) TO CURRENT-BALANCE
           MOVE FUNCTION NUMVAL(TX-AMOUNT)            TO WITHDRAWAL-AMOUNT

           IF CURRENT-BALANCE < WITHDRAWAL-AMOUNT
              MOVE 'Y' TO BATCH-FAILED-FLAG
              EXIT PARAGRAPH
           END-IF

           MOVE SPACES TO SQL-COMMAND
           MOVE SPACES TO SQL-LIT
           STRING
              "UPDATE accounts SET balance = balance - "
              FUNCTION TRIM(TX-AMOUNT)
              " WHERE account_id = "
              FUNCTION TRIM(TX-ACCOUNT-ID)
              INTO SQL-LIT
           END-STRING
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT))
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L)
           MOVE X"00" TO SQL-COMMAND(L + 1:1)

           CALL "DB_EXEC"
                USING BY VALUE DBH
                      BY REFERENCE SQL-COMMAND
                RETURNING RC
           END-CALL
           IF RC NOT = 0
              MOVE 'Y' TO BATCH-FAILED-FLAG
              EXIT PARAGRAPH
           END-IF

           MOVE SPACES TO SQL-COMMAND
           MOVE SPACES TO SQL-LIT
           STRING
              "CALL log_transaction("
              FUNCTION TRIM(TX-ACCOUNT-ID)
              ", 'WITHDRAW', "
              FUNCTION TRIM(TX-AMOUNT)
              ")"
              INTO SQL-LIT
           END-STRING
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT))
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L)
           MOVE X"00" TO SQL-COMMAND(L + 1:1)

           CALL "DB_EXEC"
                USING BY VALUE DBH
                      BY REFERENCE SQL-COMMAND
                RETURNING RC
           END-CALL
           IF RC NOT = 0
              MOVE 'Y' TO BATCH-FAILED-FLAG
           END-IF.
