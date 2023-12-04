package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

func main() {
	var coderDir string
	var oktaOIDC bool
	flag.StringVar(&coderDir, "coder-dir", "$CDR", ":ocation of coder repo")
	flag.BoolVar(&oktaOIDC, "okta-oidc", true, "Use okta oidc for auth")
	// flag.BoolVar(&githubExternalAuth, "okta-oidc", true, "Use okta oidc for auth")

	flag.Parse()
	coderDir = os.ExpandEnv(coderDir)
	if len(os.Args) == 1 {
		usage()
		return
	}

	switch os.Args[1] {
	case "local":
		extraFlags := []string{}
		if oktaOIDC {
			extraFlags = append(extraFlags, "--oidc-issuer-url", os.ExpandEnv("$OKTA_LOCAL_OIDC_ISSUER_URL"))
			extraFlags = append(extraFlags, "--oidc-client-id", os.ExpandEnv("$OKTA_LOCAL_OIDC_CLIENT_ID"))
			extraFlags = append(extraFlags, "--oidc-client-secret", os.ExpandEnv("$OKTA_LOCAL_OIDC_CLIENT_SECRET"))
		}

		allFlags := append([]string{
			"--",
			"--postgres-url", "postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable",
		}, extraFlags...)
		cmd := exec.Command(
			filepath.Join(coderDir, "scripts", "develop.sh"),
			allFlags...,
		)
		cmd.Env = os.Environ()
		cmd.Dir = coderDir
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		err := cmd.Run()
		if err != nil {
			log.Fatal(err.Error())
		}
	default:
		usage()
		return
	}
}

func usage() {
	fmt.Println("Usage: dev-coder <command> [options]")
}
