#!/usr/bin/env python3
"""Regenerate noto-fonts.mk for the release named by PKG_VERSION.

Usage: gen_noto.py [DOWNLOAD_DIR]

Needs the gh CLI (authenticated) and curl. The font files are fetched
to DOWNLOAD_DIR (default: a temporary directory) to compute their
sha256 sums. To bump the package, edit PKG_VERSION in the Makefile to
the new noto-monthly-release-<version> tag, run this script, reset
PKG_RELEASE and build. A family that is new upstream has to be added
to one group in GROUPS first.
"""

import collections
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
import urllib.parse
from concurrent.futures import ThreadPoolExecutor

REPO = 'notofonts/notofonts.github.io'
SKIP_FAMILIES = ('NotoSansTest', 'NotoSerifTest')
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, 'noto-fonts.mk')

# A script without a living user community is in "historic" whatever its
# region.
GROUPS = (
    ('core', 'Noto Sans, Serif and Sans Mono for Latin, Greek and Cyrillic', '''
        NotoSans NotoSansMono NotoSerif
    '''),
    ('extra', 'Noto Serif Display, SignWriting, Duployan and Shavian', '''
        NotoSansDuployan NotoSansShavian NotoSansSignWriting
        NotoSerifDisplay
    '''),
    ('symbols', 'Noto symbols, mathematics and music notation', '''
        NotoMusic NotoSansMath NotoSansSymbols NotoSansSymbols2
        NotoZnamennyMusicalNotation
    '''),
    ('west-asia', 'Noto fonts for West Asian scripts, including Arabic', '''
        NotoKufiArabic NotoNaskhArabic NotoNaskhArabicUI NotoRashiHebrew
        NotoSansArabic NotoSansArabicUI NotoSansArmenian NotoSansGeorgian
        NotoSansHebrew NotoSansMandaic NotoSansSamaritan NotoSansSyriac
        NotoSansSyriacEastern NotoSansSyriacWestern NotoSerifArmenian
        NotoSerifGeorgian NotoSerifHebrew NotoSerifYezidi
    '''),
    ('africa-americas', 'Noto fonts for African and American scripts', '''
        NotoSansAdlam NotoSansAdlamUnjoined NotoSansBamum NotoSansBassaVah
        NotoSansCanadianAboriginal NotoSansCherokee NotoSansCoptic
        NotoSansEthiopic NotoSansMedefaidrin NotoSansMendeKikakui
        NotoSansNKo NotoSansNKoUnjoined NotoSansOsage NotoSansOsmanya
        NotoSansTifinagh NotoSansVai NotoSerifEthiopic
    '''),
    ('south-asia', 'Noto fonts for South and Central Asian scripts', '''
        NotoNastaliqUrdu NotoSansBengali NotoSansChakma NotoSansDevanagari NotoSansGujarati
        NotoSansGunjalaGondi NotoSansGurmukhi NotoSansKannada
        NotoSansLepcha NotoSansLimbu NotoSansMalayalam NotoSansMasaramGondi
        NotoSansMeeteiMayek NotoSansMongolian NotoSansMro
        NotoSansNagMundari NotoSansNewa NotoSansOlChiki NotoSansOriya
        NotoSansSaurashtra NotoSansSinhala NotoSansSoraSompeng
        NotoSansSunuwar NotoSansSylotiNagri NotoSansTamil
        NotoSansTamilSupplement NotoSansTelugu NotoSansThaana NotoSansWancho
        NotoSansWarangCiti NotoSerifBengali NotoSerifDevanagari
        NotoSerifGujarati NotoSerifGurmukhi NotoSerifKannada
        NotoSerifMalayalam NotoSerifOriya NotoSerifSinhala NotoSerifTamil
        NotoSerifTelugu NotoSerifTibetan NotoSerifToto
    '''),
    ('southeast-asia',
     'Noto fonts for South-East Asian, Yi, Lisu and Miao scripts', '''
        NotoSansBalinese NotoSansBatak NotoSansBuginese NotoSansBuhid
        NotoSansCham NotoSansHanifiRohingya NotoSansHanunoo
        NotoSansJavanese NotoSansKayahLi NotoSansKhmer NotoSansLao
        NotoSansLaoLooped NotoSansLisu NotoSansMiao NotoSansMyanmar
        NotoSansNewTaiLue NotoSansPahawhHmong NotoSansPauCinHau
        NotoSansRejang NotoSansSundanese NotoSansTagalog NotoSansTagbanwa
        NotoSansTaiLe NotoSansTaiTham NotoSansTaiViet NotoSansTangsa
        NotoSansThai NotoSansThaiLooped NotoSansYi NotoSerifBalinese
        NotoSerifKhmer NotoSerifLao NotoSerifMyanmar NotoSerifNPHmong
        NotoSerifThai
    '''),
    ('historic', 'Noto fonts for historic scripts and numerals', '''
        NotoFangsongKSSRotated NotoFangsongKSSVertical
        NotoSansAnatolianHieroglyphs NotoSansAvestan NotoSansBhaiksuki
        NotoSansBrahmi NotoSansCarian NotoSansCaucasianAlbanian
        NotoSansChorasmian NotoSansCuneiform NotoSansCypriot
        NotoSansCyproMinoan NotoSansDeseret NotoSansEgyptianHieroglyphs
        NotoSansElbasan NotoSansElymaic NotoSansGlagolitic NotoSansGothic
        NotoSansGrantha NotoSansHatran NotoSansImperialAramaic
        NotoSansIndicSiyaqNumbers NotoSansInscriptionalPahlavi
        NotoSansInscriptionalParthian NotoSansKaithi NotoSansKawi
        NotoSansKharoshthi NotoSansKhojki NotoSansKhudawadi NotoSansLinearA
        NotoSansLinearB NotoSansLycian NotoSansLydian NotoSansMahajani
        NotoSansManichaean NotoSansMarchen NotoSansMayanNumerals
        NotoSansMeroitic NotoSansModi NotoSansMultani NotoSansNabataean
        NotoSansNandinagari NotoSansNushu NotoSansOgham
        NotoSansOldHungarian NotoSansOldItalic NotoSansOldNorthArabian
        NotoSansOldPermic NotoSansOldPersian NotoSansOldSogdian
        NotoSansOldSouthArabian NotoSansOldTurkic NotoSansPalmyrene
        NotoSansPhagsPa NotoSansPhoenician NotoSansPsalterPahlavi
        NotoSansRunic NotoSansSharada NotoSansSiddham NotoSansSogdian
        NotoSansSoyombo NotoSansTakri NotoSansTirhuta NotoSansUgaritic
        NotoSansVithkuqi NotoSansZanabazarSquare NotoSerifAhom
        NotoSerifDivesAkuru NotoSerifDogra NotoSerifGrantha
        NotoSerifHentaigana NotoSerifKhitanSmallScript NotoSerifKhojki
        NotoSerifMakasar NotoSerifOldUyghur NotoSerifOttomanSiyaq
        NotoSerifTangut NotoSerifTodhri NotoSerifVithkuqi
        NotoTraditionalNushu
    '''),
)


def version_get():
    with open(os.path.join(HERE, 'Makefile')) as f:
        m = re.search(r'^PKG_VERSION:=(\S+)$', f.read(), re.M)
    return m.group(1)


def tree_get(tag):
    out = subprocess.check_output(
        ['gh', 'api', 'repos/%s/git/trees/%s?recursive=1' % (REPO, tag)])
    tree = json.loads(out)
    assert not tree['truncated']
    return tree['tree']


def families_get(entries):
    fam = collections.defaultdict(lambda: collections.defaultdict(list))
    for e in entries:
        if e['type'] != 'blob':
            continue
        p = e['path'].split('/')
        if len(p) != 5 or p[0] != 'fonts' or p[2] != 'googlefonts':
            continue
        if p[3] not in ('ttf', 'variable-ttf') or p[1] in SKIP_FAMILIES:
            continue
        fam[p[1]][p[3]].append((p[4], e['size']))
    return fam


def groups_check(fam):
    grouped = [f for _, _, families in GROUPS for f in families.split()]
    dup = sorted(f for f, n in collections.Counter(grouped).items() if n > 1)
    assert not dup, 'in more than one group: %s' % ' '.join(dup)
    new = sorted(set(fam) - set(grouped))
    assert not new, 'not in any group: %s' % ' '.join(new)
    gone = sorted(set(grouped) - set(fam))
    assert not gone, 'not in the release: %s' % ' '.join(gone)


def family_title(family):
    s = re.sub(r'^Noto', '', family)
    return re.sub(r'(?<=[a-z0-9])(?=[A-Z])', ' ', s)


def name_local(filename):
    return filename.replace('[', '_').replace(']', '').replace(',', '_')


def sha256_get(path):
    with open(path, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()


def main():
    version = version_get()
    tag = 'noto-monthly-release-%s' % version
    raw = 'https://raw.githubusercontent.com/%s/%s/' % (REPO, tag)
    dl = sys.argv[1] if len(sys.argv) > 1 else tempfile.mkdtemp()

    fam = families_get(tree_get(tag))
    groups_check(fam)

    jobs = []
    rows = collections.OrderedDict()
    for group, _, families in GROUPS:
        for f in sorted(families.split()):
            kind = 'variable-ttf' if 'variable-ttf' in fam[f] else 'ttf'
            for fn, size in sorted(fam[f][kind]):
                dst = os.path.join(dl, f, kind, name_local(fn))
                jobs.append(('fonts/%s/googlefonts/%s/%s' % (f, kind, fn),
                             dst, size))
                rows.setdefault(group, []).append(
                    (f, kind, urllib.parse.quote(fn, safe=''),
                     name_local(fn), dst))
    license_dst = os.path.join(dl, 'fonts', 'LICENSE')
    jobs.append(('fonts/LICENSE', license_dst, None))

    def fetch(job):
        path, dst, size = job
        os.makedirs(os.path.dirname(dst), exist_ok=True)
        url = raw + urllib.parse.quote(path, safe='/')
        subprocess.check_call(['curl', '-sSfL', '--retry', '3', '-o', dst, url])
        if size is not None:
            assert os.path.getsize(dst) == size, (path, size)

    with ThreadPoolExecutor(8) as ex:
        list(ex.map(fetch, jobs))

    with open(OUT, 'w') as o:
        o.write('# Generated by gen_noto.py for %s, one NotoFile per font file.\n' % tag)
        o.write('# Per family the variable fonts are used where upstream ships them,\n')
        o.write('# otherwise the static fonts, both from googlefonts/.\n\n')
        o.write('NOTO_LICENSE_HASH:=%s\n' % sha256_get(license_dst))
        for group, title, families in GROUPS:
            o.write('\nNOTO_GROUPS+=%s\n' % group)
            o.write('NOTO_TITLE_%s:=%s\n' % (group, title))
            o.write('NOTO_FAMILIES_%s:=%s\n' % (group, ', '.join(
                family_title(f) for f in sorted(families.split()))))
            for f, kind, urlfn, loc, dst in rows[group]:
                o.write('$(eval $(call NotoFile,%s,%s,%s,%s,%s,%s))\n'
                        % (group, f, kind, urlfn, loc, sha256_get(dst)))
    print(len(jobs) - 1, 'files', len(fam), 'families', len(GROUPS), 'packages')


main()
