# Compila el contenido a la app. Correr después de editar content/.
content:
	cd backend && go run ./cmd/idiomas build -content ../content -out ../app/assets/content.json

# Server local: la app lo lee si lo configurás en Ajustes.
serve:
	cd backend && go run ./cmd/idiomas serve -content ../content -addr :8080

check:
	cd backend && go run ./cmd/idiomas check -content ../content

test: content
	cd backend && go test ./...
	cd app && flutter analyze && flutter test

run: content
	cd app && flutter run

.PHONY: content serve check test run
