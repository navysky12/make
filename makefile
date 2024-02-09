# makefile to link dotfiles to HOME using stow

# target directory to install dotfiles to
TARGET ?= "${HOME}"

# space delimited directory list in repo to ignore
EXCLUDES := "work"

.PHONY: work clean stow unstow

work:
	@if [ ! -d "work/" ]; then \
		mkdir "work/"; \
		echo "Made work directory"; \
	fi; \
	for dir in */ ; do \
		dir=$${dir%/}; \
		if ! echo $(EXCLUDES) | grep -qw "$$dir"; then \
			find "$$dir" -name '.gitmodules' -exec \
				sed -n 's/^[ \t]*path = //p' {} \; > .modules; \
			stow_exclusions=$$(awk -F'/' '{print "|" $$NF}' .modules | paste -sd '' -); \
			stow --target="work/" --ignore="(\.gitmodules$${stow_exclusions})" --no-folding "$$dir"; \
			echo "Stowed $$dir at target work/"; \
			while IFS= read -r path_to_module; do \
				parent_path=$$(dirname $$path_to_module); \
				mkdir -p "work/$$parent_path"; \
				relative_path=$$(realpath --relative-to="work/$$parent_path" \
					"$$dir/$$path_to_module"); \
				ln -sf "$$relative_path" "work/$$path_to_module"; \
			done < .modules; \
			rm .modules; \
		fi; \
	done

clean:
	@if [ ! -d "work/" ]; then \
		echo "No work directory found"; \
	else \
		for dir in */ ; do \
			dir=$${dir%/}; \
			if ! echo $(EXCLUDES) | grep -qw "$$dir"; then \
				find "$$dir" -name '.gitmodules' -exec \
					sed -n 's/^[ \t]*path = //p' {} \; > .modules; \
				stow --target="work/" --delete "$$dir"; \
				echo "Unstowed $$dir from target work/"; \
				find work/ -empty -delete; \
				rm .modules; \
			fi; \
		done; \
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

