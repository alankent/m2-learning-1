
call M2SYNC-SETTINGS.BAT

SETLOCAL

@rem Start up a Docker container, then sync files between local file system
@rem and the container.

docker kill %M2SYNC_PROJECT%
docker rm %M2SYNC_PROJECT%
docker run -d -p 80:%M2SYNC_HTTP_PORT% -p 3000:%M2SYNC_BROWSERSYNC_PORT% -p 3001:%M2SYNC_BROWSERSYNCADMIN_PORT% -p 5000:%M2SYNC_UNISON_PORT% -p 22:%M2SYNC_SSH_PORT% --name %M2SYNC_PROJECT% %M2SYNC_CONTAINER%

rem Extracting binaries from container to make sure we have compatible version.
docker cp %M2SYNC_PROJECT%:/windows/unison.exe .
docker cp %M2SYNC_PROJECT%:/windows/unison-fsmonitor.exe .

@set IGNORE=

@rem Magento files not worth pulling locally.
@set IGNORE=%IGNORE% -ignore "Path var/cache"
@set IGNORE=%IGNORE% -ignore "Path var/composer_home"
@set IGNORE=%IGNORE% -ignore "Path var/log"
@set IGNORE=%IGNORE% -ignore "Path var/page_cache"
@set IGNORE=%IGNORE% -ignore "Path var/session"
@set IGNORE=%IGNORE% -ignore "Path var/tmp"
@set IGNORE=%IGNORE% -ignore "Path pub/media"
@set IGNORE=%IGNORE% -ignore "Path pub/static"
@set IGNORE=%IGNORE% -ignore "Path app/etc/env.php"

@rem Other files not worth pushing to the container.
@set IGNORE=%IGNORE% -ignore "Path M2SYNC-START.BAT"
@set IGNORE=%IGNORE% -ignore "Path M2SYNC-STOP.BAT"
@set IGNORE=%IGNORE% -ignore "Path M2SYNC-SHELL.BAT"
@set IGNORE=%IGNORE% -ignore "Path M2SYNC-SETTINGS.BAT"
@set IGNORE=%IGNORE% -ignore "Path Dockerfile"
@set IGNORE=%IGNORE% -ignore "Path Vagrantfile"
@set IGNORE=%IGNORE% -ignore "Path .vagrant"
@set IGNORE=%IGNORE% -ignore "Path .git"
@set IGNORE=%IGNORE% -ignore "Path .gitignore"
@set IGNORE=%IGNORE% -ignore "Path .gitattributes"
@set IGNORE=%IGNORE% -ignore "Path .magento"
@set IGNORE=%IGNORE% -ignore "Path .idea"
@set IGNORE=%IGNORE% -ignore "Name {.*.swp}"
@set IGNORE=%IGNORE% -ignore "Name {.unison.*}"

@set LOCAL_ROOT=.
@set REMOTE_ROOT=socket://localhost:%M2SYNC_UNISON_PORT%//magento2 

@set UNISONARGS=%LOCAL_ROOT% %REMOTE_ROOT% -prefer %LOCAL_ROOT% -preferpartial "Path var -> %REMOTE_ROOT%" -auto -batch %IGNORE%

rem *************************************************************************
rem **** PLEASE BE PATIENT: This can take a few minutes on first startup ****
rem *************************************************************************

rem Give container a chance to start up so Unison can connect.
set loopcount=100
:loop
    rem Is Unison ready in container yet?
    .\unison %LOCAL_ROOT% %REMOTE_ROOT% -batch -auto -testserver
    if NOT ERRORLEVEL 1 goto exitloop
    timeout 2
    @set /a loopcount=loopcount-1
    @if %loopcount%==0 goto exitloop
    @goto loop
:exitloop

rem **** Pulling files from container (faster quiet mode) ****
.\unison %UNISONARGS% -silent >NUL:

rem **** Entering file watch mode ****
.\unison %UNISONARGS% -repeat watch

pause
