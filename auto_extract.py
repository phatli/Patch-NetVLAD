#! /usr/bin/env python
import logging
from tqdm.auto import tqdm
import subprocess
from os import environ
logging.basicConfig(level=logging.INFO,
                    format='%(levelname)s - %(message)s')
ds_suffix = ["index", "query"]
models = ["pittsburgh_WPCA4096", "pittsburgh_WPCA512",
          "pittsburgh_WPCA128", "mapillary_WPCA4096",
          "mapillary_WPCA512", "mapillary_WPCA128"]
datasets = ["pitts30k", "tokyo247"]
environ["CUDA_DEVICE_ORDER"] = "PCI_BUS_ID"
environ["CUDA_VISIBLE_DEVICES"] = str(1)


def main():
    for model in models:
        for dataset in datasets:
            for suffix in ds_suffix:
                logging.info(f"{model}_{dataset}_{suffix}")
                subprocess.call(["python", "feature_extract.py", "--config_path", f"patchnetvlad/configs/performance/{model}.ini",
                                 f"--dataset_file_path={dataset}_imageNames_{suffix}.txt",
                                 "--dataset_root_dir=/home/newdisk/heshan/datasets",
                                 "--output_features_dir", f"patchnetvlad/output_features/{dataset}_{suffix}_{model}"])


if __name__ == "__main__":
    main()
