"""Build an editable Markdown report into PDF; not an app runtime dependency.

Requires Python 3 and reportlab. Supply docs/identitas.json to complete the cover.
logo_fakultas must point to an imported local faculty logo, relative to docs/.
"""

import json
from pathlib import Path
import re
import textwrap
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_JUSTIFY
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Image, KeepTogether, PageBreak, Paragraph, Preformatted,
    SimpleDocTemplate, Spacer,
)


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / 'docs'


def main():
    identity_path = DOCS / 'identitas.json'
    identity = json.loads(identity_path.read_text()) if identity_path.exists() else {}
    required = ['nama', 'nim', 'jurusan', 'fakultas', 'perguruan_tinggi']
    logo_path = DOCS / identity.get('logo_fakultas', '')
    complete = all(identity.get(key, '').strip() for key in required) and logo_path.is_file()
    output = DOCS / ('Laporan_UTS_MONO_Store.pdf' if complete else 'Laporan_UTS_MONO_Store_DRAF.pdf')

    font_dir = Path('/usr/share/fonts/truetype/dejavu')
    for name, filename in [('DejaVu', 'DejaVuSans.ttf'), ('DejaVuBold', 'DejaVuSans-Bold.ttf'), ('DejaVuMono', 'DejaVuSansMono.ttf')]:
        pdfmetrics.registerFont(TTFont(name, str(font_dir / filename)))
    pdfmetrics.registerFontFamily('DejaVu', normal='DejaVu', bold='DejaVuBold')
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle('BodyID', fontName='DejaVu', fontSize=10, leading=16, alignment=TA_JUSTIFY, spaceAfter=9))
    styles.add(ParagraphStyle('TitleID', fontName='DejaVuBold', fontSize=18, leading=27, alignment=TA_CENTER, spaceAfter=18))
    styles.add(ParagraphStyle('ChapterID', fontName='DejaVuBold', fontSize=14, leading=21, alignment=TA_CENTER, spaceAfter=18))
    styles.add(ParagraphStyle('SectionID', fontName='DejaVuBold', fontSize=11, leading=17, spaceBefore=10, spaceAfter=8, keepWithNext=True))
    styles.add(ParagraphStyle('CenterID', fontName='DejaVu', fontSize=11, leading=19, alignment=TA_CENTER, spaceAfter=9))
    styles.add(ParagraphStyle('CaptionID', fontName='DejaVu', fontSize=8.5, leading=13, alignment=TA_CENTER, spaceAfter=16))
    styles.add(ParagraphStyle('CodeID', fontName='DejaVuMono', fontSize=7.5, leading=10.5, backColor=colors.HexColor('#f2f2f2'), borderPadding=7, spaceBefore=5, spaceAfter=12))
    styles.add(ParagraphStyle('BulletID', parent=styles['BodyID'], leftIndent=13, firstLineIndent=-9))

    def paragraph(text, style='BodyID'):
        text = escape(text)
        text = re.sub(r'\*\*(.*?)\*\*', r'<b>\1</b>', text)
        return Paragraph(text, styles[style])

    story = [Spacer(1, 1.3 * cm)]
    story.append(paragraph('LAPORAN UJIAN TENGAH SEMESTER', 'TitleID'))
    story.append(paragraph('PEMROGRAMAN MOBILE', 'TitleID'))
    story.append(paragraph('MONO Store<br/>Katalog Produk Berbasis API DummyJSON'.replace('<br/>', ' — '), 'CenterID'))
    story.append(Spacer(1, 1.0 * cm))
    if complete:
        logo = Image(str(logo_path))
        logo._restrictSize(4 * cm, 4 * cm)
        story.append(logo)
    else:
        story.append(paragraph('[LOGO FAKULTAS BELUM DIBERIKAN]', 'CenterID'))
        story.append(paragraph('DRAF — identitas dan logo fakultas harus dilengkapi', 'CenterID'))
    story.append(Spacer(1, 1.1 * cm))
    for key, label in [('nama', 'Nama'), ('nim', 'NIM'), ('jurusan', 'Jurusan'), ('fakultas', 'Fakultas'), ('perguruan_tinggi', 'Perguruan tinggi')]:
        story.append(paragraph(f'{label}: {identity.get(key) or "[BELUM DIISI]"}', 'CenterID'))
    story.extend([Spacer(1, .9 * cm), paragraph('2026', 'CenterID'), PageBreak()])

    if not complete:
        story.append(paragraph('STATUS DOKUMEN', 'ChapterID'))
        story.append(paragraph('Draf ini mendokumentasikan implementasi dan pengujian aplikasi. Identitas mahasiswa dan logo fakultas belum diberikan, sehingga cover belum memenuhi ketentuan pengumpulan. Jangan menganggap dokumen ini sebagai laporan final yang siap dikumpulkan.'))
        story.append(paragraph('Lengkapi docs/identitas.json menggunakan format identitas.contoh.json, simpan logo fakultas resmi sebagai berkas lokal, lalu jalankan python3 tool/build_report.py. Periksa hasil PDF dan kesesuaiannya dengan aplikasi sebelum diunggah ke Google Drive.'))
        story.append(PageBreak())

    lines = (DOCS / 'LAPORAN_UTS.md').read_text().splitlines()
    # Cover and document status above are rendered explicitly.
    start = next(i for i, line in enumerate(lines) if line.startswith('## BAB I.'))
    i = start
    first_chapter = True
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            i += 1
            continue
        if line.startswith('```'):
            code = []
            i += 1
            while i < len(lines) and not lines[i].startswith('```'):
                code.extend(textwrap.wrap(lines[i], width=88, replace_whitespace=False, drop_whitespace=False) or [''])
                i += 1
            story.append(Preformatted('\n'.join(code), styles['CodeID']))
            i += 1
            continue
        image = re.fullmatch(r'!\[(.*)\]\((.*)\)', line)
        if image:
            caption, path = image.groups()
            figure_path = DOCS / path
            if not figure_path.is_file():
                raise FileNotFoundError(f'Missing screenshot: {figure_path}')
            figure = Image(str(figure_path))
            figure._restrictSize(6.7 * cm, 14.5 * cm)
            story.append(KeepTogether([Spacer(1, 6), figure, Spacer(1, 7), paragraph(caption, 'CaptionID')]))
            i += 1
            continue
        if line.startswith('## '):
            if not first_chapter:
                story.append(PageBreak())
            first_chapter = False
            story.append(paragraph(line[3:], 'ChapterID'))
            i += 1
            continue
        if line.startswith('### '):
            story.append(paragraph(line[4:], 'SectionID'))
            i += 1
            continue
        if line.startswith('- '):
            story.append(paragraph('• ' + line[2:], 'BulletID'))
            i += 1
            continue
        parts = [line]
        i += 1
        while i < len(lines) and lines[i].strip() and not lines[i].startswith(('#', '-', '```', '![')):
            parts.append(lines[i].strip())
            i += 1
        story.append(paragraph(' '.join(parts)))

    def footer(canvas, document):
        canvas.saveState()
        canvas.setFont('DejaVu', 8)
        canvas.setFillColor(colors.HexColor('#555555'))
        canvas.drawString(2.5 * cm, 1.3 * cm, 'MONO Store | UTS Pemrograman Mobile' + (' | DRAF' if not complete else ''))
        canvas.drawRightString(A4[0] - 2.5 * cm, 1.3 * cm, str(document.page))
        canvas.restoreState()

    document = SimpleDocTemplate(
        str(output), pagesize=A4,
        rightMargin=2.5 * cm, leftMargin=2.5 * cm,
        topMargin=2.2 * cm, bottomMargin=2.2 * cm,
        title='Laporan UTS MONO Store' + (' — DRAF' if not complete else ''),
        author=identity.get('nama') or 'Identitas belum diisi',
    )
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    print(f'PDF: {output}')
    print('Cover complete:', complete)


if __name__ == '__main__':
    main()
