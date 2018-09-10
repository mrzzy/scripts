#
# img_opt.py
# PIL Based Image size optimizer
#

from getopt import getopt
import os
import sys

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


if __name__ == "__main__":
    # Determine program configuration
    USAGE = """\
    imgopt [-q <quality>] [-s <suffix>] [-h] <paths to imgs...> 
    -h - display this usage infomation
    -q <quality> - the quality to preserve in the optimized image as a pecentage
    -p <suffix>  - the suffix to add the original path to consitute the optimised path
    -o <output dir> - output image to output directory
    -v - verbose
    """
    options, image_paths = parse_args(sys.argv)
    print(options, image_paths)
