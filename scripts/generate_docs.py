import os
import sys
import re

def convert_md_to_pdf(md_path, pdf_path, title):
    try:
        from fpdf import FPDF
    except ImportError:
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "fpdf2"])
        from fpdf import FPDF

    class PDF(FPDF):
        def header(self):
            self.set_font('Helvetica', 'B', 12)
            self.cell(0, 10, title, border=False, align='R')
            self.ln(12)

        def footer(self):
            self.set_y(-15)
            self.set_font('Helvetica', 'I', 8)
            self.cell(0, 10, f'Page {self.page_no()}/{{nb}}', align='C')

    pdf = PDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font('Helvetica', size=10)

    if not os.path.exists(md_path):
        print(f"Error: {md_path} not found")
        return

    with open(md_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    in_code_block = False

    for line in lines:
        raw_line = line.rstrip('\r\n')
        
        if raw_line.startswith('```'):
            in_code_block = not in_code_block
            pdf.ln(2)
            continue

        if in_code_block:
            pdf.set_font('Courier', size=9)
            pdf.set_fill_color(240, 240, 240)
            # Remove any characters outside latin-1 if needed
            safe_text = raw_line.encode('latin-1', 'replace').decode('latin-1')
            pdf.cell(0, 5, safe_text, fill=True, ln=True)
            continue

        pdf.set_font('Helvetica', size=10)
        
        if raw_line.startswith('# '):
            pdf.set_font('Helvetica', 'B', 18)
            safe_text = raw_line[2:].encode('latin-1', 'replace').decode('latin-1')
            pdf.cell(0, 10, safe_text, ln=True)
            pdf.ln(2)
        elif raw_line.startswith('## '):
            pdf.set_font('Helvetica', 'B', 14)
            safe_text = raw_line[3:].encode('latin-1', 'replace').decode('latin-1')
            pdf.cell(0, 8, safe_text, ln=True)
            pdf.ln(2)
        elif raw_line.startswith('### '):
            pdf.set_font('Helvetica', 'B', 12)
            safe_text = raw_line[4:].encode('latin-1', 'replace').decode('latin-1')
            pdf.cell(0, 6, safe_text, ln=True)
            pdf.ln(1)
        elif raw_line.startswith('---'):
            pdf.set_draw_color(200, 200, 200)
            pdf.line(10, pdf.get_y(), 200, pdf.get_y())
            pdf.ln(4)
        elif raw_line.startswith('- '):
            pdf.set_font('Helvetica', size=10)
            safe_text = "  • " + raw_line[2:].encode('latin-1', 'replace').decode('latin-1')
            pdf.multi_cell(0, 5, safe_text)
        elif raw_line.strip() == "":
            pdf.ln(3)
        else:
            safe_text = raw_line.encode('latin-1', 'replace').decode('latin-1')
            pdf.multi_cell(0, 5, safe_text)

    pdf.output(pdf_path)
    print(f"Generated PDF: {pdf_path}")

if __name__ == "__main__":
    workspace_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    doc_dir = os.path.join(workspace_dir, "doc")
    
    fr_md = os.path.join(doc_dir, "PB_OOP_manuel_FR.md")
    fr_pdf = os.path.join(doc_dir, "PB_OOP_manuel_FR.pdf")
    
    en_md = os.path.join(doc_dir, "PB_OOP_manual_EN.md")
    en_pdf = os.path.join(doc_dir, "PB_OOP_manual_EN.pdf")

    convert_md_to_pdf(fr_md, fr_pdf, "PureBasic OOP - Manuel de Reference (FR)")
    convert_md_to_pdf(en_md, en_pdf, "PureBasic OOP - Reference Manual (EN)")
