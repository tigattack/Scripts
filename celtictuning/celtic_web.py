"""Query Celtic Tuning from a simplified web interfaced"""
import os

from flask import Flask, render_template, request
from flask.wrappers import Response

from . import Celtic

template_dir = os.path.abspath('./web_templates')
app = Flask(__name__, template_folder=template_dir)

def vehicle_info(vrn: str):
    """Just a silly little wrapper for my Celtic class"""
    try:
        celtic = Celtic.Celtic(vrn)
    except ValueError as err:
        return Response(
            str(err),
            status=400,
        )

    return celtic.get_all()

@app.route('/')
def index():
    """
    Function for web interface.
    'Interface' is a bit of a stretch but just go with it.
    """
    return render_template('page.html')


@app.route('/get_vehicle')
def api_responder():
    """
    Function for API requests
    Example: GET app/get_vehicle?vrn=ab12cde
    """

    if not request.args.get('vrn'):
        return 'ERROR: vrn parameter missing or empty.'

    vrn = request.args.get('vrn', '')
    if len(vrn) == 0:
        return 'Please provide a vehicle registration.'
    return vehicle_info(vrn)
