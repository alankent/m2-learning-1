call M2SYNC-SETTINGS.BAT

docker kill %M2SYNC_PROJECT%
docker rm %M2SYNC_PROJECT%

pause
