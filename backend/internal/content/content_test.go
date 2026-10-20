package content

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestLoadRepoContent(t *testing.T) {
	b, err := Load("../../../content")
	if err != nil {
		t.Fatalf("el contenido del repo no valida:\n%v", err)
	}
	if len(b.Languages) != 3 {
		t.Fatalf("esperaba 3 idiomas, hay %d", len(b.Languages))
	}
	if len(b.Version) != 12 {
		t.Errorf("versión inesperada %q", b.Version)
	}
}

func TestValidateReportsAllProblems(t *testing.T) {
	b := &Bundle{Languages: []Language{{
		Code: "xx", Name: "Test",
		Groups:  []Group{{ID: "g"}},
		Grammar: []GrammarTopic{{ID: "t", Title: "T", Group: "otro", Body: "x"}},
		Lessons: []Lesson{{
			ID: "l", Title: "L", Explain: "x",
			Grammar:  []string{"no-existe"},
			Practice: []Exercise{{Type: "write", Prompt: "p"}, {Type: "raro", Prompt: "p"}},
			Mission:  Mission{Kind: "speak"},
		}},
	}}}

	err := b.Validate()
	if err == nil {
		t.Fatal("esperaba errores")
	}
	for _, want := range []string{`grupo "otro"`, `"no-existe"`, "necesita answers", `tipo "raro"`, "misión sin título"} {
		if !strings.Contains(err.Error(), want) {
			t.Errorf("falta el error %q en:\n%v", want, err)
		}
	}
}

func TestFrontmatterRequired(t *testing.T) {
	dir := t.TempDir()
	lang := filepath.Join(dir, "xx")
	os.MkdirAll(filepath.Join(lang, "grammar"), 0o755)
	os.WriteFile(filepath.Join(lang, "language.yaml"), []byte("code: xx\nname: X\n"), 0o644)
	os.WriteFile(filepath.Join(lang, "grammar", "a.md"), []byte("# sin frontmatter\n"), 0o644)

	if _, err := Load(dir); err == nil || !strings.Contains(err.Error(), "frontmatter") {
		t.Fatalf("esperaba error de frontmatter, obtuve %v", err)
	}
}
