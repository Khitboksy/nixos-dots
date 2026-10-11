package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"github.com/AvengeMedia/dankgo/lyrics"
)

func TestSidecarPathFor(t *testing.T) {
	got := sidecarPathFor("/lyrics/Artist/Album/01 - Song.lrc")
	want := "/lyrics/Artist/Album/01 - Song.lyricsfile.yaml"
	if got != want {
		t.Fatalf("sidecarPathFor = %q, want %q", got, want)
	}
}

func TestWriteSidecarRoundTrip(t *testing.T) {
	lines := []lyrics.Line{
		{
			Start: 1.5,
			End:   4.25,
			Text:  "Hello world",
			Words: []lyrics.Word{
				{Start: 1.5, End: 2.0, Text: "Hello"},
				{Start: 2.0, End: 4.25, Text: " world"},
			},
		},
		{Start: 5, End: 6, Text: "   "},
		{Start: 7, End: 8, Text: "no words here"},
	}

	dir := t.TempDir()
	out := filepath.Join(dir, "track.lrc")
	if err := writeSidecar(lines, out, "Test Title", "Test Artist", "Test Album", 90*time.Second); err != nil {
		t.Fatalf("writeSidecar: %v", err)
	}
	got, err := os.ReadFile(sidecarPathFor(out))
	if err != nil {
		t.Fatalf("sidecar not written: %v", err)
	}
	if !strings.Contains(string(got), "1.0") {
		t.Fatalf("version missing:\n%s", got)
	}

	// Round trip through dankgo's parser — the reference implementation of
	// the lyricsfile spec that rmpc's parser mirrors.
	parsed, err := lyrics.ParseLyricsfile(got)
	if err != nil {
		t.Fatalf("ParseLyricsfile: %v\n%s", err, got)
	}
	if parsed.Title != "Test Title" || parsed.Artist != "Test Artist" || parsed.Album != "Test Album" {
		t.Errorf("metadata = title %q artist %q album %q",
			parsed.Title, parsed.Artist, parsed.Album)
	}
	if parsed.DurationMS != 90000 {
		t.Errorf("duration_ms = %d, want 90000", parsed.DurationMS)
	}
	if len(parsed.Synced) != 2 {
		t.Fatalf("parsed synced = %d, want 2 (whitespace-only line skipped)", len(parsed.Synced))
	}
	first := parsed.Synced[0]
	if first.Text != "Hello world" {
		t.Errorf("first text = %q", first.Text)
	}
	if len(first.Words) != 2 {
		t.Fatalf("first words = %d, want 2", len(first.Words))
	}
	var concat strings.Builder
	for _, w := range first.Words {
		concat.WriteString(w.Text)
	}
	if concat.String() != first.Text {
		t.Errorf("words concat %q != line text %q", concat.String(), first.Text)
	}
	if got := first.Words[0].Start.Duration(); got != 1500*time.Millisecond {
		t.Errorf("word start = %v, want 1.5s", got)
	}
	if got := first.Words[1].End.Duration(); got != 4250*time.Millisecond {
		t.Errorf("word end = %v, want 4.25s", got)
	}
	if parsed.Synced[1].Text != "no words here" {
		t.Errorf("second text = %q", parsed.Synced[1].Text)
	}
	if len(parsed.Synced[1].Words) != 0 {
		t.Errorf("second words = %d, want 0", len(parsed.Synced[1].Words))
	}
}

func TestWriteSidecarRemovesStale(t *testing.T) {
	dir := t.TempDir()
	out := filepath.Join(dir, "track.lrc")
	stale := filepath.Join(dir, "track.lyricsfile.yaml")
	if err := os.WriteFile(stale, []byte("stale"), 0o644); err != nil {
		t.Fatal(err)
	}

	// A wordless result removes the stale sidecar so rmpc falls back to
	// the .lrc just written.
	wordless := []lyrics.Line{{Start: 1, End: 2, Text: "plain line"}}
	if err := writeSidecar(wordless, out, "T", "A", "", 0); err != nil {
		t.Fatalf("writeSidecar (wordless): %v", err)
	}
	if _, err := os.Stat(stale); !os.IsNotExist(err) {
		t.Fatalf("stale sidecar still exists (err=%v)", err)
	}

	// With words it is (re)written beside the .lrc.
	withWords := []lyrics.Line{{
		Start: 1, End: 2, Text: "hi",
		Words: []lyrics.Word{{Start: 1, End: 2, Text: "hi"}},
	}}
	if err := writeSidecar(withWords, out, "T", "A", "", 0); err != nil {
		t.Fatalf("writeSidecar (words): %v", err)
	}
	got, err := os.ReadFile(stale)
	if err != nil {
		t.Fatalf("sidecar not written: %v", err)
	}
	if !strings.Contains(string(got), "hi") {
		t.Fatalf("sidecar content unexpected:\n%s", got)
	}
}
