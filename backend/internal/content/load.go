package content

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"gopkg.in/yaml.v3"
)

// Load lee el directorio de contenido. Cada subdirectorio con un
// language.yaml es un idioma; dentro, grammar/*.md y lessons/*.yaml.
func Load(dir string) (*Bundle, error) {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	b := &Bundle{}
	for _, e := range entries {
		if !e.IsDir() {
			continue
		}
		langDir := filepath.Join(dir, e.Name())
		if _, err := os.Stat(filepath.Join(langDir, "language.yaml")); errors.Is(err, os.ErrNotExist) {
			continue
		}
		lang, err := loadLanguage(langDir)
		if err != nil {
			return nil, err
		}
		b.Languages = append(b.Languages, *lang)
	}

	if err := b.Validate(); err != nil {
		return nil, err
	}

	b.Version, err = hashBundle(b)
	if err != nil {
		return nil, err
	}
	return b, nil
}

func loadLanguage(dir string) (*Language, error) {
	var lang Language
	if err := readYAML(filepath.Join(dir, "language.yaml"), &lang); err != nil {
		return nil, err
	}

	grammarFiles, _ := filepath.Glob(filepath.Join(dir, "grammar", "*.md"))
	for _, path := range grammarFiles {
		topic, err := loadGrammar(path)
		if err != nil {
			return nil, err
		}
		lang.Grammar = append(lang.Grammar, *topic)
	}
	sort.SliceStable(lang.Grammar, func(i, j int) bool { return lang.Grammar[i].Order < lang.Grammar[j].Order })

	lessonFiles, _ := filepath.Glob(filepath.Join(dir, "lessons", "*.yaml"))
	for _, path := range lessonFiles {
		var l Lesson
		if err := readYAML(path, &l); err != nil {
			return nil, err
		}
		lang.Lessons = append(lang.Lessons, l)
	}
	sort.SliceStable(lang.Lessons, func(i, j int) bool { return lang.Lessons[i].Order < lang.Lessons[j].Order })

	return &lang, nil
}

func loadGrammar(path string) (*GrammarTopic, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	front, body, err := splitFrontmatter(raw)
	if err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	var t GrammarTopic
	if err := yaml.Unmarshal(front, &t); err != nil {
		return nil, fmt.Errorf("%s: %w", path, err)
	}
	t.Body = strings.TrimSpace(string(body))
	return &t, nil
}

func splitFrontmatter(raw []byte) (front, body []byte, err error) {
	raw = bytes.ReplaceAll(raw, []byte("\r\n"), []byte("\n"))
	if !bytes.HasPrefix(raw, []byte("---\n")) {
		return nil, nil, errors.New("falta el frontmatter (--- al principio)")
	}
	rest := raw[4:]
	end := bytes.Index(rest, []byte("\n---\n"))
	if end < 0 {
		return nil, nil, errors.New("el frontmatter no está cerrado con ---")
	}
	return rest[:end], rest[end+5:], nil
}

func readYAML(path string, v any) error {
	raw, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	dec := yaml.NewDecoder(bytes.NewReader(raw))
	dec.KnownFields(true)
	if err := dec.Decode(v); err != nil {
		return fmt.Errorf("%s: %w", path, err)
	}
	return nil
}

func hashBundle(b *Bundle) (string, error) {
	raw, err := json.Marshal(b.Languages)
	if err != nil {
		return "", err
	}
	sum := sha256.Sum256(raw)
	return hex.EncodeToString(sum[:])[:12], nil
}
