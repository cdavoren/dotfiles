# Python Notes

Various notes about techniques/approaches in Python that I commonly use.

## Logging

Using the ``logging`` module is best.

For coloured output, I use the ``colored`` module available from pip.

Quick reminders:

- `Logger` : An abstraction of a logging *source*, e.g. database, background processing thread etc.
- `Handler` : A logging *destination* (?) e.g. StreamHandler, FileHandler - here is where thread safety occurs.
- `Formatter` : A formatter of individual logging records (i.e. entries).  The default formatter has some hardcoded behaviour based on its initial format string (questionable design choice, IMO, but probably simple to use overall).  The *Handler~ is responsible for 
- `LogRecord`

Example of a coloured logger:

```python
import sys, logging
import colored

# Uses the colored module to create coloured terminal output.  Writes to stderr by default.
class ColoredOutputHandler(logging.StreamHandler):

    class ColoredFormatter(logging.Formatter):

        colors = {
            'time' : 77, # Pastel green
            'level' : 148, # Pastel blue
            'name' : 81, # Faded yellow
            'message' : 123, # Bright cyan
        }

        def __init__(self):
            super().__init__('%(asctime)s')

        def format(self, record):
            super().format(record) # This duplicates default formatting behaviour based on format string, e.g. addition of asctime object to record
            # print(record.__dict__.keys())
            formatted = '{time_color}{time} {name_color}{name} {level_color}{level} {message_color}{message}{reset}'.format(
                time_color=colored.fg(self.colors['time']),
                name_color=colored.fg(self.colors['name']),
                level_color=colored.fg(self.colors['level']),
                message_color=colored.fg(self.colors['message']),
                reset=colored.attr('reset'),

                time=record.asctime,
                name=record.name,
                level=record.levelname,
                message=record.message)
            return formatted

    def __init__(self, stream=sys.stderr):
        super().__init__(stream)
        self.setFormatter(self.ColoredFormatter())
```

## Databases

Notes on interacting with databases in vanilla Python (i.e. NOT in the Django environment).  I use the `SQLAlchemy` and `psycopg2` modules.  Note the installation is case sensitive:

```bash
$ pip install SQLAlchemy psycopg2
```

SQLAlchemy contains an ORM out of the box.  Migrations are handled by the `alembic` submodule.


# JavaScript Notes

## npm

Consider rollup, webpack, or ?parcel.

```bash
$ node_modules/.bin/rollup editor.js -f iife -o common-static/js/editor.bundle.js -p @rollup/plugin-node-resolve
```

