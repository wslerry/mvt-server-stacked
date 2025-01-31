#!/bin/bash

mys_osm="/data/input/malaysia-singapore-brunei-latest.osm.pbf"
ind_osm="/data/input/indonesia-latest.osm.pbf"

osm_checker() {
    # make sure datasets are malaysia-singapore-brunei-latest.osm.pbf and indonesia-latest.osm.pbf
    # local mys_osm="/data/input/malaysia-singapore-brunei-latest.osm.pbf"
    # local ind_osm="/data/input/indonesia-latest.osm.pbf"

    if [ ! -f "$mys_osm" ]; then
        echo "$mys_osm not found, downloading..."
        # curl -L https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf \ 
        #     --output /data/input/malaysia-singapore-brunei-latest.osm.pbf
        wget -O /data/input/malaysia-singapore-brunei-latest.osm.pbf https://download.geofabrik.de/asia/malaysia-singapore-brunei-latest.osm.pbf
        if [ $? -ne 0 ]; then
            echo "Failed to download $mys_osm"
            exit 1
        fi
    else
        echo "$mys_osm data file already exists..."
    fi

    if [ ! -f "$ind_osm" ]; then
        echo "$ind_osm not found, downloading..."
        # curl -L https://download.geofabrik.de/asia/indonesia-latest.osm.pbf \ 
        #     --output /data/input/indonesia-latest.osm.pbf
        wget -O /data/input/indonesia-latest.osm.pbf https://download.geofabrik.de/asia/indonesia-latest.osm.pbf
        if [ $? -ne 0 ]; then
            echo "Failed to download $ind_osm"
            exit 1
        fi
    else
        echo "$ind_osm data file already exists..."
    fi
}

folder_checker() {
    local in_dir="/data/input/"
    # local out_dir="/data/output/"
    if [ -z "$(ls -A "$in_dir")" ]; then
        osm_checker
    fi
    # if [ ! -z "$(ls -A "$out_dir")" ]; then
    #     rm -rf $out_dir/*.*
    # fi
}


extract() {
    local config_ms="/opt/osmium/extraction/borneo_ms.json"
    local config_id="/opt/osmium/extraction/borneo_id.json"
    local out_clip="/data/output"


    echo Extracting Malaysia Borneo data...

    osmium extract -v -c $config_ms $mys_osm

    echo Extracting Indonesia Borneo data...

    osmium extract -v -c $config_id $ind_osm

    echo Merge Indonesia - Malaysia ...
    
    osmium merge $out_clip/borneo-ms.osm.pbf $out_clip/borneo-id.osm.pbf -o $out_clip/borneo-latest.osm.pbf --overwrite

    # rm -rf $out_clip/borneo-ms.osm.pbf /$out_clip/borneo-id.osm.pbf
}


# Check the first argument to determine which action to take
if [ $# -eq 0 ]; then
    folder_checker
    extract

    exit 1
else
    case "$1" in
        "extract")
            folder_checker
            extract

            exit 1
            ;;
        "download")
            osm_checker

            exit 1
            ;;
        *)
            echo "Usage: $0 {extract|download}" >&2
            exit 1
            ;;
    esac
fi