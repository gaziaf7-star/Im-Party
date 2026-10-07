"""Scan the app for Arabic-script text (U+0600-U+06FF) that can reach the English UI."""
import os
import re
import json
import collections

ROOT = r"C:/Users/FARUQUE/Desktop/ThemesLive/Zaviro_LIVE/zaviro_app"
AR = re.compile(r'[\u0600-\u06FF]')
SKIP_DIRS = {'build', '.dart_tool', '.git', 'android', 'ios', '.vscode', 'releases', '.idea'}
SEP = '/'


def walk_files():
    for dirpath, dirnames, filenames in os.walk(ROOT):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for fn in filenames:
            if fn.endswith(('.dart', '.json', '.yaml', '.arb')) and not fn.endswith('.bak.dz'):
                yield os.path.join(dirpath, fn)


def rel(p):
    return os.path.relpath(p, ROOT).replace(os.sep, SEP)


def main():
    hits = collections.defaultdict(list)
    for p in walk_files():
        try:
            raw = open(p, encoding='utf-8').read()
        except Exception:
            continue
        text = raw
        if p.endswith('.json'):
            try:
                text = json.dumps(json.load(open(p, encoding='utf-8')),
                                  ensure_ascii=False, indent=1)
            except Exception:
                pass
        for i, line in enumerate(text.split('\n'), 1):
            if AR.search(line):
                hits[rel(p)].append((i, line.strip()))

    for f in sorted(hits, key=lambda x: -len(hits[x])):
        print('%6d  %s' % (len(hits[f]), f))
    print('TOTAL LINES: %d in %d files' % (sum(len(v) for v in hits.values()), len(hits)))


if __name__ == '__main__':
    main()
