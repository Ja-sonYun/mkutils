BEGIN {
	s = ENVIRON["_E"]
	if (index(opts, "backslash")) {
		gsub(/\\/, "\\\\", s)
	}
	if (index(opts, "dq")) {
		gsub(/"/, "\\\"", s)
	}
	if (index(opts, "sq")) {
		gsub(/'/, "'\\''", s)
	}
	if (index(opts, "backtick")) {
		gsub(/`/, "\\`", s)
	}
	print s
}
