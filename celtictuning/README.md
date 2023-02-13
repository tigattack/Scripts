# Celtic Tuning

Unofficial Celtic Tuning sort-of API.

## Usage

```shell
pip install -r requirements.txt
flask --app celtic_web run
```

Browse to <http://localhost:5000> and use the web interface or query from CLI like so:

`curl -sG 'localhost:5000/get_vehicle' -d vrn=ab12cde`

Note: When developing, use `--debug run` with Flask for debugging with live reload of source files.

## Disclaimer

I am in no way affiliated with or endorsed by Celtic Tuning.

This project functions by scraping the Celtic Tuning web page, so it's about as far from official as you can get.

This project should not be used in any official capacity, it is offered “as-is”, without warranty, and I accept no liability for damages resulting from using the project.
