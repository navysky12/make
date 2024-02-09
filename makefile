# makefile to link dotfiles to HOME using stow

# target directory to install dotfiles to
TARGET ?= "${HOME}"

# space delimited directory list in repo to ignore
EXCLUDES := "work"

.PHONY: work clean stow unstow

define filtered_stow
	for dir in */ ; do \
		dir=$${dir%/}; \
		if ! echo $(EXCLUDES) | grep -qw "$$dir"; then \
			stow --target="work/" $(1) "$$dir"; \
			echo "$(2) $$dir with target work/"; \
		fi; \
	done
endef

work:
	@if [ ! -d "work/" ]; then \
		mkdir "work/"; \
		echo "Made work directory"; \
	fi; \
	$(call filtered_stow,"--no-folding","Stowed")

clean:
	@if [ ! -d "work/" ]; then \
		echo "No work directory found"; \
	else \
		$(call filtered_stow,"--delete","Unstowed"); \
	fi

stow:
	@if [ -d "work/" ]; then \
		stow --target=${TARGET} --no-folding "work/"; \
		echo "Stowed work/ with target ${TARGET}"; \
	else \
		echo "work/ not found, please run 'make work'"; \
	fi

unstow:
	@if [ -d "work/" ]; then \
		stow --target=${TARGET} --delete "work/"; \
		echo "Unstowed work/ with target ${TARGET}"; \
	else \
		echo "work/ not found, please run 'make work'"; \
	fi

