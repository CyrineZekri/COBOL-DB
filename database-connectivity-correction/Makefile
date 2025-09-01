# Makefile for COBOL Student Projects v5.0 (Final Version)

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

# 'make' builds all .cob files in the src directory.
all: $(patsubst $(SRC)/%.cob,$(BUILD)/%,$(wildcard $(SRC)/*.cob))

# Rule to build the C wrapper.
$(WRAPPER_LIB): db-wrapper.c
	@mkdir -p $(LIBDIR)
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)
	@echo "✅ C Wrapper compiled -> $@"

# Generic rule to compile any COBOL file.
$(BUILD)/%: $(SRC)/%.cob $(WRAPPER_LIB)
	@mkdir -p $(BUILD)
	$(COBC) $(COBFLAGS) $< -o $@ $(LINKFLAGS)
	@echo "✅ Compiled $< -> $@"

# --- Utility Targets ---

db-setup:
	@DB_PASSWORD=postgres ./reset-db.sh

# --- Student Test Runners ---

smoke-test: $(BUILD)/smoke
	@echo "--- Running Environment Smoke Test ---"
	@LD_LIBRARY_PATH=./lib ./build/smoke
	@echo "--- Smoke Test Complete ---"

run-1: $(BUILD)/1-read-balances
	@echo "--- Running Task 1: Read Balances ---"
	@LD_LIBRARY_PATH=./lib ./build/1-read-balances
	@echo "--- End of Task 1 ---"

run-2: $(BUILD)/2-error-demo
	@echo "--- Running Task 2: Error Demo ---"
	@LD_LIBRARY_PATH=./lib ./build/2-error-demo
	@echo "--- End of Task 2 ---"

run-3: $(BUILD)/3-error-log
	@echo "--- Running Task 3: Error Logging ---"
	@LD_LIBRARY_PATH=./lib ./build/3-error-log
	@echo "--- End of Task 3 ---"

run-4: $(BUILD)/4-full-demo
	@echo "--- Running Task 4: Full Demo ---"
	@LD_LIBRARY_PATH=./lib ./build/4-full-demo
	@echo "--- End of Task 4 ---"

clean:
	@rm -rf $(BUILD)/* $(LIBDIR)/*
	@echo "🧹 Cleaned build and lib directories."

.PHONY: all db-setup smoke-test run-1 run-2 run-3 run-4 clean