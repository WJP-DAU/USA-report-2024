The **_Rule of Law in the United States 2024_** presents question-level data drawnfrom the General Population Poll (GPP), an original data source designed and collected by the World Justice Project. The GPPwas conducted through online interviews to a nationally representative sample of 1,046 U.S. households in 2024. This poll wasdesigned to capture data on the experiences and perceptions of ordinary people regarding a variety of themes related to the ruleof law.

The data derived from the General Population Poll is presented in this report as thematic briefs, each one highlighting a different dimension of the rule of law from the perspective of people in the United States. The sections of this report describe people's perceptions and attitudes towards the following topics: accountability, authoritarianism, corruption, and trust in institutions. This edition of the **_The Rule of Law in the United States: Key Findings from the WJP General Population Poll 2024_** also presents a new set of questions related to the 2024 Presidential elections. These new questions are focused on the integrity of the electoralprocess and on people's attitudes when presented with hypothetical scenarios.

This GitHub repository contains the integral code used to produce the report and all its data visualizations. In order to prepare these VIZs, the DAU followed the specifications sent by the communications and design team.

## Files description
The repository is divided into two majo directories [`data-viz`](https://github.com/WJP-DAU/USA-report-2024/tree/main/data-viz) and [`html`](https://github.com/WJP-DAU/USA-report-2024/tree/main/html).

The `data-viz` directory contains all the routines to produce the data visualizations for the report. All data visualizations were produced using R as the main programming language and the [WJPr Package](https://github.com/ctoruno/WJPr) developed by [ctoruno](https://github.com/ctoruno). The `data-viz` routine follows our usual modular programming style.

The data to be used in this project is a subset from the merged.dta file managed by the organization. Due to the privacy discloures followed by the DAU (see the [DAU R Coding Handbook](https://ctoruno.quarto.pub/wjp-r-handbook/)), the contents of the `Data` and `Outputs` directories are limited on the GitHub repository and their full content can only be accessed through the WJP SharePoint.

The VIZs are stored as vectors in SVG format.

The `html` directory contains all the code used to produce the HTML (web) version of the report. The report is produced using Python as the main programming language, more specifically, using a [Flask app](https://flask.palletsprojects.com/en/3.0.x/) and [Jinja2 templates](https://jinja.palletsprojects.com/en/3.1.x/). Basic Knowledge of HTML and CSS is required to understand how the app renders the report.
