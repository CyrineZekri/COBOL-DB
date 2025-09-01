COBCOPY := copy
LIBDIR  := lib
BUILDD  := build
SRC     := src

all: help

help:
	@echo "Targets:"
	@echo "  make seed     # create/seed DB from bootstrap.sql"
	@echo "  make build    # compile any src/*.cob present"
	@echo "  make run      # build then run each built binary"
	@echo "  make smoke    # build & run src/smoke.cob only"
	@echo "  make clean    # remove build/"

seed:
	@./reset_db.sh

$(BUILDD)/%: $(SRC)/%.cob $(COBCOPY)/dbapi.cpy $(LIBDIR)/libpgcob.so
	mkdir -p $(BUILDD)
	cobc -x -free -o $@ $< -I$(COBCOPY) -L$(LIBDIR) -lpgcob

build:
	@mkdir -p $(BUILDD)
	@sh -c 'set -e; for f in $(SRC)/*.cob; do \
	  [ -e "$$f" ] || continue; \
	  b=$$(basename "$$f" .cob); \
	  echo "Compiling $$f -> $(BUILDD)/$$b"; \
	  cobc -x -free -o $(BUILDD)/$$b "$$f" -I$(COBCOPY) -L$(LIBDIR) -lpgcob; \
	done'

run: build
	@sh -c 'for b in $(BUILDD)/*; do \
	  [ -x "$$b" ] || continue; \
	  echo "== Running $$b"; \
	  COB_LIBRARY_PATH=$(LIBDIR) "$$b" || true; \
	done'

smoke: $(BUILDD)/smoke
	@echo "== Running smoke"
	@COB_LIBRARY_PATH=$(LIBDIR) $(BUILDD)/smoke

clean:
	rm -rf $(BUILDD)

.PHONY: all help seed build run smoke clean
