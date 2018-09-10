#!env python3
#
# img_opt.py
# PIL Based Image size optimizer
#

from getopt import getopt
from PIL import Image
from multiprocessing import Pool, cpu_count

import os
import sys
import io

# Parse the given argument vector argv into enabled options and image path list
# Checks if the image paths given by the user are valid.
# Returns options dictionary and img_paths list of image paths
def parse_args(argv):
    options = {
        "quality" : 85,
        "output_dir": "optimized",
        "suffix": "",
        "help": False,
        "verbose": False,
    }

    # Read command line args into options
    args = argv[1:] # Skip program name
    opts, image_paths = getopt(args, "vhq:p:o:")
    opts = dict(opts)
    
    if "-h" in opts: options["help"] = True
    if "-v" in opts: options["verbose"] = True
    if "-q" in opts: options["quality"] = int(opts["-q"])
    if "-o" in opts: options["output_dir"] = opts["-o"]
    
    # Check image paths
    for path in image_paths:
        if not os.path.exists(path): 
            raise FileNotFoundError("Image path passed does exist")
        
    return options, image_paths


# Optimise the given image object
# returns an optimised BytesIO object of image
def optimise_img(img, quality):
    opt_img = io.BytesIO()
    img.save(opt_img, optimize=True, quality=quality)
    
    return opt_img
    
# Apply optmisation at the image at the given path 
# Writes the optmised image at the path onstructued by combining the given output
# directory, the given path, and the given path suffix
def apply_optimisation(path, quality=85, output_dir=".", suffix="", verbose=False):
    # Apply image optmisation
    if verbose: print("optimising {}..".format(path))
    img = Image.open(path)
    opt_img = optimise_img(img, quality)
    
    # Write optmised file to disk
    opt_path = os.path.join(output_dir, path + suffix)
    with open(path, "wb") as f:
        f.write(opt_img.read())
                        

if __name__ == "__main__":
    # Determine program configuration
    USAGE = """\
imgopt [-q <quality>] [-s <suffix>] [-h] <paths to imgs...> 
-h - display this usage infomation
-q <quality> - the quality to preserve in the optimized image as a pecentage
-p <suffix>  - the suffix to add the original path to consitute the optimised path
-o <output dir> - output image to output directory
-v - verbose"""
    options, image_paths = parse_args(sys.argv)

    if options["help"]: 
        print(USAGE)
        sys.exit(0)
        
    # Apply image optmisisation concurrently on multiple processes
    if options["verbose"]: print("using {} processes.".format(cpu_count()))
    processes = Pool(cpu_count())
    apply = (lambda path: apply_optimisation(path, **options))
    processes.map(apply, image_paths)
