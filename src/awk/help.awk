BEGIN {
	FS = ":.*## "
	if (no_color == "" || no_color == "0") {
		C_RESET = "\033[0m"
		C_BOLD = "\033[1m"
		C_DIM = "\033[2m"
		C_GREEN = "\033[0;32m"
		C_YELLOW = "\033[0;33m"
		C_BLUE = "\033[0;34m"
		C_CYAN = "\033[0;36m"
	}
	if (project == "") {
		project = "Project"
	}
	if (width == "") {
		width = 20
	}
	cat_count = 0
	target_count = 0
	current_cat = ""
}

/^##@/ {
	current_cat = substr($0, 5)
	if (! (current_cat in cat_seen)) {
		cat_seen[current_cat] = 1
		cat_order[++cat_count] = current_cat
	}
	next
}

/^[a-zA-Z0-9_-]+:.*?## / {
	target = $1
	desc = $2
	target_order[++target_count] = target
	target_desc[target] = desc
	target_cat[target] = current_cat
}

END {
	printf "%s%s%s%s", C_BOLD, C_BLUE, project, C_RESET
	if (version != "") {
		printf " %sv%s%s", C_DIM, version, C_RESET
	}
	printf "\n"
	if (description != "") {
		printf "%s", C_DIM
		n = split(description, lines, "\n")
		for (i = 1; i <= n; i++) {
			printf "  %s\n", lines[i]
		}
		printf "%s", C_RESET
	} else {
		printf "\n"
	}
	printf "%sUsage:%s make [target] [VARIABLE=value]\n\n", C_YELLOW, C_RESET
	if (examples != "") {
		printf "%sExamples:%s\n%s", C_YELLOW, C_RESET, C_DIM
		n = split(examples, lines, "\n")
		for (i = 1; i <= n; i++) {
			printf "  %s\n", lines[i]
		}
		printf "%s\n", C_RESET
	}
	if (variables != "") {
		printf "%sVariables:%s\n%s", C_YELLOW, C_RESET, C_DIM
		n = split(variables, lines, "\n")
		for (i = 1; i <= n; i++) {
			printf "  %s\n", lines[i]
		}
		printf "%s\n", C_RESET
	}
	printf "%sTargets:%s\n", C_YELLOW, C_RESET
	for (i = 1; i <= target_count; i++) {
		t = target_order[i]
		cat = target_cat[t]
		if (! (cat in printed_cat)) {
			printed_cat[cat] = 1
			if (cat != "") {
				printf "\n  %s%s%s\n", C_CYAN, cat, C_RESET
			}
		}
		printf "    %s%-*s%s %s\n", C_GREEN, width, t, C_RESET, target_desc[t]
	}
	printf "\n"
}
