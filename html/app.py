import pandas as pd
from flask import Flask, render_template
from templates import functions
from bs4 import BeautifulSoup

app = Flask(__name__)

general_info = pd.read_excel("../report_outline.xlsx", sheet_name = "general_info")
outline = (
    pd.read_excel("../report_outline.xlsx", sheet_name = "outline")
    .assign(
        evenPage = lambda x: x["page"] % 2 == 0
    )
)  
figure_map   = pd.read_excel("../report_outline.xlsx", sheet_name = "figure_map")
section_list = outline.loc[outline["section_header"].notna(), "section_header"].drop_duplicates().to_list()
dynamic_data = functions.get_dynamic_data(general_info, outline)


@app.route("/")
def report():

    rendered_html = render_template(
        "index.html", 
        dynamic_data = dynamic_data
    )
    soup = BeautifulSoup(rendered_html, 'html.parser')
    pretty_html = soup.prettify()
    with open('index.html', 'w') as f:         
        f.write(pretty_html)   
    return pretty_html

if __name__ == "__main__":
    app.run(debug=True)
