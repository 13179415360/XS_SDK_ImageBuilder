'''construct a codebase for GPL build'''
import os
import argparse
import logging
from pathlib import PurePath
from os.path import join
import random
from datetime import datetime
import sys
import json
import shutil
import glob

def prepare_argument():
    '''prepare parsing input parameters'''
    param = argparse.ArgumentParser(description="generate codebase for GPL build")
    param.add_argument('root', help='codebase root')
    param.add_argument('working_dir', help='where to drop prepared codebase')
    param.add_argument('platform', help='mt6880')
    param.add_argument('subtarget', help='k6880v1_mdot2_datacard')

    return param

def init_logging(log_folder, log_prefix):
    '''init loggin'''
    log_file_prefix = join(log_folder, "%s" %(log_prefix))
    ran_num_str = str(random.randint(0, 10000)) # nosec
    log_file = log_file_prefix + "_%m-%d_%H_%M_%S_"+ran_num_str+".log"
    log_filename = datetime.now().strftime(log_file)
    print("(print)log file path: %s" %(log_filename))
    logging.basicConfig(level=logging.INFO,
                        format='%(asctime)s %(name)-12s %(levelname)-8s %(message)s',
                        datefmt='%m-%d %H:%M:%S',
                        filename=log_filename)
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)

def loadjson(input_file):
    '''read json file'''
    data = ""
    with open(input_file) as json_file:
        data = json.load(json_file)
    return data

def prepare_codebase(root, working_dir, platform):
    '''prepare codebase'''
    configs = loadjson("configs/%s_path" %(platform))
    logging.debug(configs)

    for path in sorted(configs.keys()):
        logging.info(path)
        logging.info(configs[path])
        target_path = join(root, path)
        dst_path = join(working_dir, path)
        default_ignore = [".git"]
        default_ignore.extend(configs[path])
        logging.info("ignore %s during copy", default_ignore)

        logging.info("copy %s to %s", target_path, dst_path)
        shutil.copytree(target_path,
                        dst_path,
                        symlinks=True,
                        ignore=shutil.ignore_patterns(*default_ignore))

def replace_txt_in_file(target_file, src_str, dst_str):
    '''replace string in file'''
    with open(target_file, "rt") as fin:
        data = fin.read()
        data = data.replace(src_str,
                            dst_str)

    with open(target_file, "wt") as fin:
        fin.write(data)

def modify_kernel_cfg(working_dir):
    '''modify kernel cfg'''
    target_path = join(working_dir,
                       "mtk/ext_kernel-4.19",
                       "arch/arm64/boot/dts/mediatek/*.dts")

    results = glob.glob(target_path)
    for file_path in results:
        logging.info("modifying kconfig %s", file_path)
        base = os.path.splitext(os.path.basename(file_path))[0]
        logging.debug("base %s", base)
        replace_txt_in_file(file_path,
                            "#include <mediatek/%s/cust.dtsi>" %(base),
                            "//#include <mediatek/%s/cust.dtsi>" %(base))

def modify_m2_cfg(working_dir, subtarget):

    target_file = ""
    dst = ""
    if subtarget == "k6880v1_mdot2_datacard":
        '''modify m2 files'''
        target_file = join(working_dir,
                           "openwrt/target/linux/mt6880_m2",
                           "k6880v1_mdot2_datacard/profiles/default.mk")
        dst = join(working_dir,
                   "openwrt/target/linux/mt6880_m2",
                   "%s/target.config" %(subtarget))

    elif subtarget == "evb6880v1_datacard":
        '''modify m2 files'''
        target_file = join(working_dir,
                           "openwrt/target/linux/mt6880",
                           "evb6880v1_datacard/profiles/default.mk")
        dst = join(working_dir,
                   "openwrt/target/linux/mt6880",
                   "%s/target.config" %(subtarget))


    # modify default.mk
    logging.info("modifying %s", target_file)
    replace_txt_in_file(target_file,
                        "PACKAGES:=libpam preloader lk atf spmfw sspm mcupm dpm mddb_installer",
                        "PACKAGES:=libpam")

    # copy makefile
    src = "data/%s/target.config" %(subtarget)

    logging.info("modifying %s", dst)
    shutil.copy2(src, dst)


def modify_mt6880_cfg(working_dir):
    '''modify mt6880 files'''
    src = "data/Makefile"
    dst = join(working_dir,
               "openwrt/target/linux/mt6880",
               "Makefile")
    logging.info("modifying %s", dst)
    shutil.copy2(src, dst)

    src = "data/image/Makefile"
    dst = join(working_dir,
               "openwrt/target/linux/mt6880",
               "image/Makefile")
    logging.info("modifying %s", dst)
    shutil.copy2(src, dst)

    src = "data/image/dtb.mk"
    dst = join(working_dir,
               "openwrt/target/linux/mt6880",
               "image/dtb.mk")
    logging.info("modifying %s", dst)
    shutil.copy2(src, dst)


def apply_changes(working_dir, subtarget):
    '''modify files'''
    modify_kernel_cfg(working_dir)

    modify_m2_cfg(working_dir, subtarget)

    modify_mt6880_cfg(working_dir)

def check_params(root, platform):
    '''check params'''
    if not os.path.exists(root):
        logging.error("%s doesn't exist", root)
        sys.exit(-1)

    if platform not in ["mt6880"]:
        logging.error("platform must be mt6880")
        sys.exit(-1)


def main(args):
    '''main function'''
    # create log folder
    os.makedirs("logs", exist_ok=True)

    init_logging("logs", PurePath(__file__).stem)

    root = args['root']
    working_dir = args['working_dir']
    platform = args['platform']
    subtarget = args['subtarget']

    logging.info("root: %s", root)
    logging.info("working dir: %s", working_dir)
    logging.info("platform: %s", platform)
    logging.info("subtarget: %s", subtarget)

    # basic checks
    check_params(root, platform)

    # re-create working_dir
    if os.path.exists(working_dir):
        shutil.rmtree(working_dir)
    os.makedirs(working_dir)

    # copy codebase
    prepare_codebase(root, working_dir, platform)

    # modify files
    apply_changes(working_dir, subtarget)

    return 0

if __name__ == '__main__':

    PARAM = prepare_argument()

    ARGS = vars(PARAM.parse_args())

    RET = main(ARGS)
    sys.exit(RET)
