// Package content carga, valida y empaqueta las lecciones escritas a mano
// que viven en el directorio content/ del repo.
package content

// Bundle es todo el contenido de la app, tal como lo consume Flutter.
type Bundle struct {
	Version   string     `json:"version"`
	Languages []Language `json:"languages"`
}

type Language struct {
	Code       string         `json:"code" yaml:"code"`
	Name       string         `json:"name" yaml:"name"`
	NativeName string         `json:"nativeName" yaml:"native_name"`
	Intro      string         `json:"intro" yaml:"intro"`
	Groups     []Group        `json:"groups" yaml:"groups"`
	Grammar    []GrammarTopic `json:"grammar" yaml:"-"`
	Lessons    []Lesson       `json:"lessons" yaml:"-"`
}

// Group agrupa temas de gramática (por ejemplo "Presente", "Pasado").
type Group struct {
	ID    string `json:"id" yaml:"id"`
	Title string `json:"title" yaml:"title"`
}

// GrammarTopic es una página de referencia: se escribe en Markdown con
// frontmatter YAML.
type GrammarTopic struct {
	ID      string `json:"id" yaml:"id"`
	Title   string `json:"title" yaml:"title"`
	Group   string `json:"group" yaml:"group"`
	Order   int    `json:"order" yaml:"order"`
	Level   string `json:"level" yaml:"level"`
	Summary string `json:"summary" yaml:"summary"`
	Body    string `json:"body" yaml:"-"`
}

// Lesson es el recorrido guiado: entender, practicar y hacer algo fuera de
// la app.
type Lesson struct {
	ID       string     `json:"id" yaml:"id"`
	Title    string     `json:"title" yaml:"title"`
	Order    int        `json:"order" yaml:"order"`
	Level    string     `json:"level" yaml:"level"`
	Summary  string     `json:"summary" yaml:"summary"`
	Grammar  []string   `json:"grammar" yaml:"grammar"`
	Explain  string     `json:"explain" yaml:"explain"`
	Practice []Exercise `json:"practice" yaml:"practice"`
	Mission  Mission    `json:"mission" yaml:"mission"`
}

const (
	// ExerciseWrite tiene respuestas correctas y la app las corrige.
	ExerciseWrite = "write"
	// ExerciseOpen es producción libre: escribís y después comparás con un
	// modelo y te autoevaluás.
	ExerciseOpen = "open"
)

type Exercise struct {
	Type        string   `json:"type" yaml:"type"`
	Instruction string   `json:"instruction,omitempty" yaml:"instruction"`
	Prompt      string   `json:"prompt" yaml:"prompt"`
	Answers     []string `json:"answers,omitempty" yaml:"answers"`
	Hint        string   `json:"hint,omitempty" yaml:"hint"`
	Model       string   `json:"model,omitempty" yaml:"model"`
	Note        string   `json:"note,omitempty" yaml:"note"`
}

// Mission es la consigna para hacer fuera del teléfono.
type Mission struct {
	Kind      string   `json:"kind" yaml:"kind"`
	Title     string   `json:"title" yaml:"title"`
	Minutes   int      `json:"minutes" yaml:"minutes"`
	Task      string   `json:"task" yaml:"task"`
	Checklist []string `json:"checklist" yaml:"checklist"`
}

var missionKinds = map[string]bool{"write": true, "speak": true, "listen": true, "read": true}
