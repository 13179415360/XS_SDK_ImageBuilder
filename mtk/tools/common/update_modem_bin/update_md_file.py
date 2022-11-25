'''copy modem binary files to AP'''
import json
import argparse
import sys
import os
import fnmatch
import shutil
import logging

def loadjson(file):
    '''load and return specified json file'''
    logging.info("start reading config %s", file)
    data = {}
    with open(file) as json_file:
        data = json.load(json_file)
    return data

def get_file_from_path(path, file_pattern):
    '''find "file_pattern" under path'''
    logging.debug("matching %s  under %s", file_pattern, path)
    return fnmatch.filter(os.listdir(path), file_pattern)

def check_path_exist(path):
    '''check path exist or not'''
    if not os.path.exists(path):
        logging.error("path '%s' not exist", path)
        sys.exit(-1)

def copy_files(mapping):
    '''based on src/dst, exe copy'''
    for src in mapping:
        logging.info("copy %s to %s", src, mapping[src])
        if os.path.isdir(src):
            if os.path.exists(mapping[src]):
                shutil.rmtree(mapping[src])
            shutil.copytree(src, mapping[src])
        else:
            shutil.copy(src, mapping[src])

def remove_files(path, files_to_removed):
    '''remove 'files_to_removed' under path'''
    for file_name in files_to_removed:
        target_file = os.path.join(path, file_name)
        logging.info("remove file %s from %s", file_name, path)
        os.remove(target_file)

def check_file_status(attri, files, pattern, path):
    '''check source file status'''
    # if more than one match or not thing match, then report error.
    if attri["multiple"] == "no" and len(files) > 1:
        logging.error("more than one file matched pattern '%s' in %s! %s",
                     pattern, path, files)
        sys.exit(-1)

    # if nothing found, report error
    if attri["allow_zero_match"] == "no" and len(files) == 0:
        logging.error("nothing matched specified pattern '%s' in %s",
                      pattern, path)
        sys.exit(-1)

def prepare_copy_mapping(copy_mapping, files, source_path, prebuilt_modem_path, rename_as_file):
    '''prepare src/dst mapping for copy operation'''
    for file_name in files:
        src_file = os.path.join(source_path, file_name)

        if rename_as_file is not None:
            file_name = rename_as_file

        dst_file = os.path.join(prebuilt_modem_path, file_name)

        copy_mapping[src_file] = dst_file

def get_attrib(item):
    '''convert json config into attrib settings'''
    attri = {}
    if item.get("multiple") is not None and item.get("multiple").lower() == "yes":
        attri["multiple"] = "yes"
    else:
        attri["multiple"] = "no"

    if item.get("allow_zero_match") is not None and item.get("allow_zero_match").lower() == "yes":
        attri["allow_zero_match"] = "yes"
    else:
        attri["allow_zero_match"] = "no"

    return attri

def main():
    '''main function'''
    param = argparse.ArgumentParser(description="copy modem bin")
    param.add_argument('prebuilt_modem_path', help='folder to store modem bin')
    param.add_argument('md_build_path', help='abs path to md build dir')
    param.add_argument('-mode', help='build mode or release mode', dest="mode", default="build")

    args = vars (param.parse_args())

    prebuilt_modem_path = args['prebuilt_modem_path']
    md_build_path = args['md_build_path']
    mode = args['mode']
    if mode.lower() == "release":
        mode = "release"
    else:
        mode = "build"

    # init logging
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s %(module)-4s %(levelname)-4s %(message)s',
                        datefmt='%m-%d %H:%M:%S')

    logging.info("src/dst folders are %s and %s", md_build_path, prebuilt_modem_path)

    ##################
    #  check path exist
    ##################
    check_path_exist(prebuilt_modem_path)
    check_path_exist(md_build_path)

    # load json file
    script_loc = os.path.dirname(__file__)
    targets = loadjson( os.path.join(script_loc, "md_file.json"))

    # store copy commands
    copy_mapping = {}

    for key in targets:
        item = targets[key]

        item_type = item["type"]
        if (item_type == "must") or (item_type == "release" and mode == "release"):

            if mode == "release": # use the same path for release mode
                source_path = md_build_path
            elif mode == "build":
                source_path = os.path.join(md_build_path, item.get("path"))

            files = get_file_from_path(source_path, key)
            attri = get_attrib(item)

            # check souce file match expectation or not
            check_file_status(attri, files, key, source_path)

            # create mapping
            prepare_copy_mapping(copy_mapping,
                                   files,
                                   source_path,
                                   prebuilt_modem_path,
                                   item.get("rename"))

            # remove existing files
            if item.get("remove") is not None:
                files_to_removed = get_file_from_path(prebuilt_modem_path, key)
                remove_files(prebuilt_modem_path, files_to_removed)

    copy_files(copy_mapping)

if __name__ == '__main__':
    main()
