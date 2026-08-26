import os
import fitz  # PyMuPDF

def md_to_pdf(md_path, pdf_path, title_text):
    if not os.path.exists(md_path):
        print(f"File not found: {md_path}")
        return

    with open(md_path, 'r', encoding='utf-8') as f:
        content = f.read()

    doc = fitz.open()
    rect = fitz.Rect(50, 50, 560, 790)
    page = doc.new_page()
    
    # Header title
    page.insert_text(fitz.Point(50, 35), title_text, fontsize=10, fontname="helv", color=(0.4, 0.4, 0.4))
    page.draw_line(fitz.Point(50, 42), fitz.Point(560, 42), color=(0.8, 0.8, 0.8), width=0.5)

    y = 60
    lines = content.splitlines()

    for line in lines:
        if y > 770:
            page = doc.new_page()
            page.insert_text(fitz.Point(50, 35), title_text, fontsize=10, fontname="helv", color=(0.4, 0.4, 0.4))
            page.draw_line(fitz.Point(50, 42), fitz.Point(560, 42), color=(0.8, 0.8, 0.8), width=0.5)
            y = 60

        text = line.rstrip()
        
        if text.startswith('# '):
            y += 10
            page.insert_text(fitz.Point(50, y), text[2:], fontsize=18, fontname="helv", color=(0.1, 0.3, 0.6))
            y += 22
        elif text.startswith('## '):
            y += 8
            page.insert_text(fitz.Point(50, y), text[3:], fontsize=14, fontname="helv", color=(0.2, 0.4, 0.7))
            y += 18
        elif text.startswith('### '):
            y += 6
            page.insert_text(fitz.Point(50, y), text[4:], fontsize=12, fontname="helv", color=(0.2, 0.2, 0.2))
            y += 15
        elif text.startswith('---'):
            y += 5
            page.draw_line(fitz.Point(50, y), fitz.Point(560, y), color=(0.85, 0.85, 0.85), width=0.5)
            y += 10
        elif text.startswith('```') or text.startswith('  ') or text.startswith(';') or text.startswith('Interface') or text.startswith('Structure') or text.startswith('Procedure') or text.startswith('DataSection'):
            page.insert_text(fitz.Point(60, y), text, fontsize=8.5, fontname="courier", color=(0.1, 0.1, 0.1))
            y += 12
        elif text.strip() == "":
            y += 6
        else:
            page.insert_text(fitz.Point(50, y), text, fontsize=9.5, fontname="helv", color=(0.15, 0.15, 0.15))
            y += 13

    doc.save(pdf_path)
    print(f"Successfully created: {pdf_path}")

if __name__ == "__main__":
    base_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    doc_dir = os.path.join(base_dir, "doc")

    fr_md = os.path.join(doc_dir, "PB_OOP_manuel_FR.md")
    fr_pdf = os.path.join(doc_dir, "PB_OOP_manuel_FR.pdf")

    en_md = os.path.join(doc_dir, "PB_OOP_manual_EN.md")
    en_pdf = os.path.join(doc_dir, "PB_OOP_manual_EN.pdf")

    md_to_pdf(fr_md, fr_pdf, "PureBasic OOP - Manuel de Reference (FR)")
    md_to_pdf(en_md, en_pdf, "PureBasic OOP - Reference Manual (EN)")
