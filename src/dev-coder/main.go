package main

import "flag"

func main() {
	var coderDir string
	flag.StringVar(&coderDir, "coder-dir", "", "$CDR")
}
