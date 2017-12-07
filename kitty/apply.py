#!/usr/bin/env python3

import sys, os, pathlib

def main():
    if len(sys.argv) < 3:
        print('Syntax: apply [colour file] [existing kitty config name]', file=sys.stderr)
        sys.exit(-1)

    cf = open(sys.argv[1])

    colours = {}

    for line in cf:
        line_s = line.strip()
        if line_s.startswith('Colour'):
            colour_prefix = line_s.split('\\')[0]
            print(colour_prefix)
            colours[colour_prefix] = line

    cf.close()

    print(colours)

    kitty_config = sys.argv[2].replace(' ', '%20')
    kitty_config_path = os.path.join(str(pathlib.Path.home()), 'Sessions', kitty_config)
    kf = open(kitty_config_path, 'r')

    lines = kf.readlines()
    print(len(lines))
    kf.close()

    kf = open(kitty_config_path, 'w')

    for line in lines:
        print(line)
        tokens = line.strip().split('\\')
        if tokens[0] in colours.keys():
            kf.write(colours[tokens[0]])
        else:
            kf.write(line)

    kf.close()

if __name__ == '__main__':
    main()