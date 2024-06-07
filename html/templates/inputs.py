import markdown

def load_markdown_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return file.read()

dynamic_data = {
    "general": {
        "title"       : "The Rule of Law in the United States",
        "subtitle"    : "Key Findings from the WJP General Population Poll 2024",
        "description" : "This report presents perceptions and experiences of authoritarianism, corruption and trust, security, and criminal justice.",
        "pdfName"     : "US_Report_WJP"
    },
    "toc": {
        "SectionI"   : "Section I: Authoritarianism, Fundamental Freedoms, and Accountability",
        "SectionII"  : "Section II: Corruption and Trust",
        "SectionIII" : "Section III: Security and Criminal Justice",
        "SectionIV"  : "Section IV: Discrimination"
    },
    "acknowledgements" : {
        "text": markdown.markdown(load_markdown_file("text/acknowledgements.md"))
    } 
}