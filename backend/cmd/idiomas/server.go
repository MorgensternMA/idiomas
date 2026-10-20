package main

import (
	"encoding/json"
	"net/http"

	"idiomas/backend/internal/content"
)

// newServer relee el contenido en cada pedido: así, al editar un archivo,
// la app ve el cambio con solo refrescar.
func newServer(dir string) http.Handler {
	mux := http.NewServeMux()

	mux.HandleFunc("GET /api/version", func(w http.ResponseWriter, r *http.Request) {
		b, ok := load(w, dir)
		if !ok {
			return
		}
		writeJSON(w, map[string]string{"version": b.Version})
	})

	mux.HandleFunc("GET /api/bundle", func(w http.ResponseWriter, r *http.Request) {
		b, ok := load(w, dir)
		if !ok {
			return
		}
		writeJSON(w, b)
	})

	return mux
}

func load(w http.ResponseWriter, dir string) (*content.Bundle, bool) {
	b, err := content.Load(dir)
	if err != nil {
		http.Error(w, err.Error(), http.StatusUnprocessableEntity)
		return nil, false
	}
	return b, true
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	json.NewEncoder(w).Encode(v)
}
