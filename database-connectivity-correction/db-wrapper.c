#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <libpq-fe.h>

extern "C" {

typedef struct { PGresult *res; int row; } stmt_t;

static void set_err(const char* m) { (void)m; }

static char* dup_trim_cstr(const char *s) {
    if (!s) return NULL;
    size_t n = strnlen(s, 4096);
    while (n > 0 && (s[n-1] == ' ' || s[n-1] == '\t' || s[n-1] == '\n' || s[n-1] == '\r')) n--;
    char *p = (char*)malloc(n+1);
    if (!p) return NULL;
    memcpy(p, s, n);
    p[n] = '\0';
    return p;
}

void* DB_CONNECT(const char *conninfo) {
    set_err("");
    char *ci = dup_trim_cstr(conninfo);
    if (!ci) { set_err("OOM dup conninfo"); return NULL; }
    PGconn *c = PQconnectdb(ci);
    free(ci);
    if (PQstatus(c) != CONNECTION_OK) {
        fprintf(stderr, "DB_CONNECT failed: %s\n", PQerrorMessage(c));
        PQfinish(c);
        return NULL;
    }
    return (void*)c;
}

int DB_DISCONNECT(void *dbh) {
    if (!dbh) return 0;
    PQfinish((PGconn*)dbh);
    return 0;
}

int DB_EXEC(void *dbh, const char *sql) {
    set_err("");
    if (!dbh || !sql) { set_err("bad args"); return 1; }
    char *q = dup_trim_cstr(sql);
    if (!q) { set_err("OOM dup sql"); return 1; }
    PGresult *r = PQexec((PGconn*)dbh, q);
    free(q);
    if (!r) return 2;
    ExecStatusType st = PQresultStatus(r);
    int rc = (st == PGRES_COMMAND_OK || st == PGRES_TUPLES_OK) ? 0 : 3;
    if (rc != 0) { fprintf(stderr, "DB_EXEC failed: %s\n", PQresultErrorMessage(r)); }
    PQclear(r);
    return rc;
}

void* DB_QUERY(void *dbh, const char *sql) {
    set_err("");
    if (!dbh || !sql) { set_err("bad args"); return NULL; }
    char *q = dup_trim_cstr(sql);
    if (!q) { set_err("OOM dup sql"); return NULL; }
    PGresult *r = PQexec((PGconn*)dbh, q);
    free(q);
    if (!r) return NULL;
    if (PQresultStatus(r) != PGRES_TUPLES_OK) {
        fprintf(stderr, "DB_QUERY failed: %s\n", PQresultErrorMessage(r));
        PQclear(r); return NULL;
    }
    stmt_t *s = (stmt_t*)calloc(1, sizeof(stmt_t));
    if (!s) { PQclear(r); return NULL; }
    s->res = r; s->row = 0;
    return (void*)s;
}

int DB_FETCH(void *vstmt, char *c1, char *c2, char *c3) {
    set_err("");
    if (!vstmt) return 2;
    stmt_t *s = (stmt_t*)vstmt;
    int rows = PQntuples(s->res);
    if (s->row >= rows) {
        PQclear(s->res);
        s->res = NULL;
        free(s);
        return 1; // EOF
    }
    const char *v1 = (PQnfields(s->res) > 0) ? PQgetvalue(s->res, s->row, 0) : "";
    const char *v2 = (PQnfields(s->res) > 1) ? PQgetvalue(s->res, s->row, 1) : "";
    const char *v3 = (PQnfields(s->res) > 2) ? PQgetvalue(s->res, s->row, 2) : "";

    // THE FIX IS HERE: Buffer sizes now exactly match the COBOL PICs.
    if (c1) { snprintf(c1, 64,  "%s", v1); }
    if (c2) { snprintf(c2, 64,  "%s", v2); }
    if (c3) { snprintf(c3, 256, "%s", v3); }
    s->row++;
    return 0;
}

} // End of extern "C" block