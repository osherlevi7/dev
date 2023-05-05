import logging.config
import secrets

import aiofiles
from fastapi import (
    BackgroundTasks,
    Depends,
    FastAPI,
    File,
    HTTPException,
    status,
)
from fastapi.responses import FileResponse
from fastapi.security import HTTPBasic, HTTPBasicCredentials

import settings
from helpers import remove_old_files, run_command


logging.config.dictConfig(settings.LOG_CONFIG)
logger = logging.getLogger(__name__)
app = FastAPI(debug=settings.DEBUG)
security = HTTPBasic()


def authenticate(credentials: HTTPBasicCredentials = Depends(security)):
    correct_username = secrets.compare_digest(
        credentials.username, settings.FILE_CONVERTER_USERNAME
    )
    correct_password = secrets.compare_digest(
        credentials.password, settings.FILE_CONVERTER_PASSWORD
    )
    if not (correct_username and correct_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username


@app.post(
    "/convert-to/{file_format}/",
    response_class=FileResponse,
    dependencies=[Depends(authenticate)],
)
async def convert(
    tasks: BackgroundTasks,
    file_format: settings.FileFormats = settings.FileFormats.pdf.value,
    file: bytes = File(...),
):
    path = f"{settings.files()}/{id(file)}"
    async with aiofiles.open(path, mode="wb") as f:
        await f.write(file)
    await run_command(
        command=f"{settings.LIBREOFFICE} --headless "
        f"--convert-to {file_format.value} {path} "
        f"--outdir {settings.files()}"
    )
    tasks.add_task(remove_old_files)
    return f"{path}.{file_format.value}"
