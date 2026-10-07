"""Classify Arabic-script occurrences by bug class.

(a) Arabic StringManager constant  -> becomes the English fallback string (key == display text)
(b) Arabic value inside a NON-Arabic locale map
(c) Arabic literal hardcoded in dart code (widget/model/etc.)
(d) Arabic inside asset JSON
(z) Arabic in a comment only -> not user visible
"""
import os
import re
import json
import collections

ROOT = r"C:/Users/FARUQUE/Desktop/ThemesLive/Zaviro_LIVE/zaviro_app"
AR = re.compile(r'[\u0600-\u06FF]')
SKIP_DIRS = {'build', '.dart_tool', '.git', 'android', 'ios', '.vscode', 'releases', '.idea'}
LOCALE_FILE = 'lib/src/core/translations/locale_keys.g.dart'
SM_FILE = 'lib/src/core/constants/string_manager.dart'

STR_LIT = re.compile(
    r"""r?'''(?:[^\\]|\\.)*?'''|r?\"\"\"(?:[^\\]|\\.)*?\"\"\"|r?'(?:[^'\\\n]|\\.)*'|r?\"(?:[^\"\\\n]|\\.)*\"""",
    re.S)


def rel(p):
    return os.path.relpath(p, ROOT).replace(os.sep, '/')


def walk(exts):
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if fn.endswith(exts) and not fn.endswith('.bak.dz'):
                yield os.path.join(dirpath, fn)


def strip_comments(src):
    """Replace comment bodies with spaces, preserving offsets. Returns (code, comment_spans)."""
    out = list(src)
    comments = []
    i, n = 0, len(src)
    while i < n:
        c = src[i]
        if c in "'\"":
            m = STR_LIT.match(src, i)
            if m:
                i = m.end()
                continue
            i += 1
            continue
        if c == '/' and i + 1 < n:
            if src[i + 1] == '/':
                j = src.find('\n', i)
                j = n if j < 0 else j
                comments.append((i, j))
                for k in range(i, j):
                    out[k] = ' '
                i = j
                continue
            if src[i + 1] == '*':
                j = src.find('*/', i + 2)
                j = n if j < 0 else j + 2
                comments.append((i, j))
                for k in range(i, j):
                    if out[k] != '\n':
                        out[k] = ' '
                i = j
                continue
        i += 1
    return ''.join(out), comments


def line_of(src, pos):
    return src.count('\n', 0, pos) + 1


# ---------------------------------------------------------------- locale maps
def locale_regions(src):
    """Return list of (locale, start, end) for each `static ... Map ... _xx = {`."""
    marks = [(m.group(1), m.end())
             for m in re.finditer(r'Map<String,\s*dynamic>\s+_(\w+)\s*=\s*\{', src)]
    regions = []
    for idx, (loc, start) in enumerate(marks):
        end = marks[idx + 1][1] if idx + 1 < len(marks) else len(src)
        regions.append((loc, start, end))
    return regions


def scan_locale_file():
    path = os.path.join(ROOT, LOCALE_FILE)
    src = open(path, encoding='utf-8').read()
    code, _ = strip_comments(src)
    res = collections.defaultdict(lambda: {'key': [], 'value': []})
    for loc, start, end in locale_regions(code):
        chunk = code[start:end]
        # entries look like `    <keyexpr>: <value>,` possibly wrapped
        for m in re.finditer(r'(?m)^ {4}(.+?):\s*(.*?)(?=\n {4}\S|\n\s*\};)', chunk, re.S):
            keyexpr, val = m.group(1), m.group(2)
            pos = start + m.start()
            ln = line_of(code, pos)
            if AR.search(keyexpr):
                res[loc]['key'].append((ln, keyexpr.strip(), val.strip()[:60]))
            if AR.search(val):
                res[loc]['value'].append((ln, keyexpr.strip(), val.strip()[:60]))
    return res, src


# ---------------------------------------------------------------- generic dart
def scan_dart():
    lit_hits = collections.defaultdict(list)      # class c (or a for string_manager)
    comment_hits = collections.defaultdict(list)  # class z
    for p in walk(('.dart',)):
        r = rel(p)
        if r == LOCALE_FILE:
            continue
        try:
            src = open(p, encoding='utf-8').read()
        except Exception:
            continue
        if not AR.search(src):
            continue
        code, comments = strip_comments(src)
        for m in STR_LIT.finditer(code):
            if AR.search(m.group(0)):
                lit_hits[r].append((line_of(code, m.start()), m.group(0).strip()))
        for (a, b) in comments:
            seg = src[a:b]
            if AR.search(seg):
                comment_hits[r].append((line_of(src, a), seg.strip()[:90]))
    return lit_hits, comment_hits


def scan_json():
    hits = collections.defaultdict(list)
    for p in walk(('.json', '.arb')):
        try:
            obj = json.load(open(p, encoding='utf-8'))
        except Exception:
            continue
        text = json.dumps(obj, ensure_ascii=False, indent=1)
        if AR.search(text):
            for i, line in enumerate(text.split('\n'), 1):
                if AR.search(line):
                    hits[rel(p)].append((i, line.strip()))
    return hits


def distinct(seq):
    return len({s for _, s in seq})


def main():
    print('=' * 78)
    print('CLASS (a)/(b): locale_keys.g.dart  (Arabic in KEY position vs VALUE position)')
    print('=' * 78)
    loc, _ = scan_locale_file()
    for lc in ['ar', 'tr', 'ur', 'hi', 'id', 'en']:
        d = loc.get(lc)
        if not d:
            continue
        print('  _%-3s  arabic-in-KEY: %5d   arabic-in-VALUE: %5d' %
              (lc, len(d['key']), len(d['value'])))
        for ln, k, v in d['key'][:6]:
            print('        KEY  L%-6d %s : %s' % (ln, k[:60], v[:40]))

    print()
    print('=' * 78)
    print('CLASS (a)/(c): Arabic string LITERALS in dart code')
    print('=' * 78)
    lits, comms = scan_dart()
    tot = 0
    for f in sorted(lits, key=lambda x: -len(lits[x])):
        n = len(lits[f])
        tot += n
        print('%5d occ / %3d distinct   %s' % (n, distinct(lits[f]), f))
    print('TOTAL literal occurrences: %d  distinct: %d  files: %d' %
          (tot, len({s for v in lits.values() for _, s in v}), len(lits)))

    print()
    print('--- Arabic in COMMENTS only (class z, not user visible) ---')
    tc = 0
    for f in sorted(comms, key=lambda x: -len(comms[x])):
        tc += len(comms[f])
        print('%5d  %s' % (len(comms[f]), f))
    print('TOTAL comment occurrences: %d' % tc)

    print()
    print('=' * 78)
    print('CLASS (d): asset JSON')
    print('=' * 78)
    js = scan_json()
    for f, v in js.items():
        print('%5d  %s' % (len(v), f))
    if not js:
        print('  none')


if __name__ == '__main__':
    main()
