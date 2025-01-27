@echo off

echo -----------------------------
echo    Borneo mbtiles maker
echo -----------------------------

echo Osmium processing...
@REM osmium cat -c changeset -c uid -c user -o my-sg-br.osm.pbf malaysia-singapore-brunei-latest.osm.pbf
@REM osmium cat -c changeset -c uid -c user -o id.osm.pbf indonesia-latest.osm.pbf
@REM osmium merge my-sg-br.osm.pbf id.osm.pbf -o my-sg-br-in.osm.pbf

osmium merge malaysia-singapore-brunei-latest.osm.pbf indonesia-latest.osm.pbf -o my-sg-br-in.osm.pbf

@REM osmium extract -b 11.35,48.05,11.73,48.25 my-sg-br-in.osm.pbf -o borneo.osm.pbf
@REM osmium extract -b 108.698730,-4.477856,119.487305,7.558547 my-sg-br-in.osm.pbf -o borneo.osm.pbf
osmium extract -v -c ./borneo_extract.json my-sg-br-in.osm.pbf

osmium cat -f pbf borneo.osm.pbf -o borneo-latest.osm.pbf

echo Run tilemaker

docker run -it --rm ^
    -v %CD%:/data ^
    -v %CD%\coastline:/usr/src/app/coastline ^
    -v %CD%\landcover:/usr/src/app/landcover ^
    ghcr.io/systemed/tilemaker:master ^
    /data/borneo-latest.osm.pbf ^
    --output /data/borneo.mbtiles ^
    --store /data/store ^
    --bbox 103.5585008,-7.1986095,140.6689398,34.9706497 ^
    --process resources/process-openmaptiles.lua ^
    --config resources/config-openmaptiles.json