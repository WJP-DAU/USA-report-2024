"""
Project:            USA Report 2024
Module Name:        Text Processing Q16 and Q17
Author:             Isabella Coddington
Date:               June 28,2024
Description:        This module contains the code to preprocess Q16 and Q17 for word cloud production.
This version:       July 1st, 2024
"""


# Import libraries
import pandas as pd
import spacy
from nltk.stem import PorterStemmer
from nltk.corpus import stopwords
import csv

# load master data 
path = "C:/Users/icoddington/OneDrive - World Justice Project/Data Analytics/6. Country Reports/USA-report-2024/data-viz/data/USA_data.dta"
df = pd.read_stata(path, convert_categoricals=True)

# load spaCy model
nlp = spacy.load('en_core_web_sm')

# initialize PorterStemmer
ps = PorterStemmer()

# set of stop words
stop_words = set(stopwords.words('english'))

# process text
def process_text(text):
    if pd.isna(text) or text.strip() == '':
        return [], [], []
    doc = nlp(text.lower())
    tokens = [token.text for token in doc if token.text not in stop_words and token.is_alpha]
    stems = [ps.stem(token) for token in tokens]
    lemmas = [token.lemma_ for token in doc if token.text not in stop_words and token.is_alpha]
    return tokens, stems, lemmas

# filter for relevant columns
filtered_columns = [col for col in df.columns if 'USA_q16' in col or 'USA_q17' in col]
text_df = df[filtered_columns]

columns_to_drop = ['USA_q16_98', 'USA_q16_99', 'USA_q17_98', 'USA_q17_99']
for col in columns_to_drop:
    if col in text_df.columns:
        text_df = text_df.drop(columns=[col])

# apply the text processing function to each relevant column
for col in text_df.columns:
    text_df[f'{col}_tokens'], text_df[f'{col}_stems'], text_df[f'{col}_lemmas'] = zip(*text_df[col].apply(process_text))

text_df['rule_of_law'] = text_df[[col for col in text_df.columns if 'USA_q16' in col and '_lemmas' in col]].values.tolist()
text_df['rule_of_law_US'] = text_df[[col for col in text_df.columns if 'USA_q17' in col and '_lemmas' in col]].values.tolist()

# flatten the lists of lemmas
def flatten_lemmas(lemmas_list):
    return [lemma for sublist in lemmas_list for lemma in sublist]

text_df['rule_of_law'] = text_df['rule_of_law'].apply(flatten_lemmas)
text_df['rule_of_law_US'] = text_df['rule_of_law_US'].apply(flatten_lemmas)

rule_of_law_df = text_df.explode('rule_of_law')[['rule_of_law']].dropna()
rule_of_law_us_df = text_df.explode('rule_of_law_US')[['rule_of_law_US']].dropna()

# lemma frequencies
rol_lemma_freq = rule_of_law_df['rule_of_law'].value_counts().reset_index()
rol_lemma_freq.columns = ['ROL', 'frequency_rol']

rol_us_lemma_freq = rule_of_law_us_df['rule_of_law_US'].value_counts().reset_index()
rol_us_lemma_freq.columns = ['ROL_us', 'frequency_us']

# merge to single df
lemmas_df = pd.merge(rol_lemma_freq, rol_us_lemma_freq, left_index=True, right_index=True, how='outer').fillna(0).astype({'frequency_rol': int, 'frequency_us': int})

# save to csv file
output_path = 'C:/Users/icoddington/OneDrive - World Justice Project/Data Analytics/6. Country Reports/USA-report-2024/data-viz'
lemmas_df.to_csv(output_path, index=False)
