import re
import markdown
from docx import Document

def df2dict(df):
    """
    Convert a DataFrame to a nested dictionary.

    This function takes a DataFrame and converts it into a nested dictionary,
    where each row of the DataFrame becomes a dictionary entry with the index
    column as the key. Missing values in the DataFrame are replaced with "None".

    Args:
        df (pandas.DataFrame): The DataFrame to convert.

    Returns:
        dict: A nested dictionary representation of the DataFrame, where each key
              is the index column value and each value is a dictionary representing
              the corresponding row of the DataFrame.
    """
    outcome = (
        df.copy()
        .fillna("None")
        .set_index("id")
        .to_dict(orient="index")
    )
    return outcome

def get_section_data(section_name, outline):
    """
    Get data for a specific section from an outline DataFrame.

    This function takes a section name and an outline DataFrame as input,
    and returns a dictionary containing data for the specified section.

    Args:
        section_name (str): The name of the section to retrieve data for.
        outline (pandas.DataFrame): The outline DataFrame containing section data.

    Returns:
        dict: A dictionary containing data for the specified section, with the following keys:
              - 'id': The ID of the section page.
              - 'header': The header of the section.
              - 'toc': A DataFrame containing the table of contents (TOC) for the section.
    """

    content = outline.loc[outline["section_header"] == section_name]
    data = {
        "id"      : content.loc[content["section_page"] == True, "id"].iloc[0],
        "header"  : content.loc[content["section_page"] == True, "section_header"].iloc[0],
        "toc"     : content.loc[content["has_subsection"] == True]
    }
    return data

def page_grouping(input):
    """
    Groups elements from the input list into sublists, where each sublist represents a page.

    Args:
        input (list of str): A list of strings, where each string is an element that can be part of a page. 
                             The special string "page-end" indicates the end of a page.

    Returns:
        list of list of str: A list of sublists, where each sublist contains elements of a page. The "page-end" 
                             strings are not included in the sublists.
    """
    page_group = []
    current    = []

    for element in input:
        if "page-end" in element:
            if current:
                page_group.append(current)
                current = []
        else:
            current.append(element)
    
    if current:
        page_group.append(page_group)

    return page_group

def load_markdown_file(file_path, box = False):
    """
    Load a markdown file and wrap its paragraphs in HTML <p> tags. 

    This function reads the content of a markdown file from the specified file path,
    splits the content into paragraphs by double newlines, and wraps each paragraph
    in HTML <p> tags.

    Args:
        file_path (str): The path to the markdown file.

    Returns:
        str: A string containing the content of the markdown file with paragraphs
             wrapped in HTML <p> tags.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    
    paragraphs = content.split('\n\n')
    wrapped_paragraphs = [f'<p>{paragraph.strip()}</p>' for paragraph in paragraphs]
    result = '\n\n'.join(wrapped_paragraphs)

    if box:
        result = re.sub(
            "<p>{% BOX %}",
            '</div><div class="col-12 mb-4 bg-quote p-5"><p class="p-quote"><i>',
            result
        )
        result = re.sub(
            "{% BOX END %}</p>",
            '</i></p></div><div class="col-12">',
            result
        )

    return result

def process_word(path):
    """
    Processes a Word document, extracting and formatting the text content with HTML-like tags for bold and italic text.

    Args:
        path (str): The file path to the Word document.

    Returns:
        list of str: A list of strings, where each string represents a paragraph from the document with text wrapped 
                     in HTML-like <b> and <i> tags to indicate bold and italic formatting, respectively.
    """
    doc = Document(path)
    content = []
    
    for paragraph in doc.paragraphs:
        paragraph_text = ""
        run_buffer = ""
        bold = italic = False

        for run in paragraph.runs:
            run_text = run.text

            if run.bold != bold or run.italic != italic:
                if run_buffer:
                    if bold:
                        run_buffer = f'<b>{run_buffer}</b>'
                    if italic:
                        run_buffer = f'<i>{run_buffer}</i>'
                    paragraph_text += run_buffer
                    run_buffer = ""

                bold = run.bold
                italic = run.italic

            run_buffer += run_text

        if run_buffer:
            if bold:
                run_buffer = f"<b>{run_buffer}</b>"
            if italic:
                run_buffer = f"<i>{run_buffer}</i>"
            paragraph_text += run_buffer

        content.append(paragraph_text)
    
    grouped_content = page_grouping(content)

    return grouped_content

def get_dynamic_data(general_info, outline):
    """
    Get dynamic data for generating a report.

    This function takes an outline DataFrame as input and returns a dictionary
    containing dynamic data for generating a report, including general information,
    table of contents, and acknowledgements.

    Args:
        outline (pandas.DataFrame): The outline DataFrame containing report structure data.

    Returns:
        dict: A dictionary containing dynamic data for generating a report, with the following keys:
              - 'general': General information about the report, including title, subtitle, 
                           description, and PDF name.
              - 'toc': A nested dictionary representing the table of contents (TOC) of the report.
              - 'acknowledgements': Acknowledgements text loaded from a markdown file.
    """

    dynamic_data = {
        "general": (
            general_info
            .set_index('id')
            .T
            .to_dict(orient = "index")
        )["value"],
        "toc" : (
                df2dict(
                    outline
                    .loc[outline["toc"] == True, ["id", "page", "section_header", "subsection_header"]]
                )
        ),
        "acknowledgements" : {
            "text" : markdown.markdown(load_markdown_file("text/acknowledgements.md"))
        },
        "aboutReport" : {
            "section_page" : get_section_data("About this Report", outline),
            "text"         : markdown.markdown(load_markdown_file("text/about_this_report.md", box = True)),
            "page"         : outline.loc[outline["subsection_header"] == "About this Report", "page"].iloc[0],
            "header"       : outline.loc[outline["subsection_header"] == "About this Report", "section_header"].iloc[0],
            "evenPage"     : outline.loc[outline["subsection_header"] == "About this Report", "evenPage"].iloc[0]
        },
        "ExecFindings" : df2dict(
            outline.copy()
            .loc[outline["subsection_header"] == "Executive Findings", ["id", "page", "subsection_header", "evenPage"]]
            .assign(
                content = process_word("text/Executive_Findings_template.docx"),
                startingPage = outline.loc[outline["subsection_header"] == "Executive Findings", "page"].iloc[0]
            )
        ),
        "thematic_findings" : df2dict(
            outline.loc[outline["thematic_findings"] == True]
        )
    }   
    return dynamic_data