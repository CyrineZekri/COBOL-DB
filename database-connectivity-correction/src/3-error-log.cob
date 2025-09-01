IDENTIFICATION DIVISION.
       PROGRAM-ID. error-log.
       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT LOG-FILE ASSIGN TO "build/db_errors.log"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS LOG-FILE-STATUS.
       DATA DIVISION.
       FILE SECTION.
       FD  LOG-FILE.
       01  LOG-RECORD           PIC X(200).
       WORKING-STORAGE SECTION.
       COPY "dbapi.cpy".
       01  LOG-LINE             PIC X(200).
       01  CONN-LIT             PIC X(200)
           VALUE "host=localhost dbname=schooldb user=postgres password=postgres".
       01  SQL-LIT  PIC X(200) VALUE "SELECT wrong_column FROM accounts;".
       01  L                    PIC 9(4) VALUE 0.
       01  LOG-FILE-STATUS      PIC XX.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE SPACES TO DB-CONNSTR.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(CONN-LIT)).
           MOVE CONN-LIT(1:L) TO DB-CONNSTR(1:L).
           MOVE X"00" TO DB-CONNSTR(L + 1:1).

           CALL STATIC "DB_CONNECT" USING DB-CONNSTR RETURNING DBH.
           IF DBH = NULL-PTR THEN STOP RUN.


           MOVE SPACES TO SQL-COMMAND.
           COMPUTE L = FUNCTION LENGTH(FUNCTION TRIM(SQL-LIT)).
           MOVE SQL-LIT(1:L) TO SQL-COMMAND(1:L).
           MOVE X"00" TO SQL-COMMAND(L + 1:1).

           CALL STATIC "DB_QUERY"
               USING BY VALUE DBH, BY REFERENCE SQL-COMMAND
               RETURNING STMT.

           IF STMT = NULL-PTR THEN
               PERFORM WRITE-TO-LOG
           END-IF.

           CALL STATIC "DB_DISCONNECT" USING BY VALUE DBH RETURNING RC.
           GOBACK.

       WRITE-TO-LOG.
           OPEN INPUT LOG-FILE.
           IF LOG-FILE-STATUS = "35" THEN
               OPEN OUTPUT LOG-FILE
               CLOSE LOG-FILE
           ELSE
               CLOSE LOG-FILE
           END-IF.
           STRING "[ERROR] SQL=" FUNCTION TRIM(SQL-LIT)
               INTO LOG-LINE.
           OPEN EXTEND LOG-FILE.
           MOVE LOG-LINE TO LOG-RECORD.
           WRITE LOG-RECORD.
           CLOSE LOG-FILE.
           DISPLAY "ERROR: Logged to build/db_errors.log".