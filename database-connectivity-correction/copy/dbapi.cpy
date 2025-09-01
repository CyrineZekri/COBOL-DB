01  DB-CONNSTR           PIC X(256).
       01  SQL-COMMAND          PIC X(512).
       01  DBH                  USAGE POINTER.
       01  STMT                 USAGE POINTER.
       01  NULL-PTR             USAGE POINTER.
       01  RC                   PIC S9(9) COMP-5.
       01  C1                   PIC X(64).
       01  C2                   PIC X(64).
       01  C3                   PIC X(256).
       