package main

import "fmt"

// parameters that are embedded via LDFLAGS.
var (
	Name      string
	Version   string
	GoVersion string
	BuildDate string
	GitTag    string
	GitLog    string
	GitHash   string
	GitBranch string
)

func PrintParams() {
	fmt.Println("Name:\t", Name)
	fmt.Println("Version:\t", Version)
	fmt.Println("GoVersion:\t", GoVersion)
	fmt.Println("BuildDate:\t", BuildDate)
	fmt.Println("GitTag:\t", GitTag)
	fmt.Println("GitLog:\t", GitLog)
	fmt.Println("GitHash:\t", GitHash)
	fmt.Println("GitBranch:\t", GitBranch)
}
