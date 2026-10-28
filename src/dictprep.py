#!/usr/bin/python
# -*- coding: utf-8 -*-
# MeeTranslate: turns a downloaded WikDict file into a small lookup database
# (only the simple_translation table, with a case-insensitive index).
# Usage: dictprep.py DOWNLOADED.sqlite3 TARGET.sqlite3

import os
import sys
import sqlite3


def main():
    src, dst = sys.argv[1], sys.argv[2]
    tmp = dst + '.tmp'
    if os.path.exists(tmp):
        os.remove(tmp)
    db = sqlite3.connect(tmp)
    db.execute("ATTACH DATABASE ? AS src", (src,))
    db.execute("CREATE TABLE simple_translation(written_rep TEXT, trans_list TEXT, "
               "max_score REAL, rel_importance REAL)")
    db.execute("INSERT INTO simple_translation SELECT written_rep, trans_list, max_score, "
               "rel_importance FROM src.simple_translation")
    db.commit()
    db.execute("DETACH DATABASE src")
    db.execute("CREATE INDEX word_nocase ON simple_translation(written_rep COLLATE NOCASE)")
    db.execute("CREATE INDEX word_exact ON simple_translation(written_rep)")
    count = db.execute("SELECT count(*) FROM simple_translation").fetchone()[0]
    db.commit()
    db.close()
    if count == 0:
        os.remove(tmp)
        sys.stderr.write('empty dictionary\n')
        return 2
    os.rename(tmp, dst)
    os.remove(src)
    return 0


if __name__ == '__main__':
    try:
        sys.exit(main())
    except Exception, e:
        sys.stderr.write('%s\n' % e)
        sys.exit(3)
