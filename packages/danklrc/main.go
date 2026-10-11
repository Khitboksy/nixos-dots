// danklrc fetches song lyrics through github.com/AvengeMedia/dankgo/lyrics
// (the "danklyrics" engine behind DankMaterialShell) and writes an .lrc file
// to the path rmpc expects, with [ti:]/[ar:]/[al:] headers so rmpc's lyric
// index can also match it by tags. When the winner carries word timings, a
// word-timed <stem>.lyricsfile.yaml sidecar is written next to it; rmpc
// prefers the sidecar, and line-only results leave no sidecar behind.
//
// It races all default providers (BetterLyrics, Unison, LyricsPlus, KuGou,
// LRCLIB, YouTube Music) with dankgo's disk cache, sidecar lookup, and rate
// limiting, then serializes the winner to plain line-synced LRC.
//
// Exit codes:
//
//	0  lyrics written to -out
//	1  no lyrics found for this candidate
//	2  usage, lookup, or write error
//	3  provider marked the track instrumental (nothing written)
package main

import (
	"context"
	"flag"
	"fmt"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/AvengeMedia/dankgo/lyrics"
)

const (
	exitWritten      = 0
	exitMiss         = 1
	exitError        = 2
	exitInstrumental = 3
)

func main() {
	title := flag.String("title", "", "track title")
	artist := flag.String("artist", "", "track artist")
	album := flag.String("album", "", "track album")
	duration := flag.Int("duration", 0, "track duration in whole seconds (0 = unknown)")
	file := flag.String("file", "", "absolute path to the audio file (enables sidecar lookup)")
	out := flag.String("out", "", "path of the .lrc file to write")

	flag.Parse()

	if *title == "" || *artist == "" || *out == "" {
		fmt.Fprintln(os.Stderr, "usage: danklrc -title T -artist A -out FILE [-album B] [-duration SECS] [-file PATH]")
		os.Exit(exitError)
	}

	client := lyrics.New(lyrics.Options{
		UserAgent: "danklrc/0.1 (+https://github.com/AvengeMedia/dankgo)",
	})

	req := lyrics.Request{
		Title:  *title,
		Artist: *artist,
		Album:  *album,
	}
	if *duration > 0 {
		req.Duration = time.Duration(*duration) * time.Second
	}
	if *file != "" {
		if abs, err := filepath.Abs(*file); err == nil {
			req.FileURL = (&url.URL{Scheme: "file", Path: abs}).String()
		}
	}

	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()

	result, err := client.Lookup(ctx, req)
	if err != nil {
		fmt.Fprintln(os.Stderr, "lookup failed:", err)
		os.Exit(exitError)
	}
	if !result.Found {
		fmt.Fprintf(os.Stderr, "no lyrics: %s - %s\n", *artist, *title)
		os.Exit(exitMiss)
	}
	if result.Instrumental {
		fmt.Fprintf(os.Stderr, "instrumental: %s - %s\n", *artist, *title)
		os.Exit(exitInstrumental)
	}

	body := render(result)
	if strings.TrimSpace(body) == "" {
		fmt.Fprintf(os.Stderr, "empty lyrics: %s - %s\n", *artist, *title)
		os.Exit(exitMiss)
	}

	content := headers(*title, *artist, *album) + body
	if err := writeAtomic(*out, content); err != nil {
		fmt.Fprintln(os.Stderr, "write failed:", err)
		os.Exit(exitError)
	}

	// Word timings go into a sidecar next to the .lrc. A failure only warns:
	// the .lrc is already in place and line-synced lyrics still work.
	if err := writeSidecar(result.Synced, *out, *title, *artist, *album, time.Duration(*duration)*time.Second); err != nil {
		fmt.Fprintln(os.Stderr, "sidecar write failed:", err)
	}

	fmt.Fprintf(os.Stderr, "source=%s cached=%v synced=%d plain=%d -> %s\n",
		result.Source, result.Cached, len(result.Synced), len(result.Plain), *out)
	os.Exit(exitWritten)
}

// headers mirrors the format the shell fetcher always wrote: rmpc's LrcIndex
// parses these for tag-based matching (fallback to filename lookup).
func headers(title, artist, album string) string {
	var b strings.Builder
	fmt.Fprintf(&b, "[ti: %s]\n", title)
	fmt.Fprintf(&b, "[ar: %s]\n", artist)
	if album != "" && album != title {
		fmt.Fprintf(&b, "[al: %s]\n", album)
	}
	b.WriteString("\n")
	return b.String()
}

// render serializes the result to LRC body text. Synced lines become
// [mm:ss.xx] timestamps (line granularity is all rmpc's pane displays).
// Plain-only results keep the old fetcher's behavior and go out as raw text.
func render(result *lyrics.Result) string {
	if len(result.Synced) == 0 {
		return result.Plain
	}

	multiVoice := len(result.Voices) > 1
	var b strings.Builder
	for _, line := range result.Synced {
		text := strings.TrimSpace(line.Text)
		if text == "" {
			continue
		}
		if line.Background {
			text = "(" + text + ")"
		}
		if multiVoice {
			if name := result.Voices[line.Voice].Name; name != "" {
				text = name + ": " + text
			}
		}
		d := line.Start.Duration()
		fmt.Fprintf(&b, "[%02d:%02d.%02d] %s\n",
			int(d.Minutes()), int(d.Seconds())%60, (d.Milliseconds()%1000)/10, text)
	}
	return b.String()
}

// sidecarPathFor maps the .lrc target onto the lyricsfile sidecar rmpc looks
// for first: same directory, same stem, .lyricsfile.yaml appended.
func sidecarPathFor(out string) string {
	return strings.TrimSuffix(out, filepath.Ext(out)) + ".lyricsfile.yaml"
}

// hasWordTimings reports whether any line carries word-level timing: the
// condition for a sidecar to exist at all.
func hasWordTimings(lines []lyrics.Line) bool {
	for _, line := range lines {
		if len(line.Words) > 0 {
			return true
		}
	}
	return false
}

// writeSidecar renders the word-timed lyricsfile next to out and renames it
// into place. When the result carries no word timings, any existing sidecar
// is removed so stale words cannot shadow the fresh .lrc (rmpc prefers
// sidecars). Encoding is upstream's AsLyricsfile, so the sidecar shape
// always matches what ParseLyricsfile expects.
func writeSidecar(lines []lyrics.Line, out, title, artist, album string, duration time.Duration) error {
	path := sidecarPathFor(out)
	if !hasWordTimings(lines) {
		if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
			return err
		}
		return nil
	}
	// render() skips whitespace-only lines; keep the sidecar aligned so both
	// files describe the same set of lines.
	synced := make([]lyrics.Line, 0, len(lines))
	for _, line := range lines {
		if strings.TrimSpace(line.Text) != "" {
			synced = append(synced, line)
		}
	}
	doc := lyrics.Lyrics{
		Title:  title,
		Artist: artist,
		Album:  album,
		Synced: synced,
	}
	if duration > 0 {
		doc.DurationMS = duration.Milliseconds()
	}
	content, err := doc.AsLyricsfile()
	if err != nil {
		return err
	}
	return writeAtomic(path, string(content))
}

// writeAtomic creates parent dirs, writes a temp file in the target
// directory, then renames it into place so rmpc's watcher never sees a
// half-written file.
func writeAtomic(path, content string) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	tmp, err := os.CreateTemp(dir, ".danklrc-*")
	if err != nil {
		return err
	}
	tmpName := tmp.Name()
	defer os.Remove(tmpName)
	if _, err := tmp.WriteString(content); err != nil {
		tmp.Close()
		return err
	}
	if err := tmp.Close(); err != nil {
		return err
	}
	return os.Rename(tmpName, path)
}
