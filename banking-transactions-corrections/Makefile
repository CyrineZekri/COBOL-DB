# Makefile for COBOL Student Project 2: Banking Transactions

# --- Variables ---
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

# --- Main Targets ---

all: $(patsubst $(SRC)/%.cob,$(BUILD)/%,$(wildcard $(SRC)/*.cob))

$(WRAPPER_LIB): db-wrapper.c
	@mkdir -p $(LIBDIR)
	@$(CC) $(CFLAGS) -o $@ $< $(LIBS)
	@echo "✅ C Wrapper compiled -> $@"

$(BUILD)/%: $(SRC)/%.cob $(WRAPPER_LIB)
	@mkdir -p $(BUILD)
	@$(COBC) $(COBFLAGS) $< -o $@ $(LINKFLAGS)
	@echo "✅ Compiled $< -> $@"

# --- Utility Targets ---

db-setup:
	@DB_PASSWORD=postgres ./reset-db.sh

# --- Student Test Runners ---

smoke-test: $(BUILD)/smoke
	@echo "--- Running Environment Smoke Test ---"
	@LD_LIBRARY_PATH=./lib ./build/smoke
	@echo "--- Smoke Test Complete ---"

run-1: $(BUILD)/1-initial-report
	@echo "--- Running Task 1: Initial Report ---"
	@LD_LIBRARY_PATH=./lib ./build/1-initial-report
	@echo "--- End of Task 1 ---"

run-2: $(BUILD)/2-process-transactions
	@echo "--- Running Task 2: Process Transactions ---"
	@LD_LIBRARY_PATH=./lib ./build/2-process-transactions
	@echo "--- End of Task 2 ---"

run-3: $(BUILD)/3-atomic-transfers
	@echo "--- Running Task 3: Atomic Transfers ---"
	@LD_LIBRARY_PATH=./lib ./build/3-atomic-transfers
	@echo "--- End of Task 3 ---"

run-4: $(BUILD)/4-close-accounts
	@echo "--- Running Task 4: Close Accounts ---"
	@LD_LIBRARY_PATH=./lib ./build/4-close-accounts
	@echo "--- End of Task 4 ---"

run-5: $(BUILD)/5-summary-report
	@echo "--- Running Task 5: Summary Report ---"
	@LD_LIBRARY_PATH=./lib ./build/5-summary-report
	@echo "--- End of Task 5 ---"

clean:
	@rm -rf $(BUILD)/* $(LIBDIR)/*
	@echo "🧹 Cleaned build and lib directories."

.PHONY: all db-setup smoke-test run-1 run-2 run-3 run-4 run-5 clean