import asyncio
import os
import pathlib
import time

from logging import getLogger

import settings


logger = getLogger(__name__)


async def run_command(command: str):
    process = await asyncio.create_subprocess_shell(
        cmd=command,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )
    stdout, stderr = await process.communicate()
    stdout, stderr = stdout.decode(), stderr.decode()

    logger.debug(
        f"command: {command}, "
        f"exit code: '{process.returncode}', stderr: '{stderr}', "
        f"stdout: '{stdout}'".replace("\n", " ")
    )
    if process.returncode:
        logger.exception(f"stderr: {stderr}, stdout: {stdout}")


async def remove_old_files():
    now = time.time()
    files = [p for p in pathlib.Path(settings.files()).glob("[0-9]*")]
    [
        os.remove(f)
        for f in files
        if os.stat(f).st_mtime < now - settings.REMOVE_OLDER_THEN_SECONDS
    ]
