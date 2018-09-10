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
        "scale" : 100,
        "output_dir": "optimized",
        "verbose": False,
    }

    # Read command line args into options
    args = argv[1:] # Skip program name
    opts, image_paths = getopt(args, "vhs:q:p:o:")
    opts = dict(opts)
    
    if "-h" in opts: 
        USAGE = """\
imgopt [-q <quality>] [-s <scale>] [-o <output_dir>] [-h] <paths to imgs...> 
-h - display this usage infomation
-q <quality> - the quality to preserve in the optimized image as a pecentage
-s <scale> - the amount of scaling applied to the optimised image as a percentage
-o <output dir> - output image to output directory
-v - verbose"""
        print(USAGE)
        sys.exit(0)

    if "-v" in opts: options["verbose"] = True
    if "-q" in opts: options["quality"] = int(opts["-q"])
    if "-s" in opts: options["scale"] = int(opts["-s"])
    if "-o" in opts: options["output_dir"] = opts["-o"]
    
    
    # Check image paths
    for path in image_paths:
        if not os.path.exists(path): 
            print("Error: Image path passed does exist")
            sys.exit(1)
        
    return options, image_paths


# Optimise the given image object of the given format 
# Downsample the optmised image based on the given quality percentage
# returns an optimised BytesIO object of image
def optimise_img(img, quality, img_format):
    opt_img = io.BytesIO()
    img.save(opt_img, format=img_format, optimize=True, quality=quality)
    
    return opt_img

# Rescale the given image object by a factor defined by the given scale percentage
# Returns the rescaled image object
def rescale_img(img, scale, verbose=False):
    factor = scale / 100
    scaled_height = round(img.height * factor)
    scaled_width = round(img.width * factor)
    
    if verbose:
        print("({},{}) -> ({},{})".format(img.width, img.height,
                                          scaled_width, scaled_height))
    
    return img.resize((scaled_width, scaled_height))
    
    
# Apply optimization at the image at the given path 
# Writes the optimised image at the path constructed by combining the given output
# directory, the given path, and the given path
def apply_optimisation(objective):
    # Load optmisisation objectives
    path = objective["path"]
    quality = objective["quality"]
    scale = objective["scale"]
    output_dir = objective["output_dir"]
    verbose = objective["verbose"]

    img = Image.open(path)
    img_format = img.format

    # Apply image optimisation
    if verbose: print("optimising {}..".format(path))
    scaled_img = rescale_img(img, scale, verbose)
    opt_img = optimise_img(scaled_img, quality, img_format)

    if verbose:
        print("{} => {}".format(os.path.getsize(path), opt_img.getbuffer().nbytes))
    
    # Write optimised file to disk
    opt_path = os.path.join(output_dir, os.path.basename(path))
    with open(opt_path, "wb") as f:
        f.write(opt_img.getbuffer())
                        

if __name__ == "__main__":
    # Determine program configuration
    options, image_paths = parse_args(sys.argv)

    # Create output directory if it does already exists 
    if not os.path.exists(options["output_dir"]):
        os.mkdir(options["output_dir"])
        
    # Construct optimisation objectives (path + options)
    objectives = [ dict(options) for p in image_paths ]
    for objective, path in zip(objectives, image_paths):
        objective["path"] = path
        
    # Apply image optimisation concurrently on multiple processes
    if options["verbose"]: print("using {} processes.".format(cpu_count()))
    processes = Pool(cpu_count())
    processes.map(apply_optimisation, objectives)
