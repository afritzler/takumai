package main

import "fmt"

var (
	version string
	commit  string
)

func main() {
	fmt.Println("Hello, World!")
	fmt.Printf("Version: %s, Commit: %s\n", version, commit)
}
