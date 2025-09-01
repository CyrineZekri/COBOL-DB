IDENTIFICATION DIVISION.
       PROGRAM-ID. read-balances.
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       COPY "dbapi.cpy".
       01  CONN-LIT PIC X(200)
           VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  L PIC 9(4) VALUE 0.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).

           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.

           MOVE SPACES TO SQL-COMMAND.
           STRING "SELECT account_id, balance FROM accounts ORDER BY account_id"
               DELIMITED BY SIZE INTO SQL-COMMAND.

           CALL STATIC "DB_QUERY"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING STMT.

           IF STMT NOT = NULL-PTR THEN
               PERFORM FETCH-LOOP UNTIL RC NOT = 0
           END-IF.

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.

       FETCH-LOOP.
           MOVE SPACES TO C1, C2, C3.
           CALL STATIC "DB_FETCH"
               USING BY VALUE STMT, BY REFERENCE C1, C2, C3
               RETURNING RC.
           IF RC = 0 THEN
               DISPLAY "-> Account " FUNCTION TRIM(C1)
                       ", balance " FUNCTION TRIM(C2).
                       