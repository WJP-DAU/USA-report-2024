import pandas as pd
from flask import Flask, render_template
from bs4 import BeautifulSoup
from bs4.formatter import HTMLFormatter
from templates import functions

app = Flask(__name__)

general_info = pd.read_excel("../report_outline.xlsx", sheet_name = "general_info")
outline = (
    pd.read_excel("../report_outline.xlsx", sheet_name = "outline")
    .assign(
        evenPage = lambda x: x["page"] % 2 == 0
    )
)  
figure_map   = pd.read_excel("../report_outline.xlsx", sheet_name = "figure_map")
figure_map   = (
    figure_map
    .loc[(figure_map["id"] != "Figure_6") | (figure_map["panel"] != "D")]       # 4th panel is too big. On hold for the moment
)
dynamic_data = functions.get_dynamic_data(general_info, outline)
thematic_findings = dict(
    zip(
        outline.loc[outline["thematic_findings"] == True].id, 
        outline.loc[outline["thematic_findings"] == True].macro
    )
)

@app.context_processor
def utility_processor():
    return dict(get_thematic_parameters = functions.get_thematic_parameters)

@app.route("/")
def report():

    rendered_html = render_template(
        "index.html", 
        dynamic_data      = dynamic_data,
        outline           = outline,
        figure_map        = figure_map,
        thematic_findings = thematic_findings 
    )
    soup = BeautifulSoup(rendered_html, 'html.parser')
    pretty_html = soup.prettify(formatter = HTMLFormatter(indent=4))
    with open('index.html', 'w') as f:         
        f.write(pretty_html)   
    return pretty_html

if __name__ == "__main__":
    app.run(debug=True)
