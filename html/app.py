import pandas as pd
import json
from flask import Flask, render_template
from templates import inputs

app = Flask(__name__)

@app.route("/")
def report():
    return render_template("index.html", dynamic_data = inputs.dynamic_data)

if __name__ == "__main__":
    app.run(debug=True)
