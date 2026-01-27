BEGIN {
	split(v1, a, ".")
	split(v2, b, ".")
	for (i = 1; i <= 3; i++) {
		if ((a[i] + 0) < (b[i] + 0)) {
			print -1
			exit
		}
		if ((a[i] + 0) > (b[i] + 0)) {
			print 1
			exit
		}
	}
	print 0
}
