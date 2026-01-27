BEGIN {
	split(ver, v, ".")
	if (part == "major") {
		v[1]++
		v[2] = 0
		v[3] = 0
	} else if (part == "minor") {
		v[2]++
		v[3] = 0
	} else if (part == "patch") {
		v[3]++
	}
	printf "%d.%d.%d", v[1], v[2], v[3]
}
