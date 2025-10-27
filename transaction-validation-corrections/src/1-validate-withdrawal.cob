       IDENTIFICATION DIVISION.
       PROGRAM-ID. validate-withdrawal.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT TX-FILE ASSIGN TO "transactions.dat"
                  ORGANIZATION IS LINE SEQUENTIAL
                  FILE STATUS IS TX-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.
       FD  TX-FILE.
       01  TX-RECORD            PIC X(512).

       WORKING-STORAGE SECTION.
       COPY "dbapi.cpy".
       01  CONN-LIT             PIC X(200) VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  L                    PIC 9(4) VALUE 0.
       01  TX-FILE-STATUS       PIC XX VALUE "00".
       01  SQL-LIT              PIC X(512).
       01  CLEAN-LINE           PIC X(512).
       01  TX-ACTION            PIC X(32).
       01  TX-ACCOUNT-ID        PIC X(32).
       01  TX-AMOUNT            PIC X(32).
       01  AMOUNT-NUM           PIC S9(9)V99    COMP-3.
       01  AMOUNT-DSP           PIC 9(9)V99.
       01  CURRENT-BALANCE      PIC S9(9)V99    COMP-3.
       01  WITHDRAWAL-AMOUNT    PIC S9(9)V99    COMP-3.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT))
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L)
           MOVE X"00" TO DB-CONNSTR(L + 1:1)
           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH
           IF DBH = NULL-PTR
               DISPLAY "Validation FAILED: Database connection error"
               STOP RUN
           END-IF

           OPEN INPUT TX-FILE
           PERFORM UNTIL TX-FILE-STATUS NOT = "00"
              READ TX-FILE
                 AT END
                    MOVE "10" TO TX-FILE-STATUS
                 NOT AT END
                    MOVE TX-RECORD TO CLEAN-LINE
                    INSPECT CLEAN-LINE REPLACING ALL X"0D" BY SPACE
                    INSPECT CLEAN-LINE REPLACING ALL X"0A" BY SPACE
                    MOVE SPACES TO TX-ACTION TX-ACCOUNT-ID TX-AMOUNT
                    UNSTRING CLEAN-LINE DELIMITED BY ","
                       INTO TX-ACTION TX-ACCOUNT-ID TX-AMOUNT
                    END-UNSTRING
                    IF FUNCTION UPPER-CASE(FUNCTION TRIM(TX-ACTION)) = "WITHDRAW"
                       PERFORM VALIDATE-AND-PROCESS
                    END-IF
              END-READ
           END-PERFORM
           CLOSE TX-FILE

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC
           GOBACK.

       VALIDATE-AND-PROCESS.
           MOVE FUNCTION NUMVAL(FUNCTION TRIM(TX-AMOUNT)) TO AMOUNT-NUM
           MOVE AMOUNT-NUM TO AMOUNT-DSP

           MOVE SPACES TO SINGLE-RESULT-BUFFER
           MOVE SPACES TO SQL-COMMAND
           MOVE SPACES TO SQL-LIT
           STRING
              "SELECT balance FROM accounts WHERE account_id = "
              FUNCTION TRIM(TX-ACCOUNT-ID)
              "::bigint"
              INTO SQL-LIT
           END-STRING
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT))
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L)
           MOVE X"00" TO SQL-COMMAND(L + 1:1)

           CALL STATIC "DB_QUERY_SINGLE"
               USING BY VALUE DBH
                     BY REFERENCE SQL-COMMAND
                     BY REFERENCE SINGLE-RESULT-BUFFER
               RETURNING RC
           IF RC NOT = 0
               DISPLAY "Validation FAILED: Unable to read balance for account " FUNCTION TRIM(TX-ACCOUNT-ID)
               EXIT PARAGRAPH
           END-IF

           MOVE FUNCTION NUMVAL(SINGLE-RESULT-BUFFER) TO CURRENT-BALANCE
           MOVE AMOUNT-NUM TO WITHDRAWAL-AMOUNT

           IF CURRENT-BALANCE >= WITHDRAWAL-AMOUNT
              PERFORM EXECUTE-UPDATE
           ELSE
              DISPLAY "Validation FAILED: Insufficient funds for account " FUNCTION TRIM(TX-ACCOUNT-ID)
           END-IF.

       EXECUTE-UPDATE.
           MOVE SPACES TO SQL-COMMAND
           MOVE SPACES TO SQL-LIT
           STRING
              "UPDATE accounts SET balance = balance - "
              FUNCTION TRIM(TX-AMOUNT)
              " WHERE account_id = "
              FUNCTION TRIM(TX-ACCOUNT-ID)
              "::bigint"
              INTO SQL-LIT
           END-STRING
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT))
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L)
           MOVE X"00" TO SQL-COMMAND(L + 1:1)

           CALL STATIC "DB_EXEC"
               USING BY VALUE DBH
                     BY REFERENCE SQL-COMMAND
               RETURNING RC
           IF RC = 0
              DISPLAY "Validation PASSED: Withdrawal of " FUNCTION TRIM(TX-AMOUNT)
                      " from account " FUNCTION TRIM(TX-ACCOUNT-ID) " successful."
           ELSE
              DISPLAY "Validation FAILED: Database update error for account " FUNCTION TRIM(TX-ACCOUNT-ID)
           END-IF.
