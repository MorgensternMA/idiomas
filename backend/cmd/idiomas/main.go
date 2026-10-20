// idiomas compila el contenido de las lecciones para la app y, en
// desarrollo, lo sirve por HTTP para verlo en vivo.
//
//	idiomas check -content ../content
//	idiomas build -content ../content -out ../app/assets/content.json
//	idiomas serve -content ../content -addr :8080
package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"

	"idiomas/backend/internal/content"
)

func main() {
	if len(os.Args) < 2 {
		usage()
	}
	cmd, args := os.Args[1], os.Args[2:]

	fs := flag.NewFlagSet(cmd, flag.ExitOnError)
	dir := fs.String("content", "../content", "directorio de contenido")
	out := fs.String("out", "../app/assets/content.json", "archivo de salida (build)")
	addr := fs.String("addr", ":8080", "dirección del server (serve)")
	fs.Parse(args)

	switch cmd {
	case "check":
		b := mustLoad(*dir)
		for _, l := range b.Languages {
			fmt.Printf("%s: %d temas de gramática, %d lecciones\n", l.Code, len(l.Grammar), len(l.Lessons))
		}
		fmt.Println("versión", b.Version)
	case "build":
		b := mustLoad(*dir)
		raw, err := json.MarshalIndent(b, "", "  ")
		if err != nil {
			log.Fatal(err)
		}
		if err := os.WriteFile(*out, raw, 0o644); err != nil {
			log.Fatal(err)
		}
		fmt.Printf("escrito %s (versión %s)\n", *out, b.Version)
	case "serve":
		mustLoad(*dir)
		log.Printf("sirviendo %s en %s", *dir, *addr)
		log.Fatal(http.ListenAndServe(*addr, newServer(*dir)))
	default:
		usage()
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "uso: idiomas check|build|serve [-content dir] [-out archivo] [-addr :8080]")
	os.Exit(2)
}

func mustLoad(dir string) *content.Bundle {
	b, err := content.Load(dir)
	if err != nil {
		log.Fatalf("contenido inválido:\n%v", err)
	}
	return b
}
