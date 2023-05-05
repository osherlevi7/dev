import logging
import os
import sys

from enum import Enum


class FileFormats(Enum):
    pdf = "pdf"
    odt = "odt"
    docx = "docx"
    doc = "doc"
    txt = "txt"


class EnvironmentType(Enum):
    production = "production"
    development = "development"


ENVIRONMENT = EnvironmentType(
    os.getenv("ENVIRONMENT", EnvironmentType.production)
)

try:
    EnvironmentType(ENVIRONMENT)
except ValueError as e:
    sys.exit(e)

DEBUG = ENVIRONMENT == EnvironmentType.development

LOG_FORMAT = (
    "{asctime:s}.{msecs:0<3.0f} {levelname} [{name}:{lineno}] {message}"
)

LOG_LEVEL = logging.DEBUG if DEBUG else logging.INFO

LOG_CONFIG = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "message": {
            "style": "{",
            "format": LOG_FORMAT,
            "datefmt": "%Y-%m-%d %H:%M:%S",
        }
    },
    "handlers": {
        "console": {
            "level": LOG_LEVEL,
            "formatter": "message",
            "class": "logging.StreamHandler",
            "stream": "ext://sys.stdout",
        },
    },
    "loggers": {
        "root": {
            "level": LOG_LEVEL,
            "handlers": ["console"],
        },
        "uvicorn": {
            "propagate": False,
            "level": LOG_LEVEL,
            "handlers": ["console"],
        },
        "multipart": {
            "propagate": False,
            "level": logging.INFO,
            "handlers": ["console"],
        },
    },
}

REMOVE_OLDER_THEN_SECONDS = int(os.getenv("REMOVE_OLDER_THEN_SECONDS", 60))

COMMAND_RETRIES = int(os.getenv("COMMAND_RETRIES", 5))

LIBREOFFICE = os.getenv("LIBREOFFICE", "libreoffice")

FILES = f"../files"


def files():
    if not os.path.exists(FILES):
        os.mkdir(FILES)
    return FILES


FILE_CONVERTER_USERNAME = os.getenv(
    "FILE_CONVERTER_USERNAME", "FILE_CONVERTER_USERNAME"
)
FILE_CONVERTER_PASSWORD = os.getenv(
    "FILE_CONVERTER_PASSWORD", "FILE_CONVERTER_PASSWORD"
)
