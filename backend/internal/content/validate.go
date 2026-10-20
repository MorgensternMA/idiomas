package content

import (
	"errors"
	"fmt"
	"strings"
)

// Validate junta todos los problemas del contenido en un solo error, para
// poder arreglarlos de una pasada.
func (b *Bundle) Validate() error {
	var errs []error
	add := func(format string, args ...any) { errs = append(errs, fmt.Errorf(format, args...)) }

	seenLang := map[string]bool{}
	for _, lang := range b.Languages {
		if lang.Code == "" || lang.Name == "" {
			add("idioma sin code o name")
			continue
		}
		if seenLang[lang.Code] {
			add("idioma %q duplicado", lang.Code)
		}
		seenLang[lang.Code] = true

		groups := map[string]bool{}
		for _, g := range lang.Groups {
			groups[g.ID] = true
		}

		topics := map[string]bool{}
		for _, t := range lang.Grammar {
			where := lang.Code + "/grammar/" + t.ID
			switch {
			case t.ID == "":
				add("%s: tema de gramática sin id", lang.Code)
			case topics[t.ID]:
				add("%s: id duplicado", where)
			}
			topics[t.ID] = true
			if t.Title == "" || t.Body == "" {
				add("%s: falta título o contenido", where)
			}
			if !groups[t.Group] {
				add("%s: grupo %q no está en language.yaml", where, t.Group)
			}
		}

		lessons := map[string]bool{}
		for _, l := range lang.Lessons {
			where := lang.Code + "/lessons/" + l.ID
			switch {
			case l.ID == "":
				add("%s: lección sin id", lang.Code)
			case lessons[l.ID]:
				add("%s: id duplicado", where)
			}
			lessons[l.ID] = true
			if l.Title == "" || strings.TrimSpace(l.Explain) == "" {
				add("%s: falta título o explicación", where)
			}
			for _, ref := range l.Grammar {
				if !topics[ref] {
					add("%s: referencia a gramática inexistente %q", where, ref)
				}
			}
			for i, ex := range l.Practice {
				exWhere := fmt.Sprintf("%s: ejercicio %d", where, i+1)
				if ex.Prompt == "" {
					add("%s: falta prompt", exWhere)
				}
				switch ex.Type {
				case ExerciseWrite:
					if len(ex.Answers) == 0 {
						add("%s: un ejercicio write necesita answers", exWhere)
					}
				case ExerciseOpen:
					if ex.Model == "" {
						add("%s: un ejercicio open necesita model", exWhere)
					}
				default:
					add("%s: tipo %q desconocido", exWhere, ex.Type)
				}
			}
			m := l.Mission
			if !missionKinds[m.Kind] {
				add("%s: misión con kind %q inválido", where, m.Kind)
			}
			if m.Title == "" || strings.TrimSpace(m.Task) == "" {
				add("%s: misión sin título o consigna", where)
			}
		}
	}
	return errors.Join(errs...)
}
