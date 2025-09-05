# Makefile for COBOL  Project  Transaction Validation

BUILD   := build
SRC     := src
COPY    := copy
LIBDIR  := lib

CC      := g++
CFLAGS  := -shared -fPIC
LIBS    := -I/usr/include/postgresql -lpq

COBC    := cobc
COBFLAGS:= -x -free -I$(COPY)
LINKFLAGS:= -L$(LIBDIR) -lpgcob

WRAPPER_LIB := $(LIBDIR)/libpgcob.so

all: $(patsubst $(SRC)/%.cob,$(BUILD)/%,$(wildcard $(SRC)/*.cob))

$(WRAPPER_LIB): db-wrapper.c
	@mkdir -p $(LIBDIR)
	@$(CC) $(CFLAGS) -o $@ $< $(LIBS)
	@echo "✅ C Wrapper compiled -> $@"

$(BUILD)/%: $(SRC)/%.cob $(WRAPPER_LIB)
	@mkdir -p $(BUILD)
	@$(COBC) $(COBFLAGS) $< -o $@ $(LINKFLAGS)
	@echo "✅ Compiled $< -> $@"

db-setup:
	@DB_PASSWORD=postgres ./reset-db.sh

load-proc:
	@echo "Loading stored procedure..."
	@PGPASSWORD=postgres psql -h 127.0.0.1 -U postgres -d schooldb -f stored_procedure.sql
	@echo "✅ Stored procedure loaded."

# --- Individual Task Runners ---

run-1: $(BUILD)/1-validate-withdrawal
	@echo "--- Running Task 1: Validate Withdrawal ---"
	@LD_LIBRARY_PATH=./lib ./build/1-validate-withdrawal
	@echo "--- End of Task 1 ---"

run-2: $(BUILD)/2-audit-trail
	@echo "--- Running Task 2: Secure Audit Trail ---"
	@LD_LIBRARY_PATH=./lib ./build/2-audit-trail
	@echo "--- End of Task 2 ---"

run-3: $(BUILD)/3-batch-validation
	@echo "--- Running Task 3: Guardian of the Ledger ---"
	@LD_LIBRARY_PATH=./lib ./build/3-batch-validation
	@echo "--- End of Task 3 ---"

run-4: $(BUILD)/4-extend-api
	@echo "--- Running Task 4 (Stretch Goal): Extend API ---"
	@LD_LIBRARY_PATH=./lib ./build/4-extend-api
	@echo "--- End of Task 4 ---"

clean:
	@rm -rf $(BUILD)/* $(LIBDIR)/*
	@echo "🧹 Cleaned build and lib directories."

.PHONY: all db-setup load-proc run-1 run-2 run-3 run-4 clean