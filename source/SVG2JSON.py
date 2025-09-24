# SVG2JSON
# Python Script to Convert SVG to JSON:

import xml.etree.ElementTree as ET
import json
import re


def parse_svg_path(path_str):
    path_str = path_str.replace(',', ' ')
    commands = re.findall(r'[MLHVZmlhvz]|-?\d*\.?\d+', path_str)
    
    abs_x, abs_y = 0, 0  # Absolute coordinates
    points = []
    last_cmd = None
    
    i = 0
    while i < len(commands):
        cmd = commands[i]
        if cmd.isalpha():  # It's a command
            last_cmd = cmd
            i += 1
        else:  # It's a coordinate
            cmd = last_cmd  # Repeat last command if needed
        
        if cmd in 'ML':  # Move or Line to absolute position
            abs_x, abs_y = float(commands[i]), float(commands[i+1])
            points.extend([abs_x, abs_y])
            i += 2
        elif cmd in 'ml':  # Move or Line to relative position
            abs_x += float(commands[i])
            abs_y += float(commands[i+1])
            points.extend([abs_x, abs_y])
            i += 2
        elif cmd in 'Hh':  # Horizontal line
            dx = float(commands[i])
            abs_x = dx if cmd == 'H' else abs_x + dx
            points.extend([abs_x, abs_y])
            i += 1
        elif cmd in 'Vv':  # Vertical line
            dy = float(commands[i])
            abs_y = dy if cmd == 'V' else abs_y + dy
            points.extend([abs_x, abs_y])
            i += 1
        elif cmd in 'Zz':  # Close path (connect to first point)
            if points:
                points.extend(points[:2])
            i += 1
    strHolder = ["{:.2f}".format(num) for num in points]
    newPoints = [", ".join(strHolder)]
    return newPoints


def svg_to_json(svg_file, output_file):
    tree = ET.parse(svg_file)
    root = tree.getroot()
    
    namespace = {'svg': 'http://www.w3.org/2000/svg', 'inkscape': 'http://www.inkscape.org/namespaces/inkscape'}
    polygons = {}

    for group in root.findall(".//svg:g", namespace):
        group_id = group.attrib.get('{http://www.inkscape.org/namespaces/inkscape}label', 'Unknown')
        polygons[group_id] = {}

        for path in group.findall(".//svg:path", namespace):
            # Use the 'id' attribute as the territory name if available, else fallback to 'inkscape:label'
            # old: territory_name = path.attrib.get('id') or path.attrib.get('{http://www.inkscape.org/namespaces/inkscape}label', 'Unknown')
            territory_name = path.attrib.get('{http://www.inkscape.org/namespaces/inkscape}label', 'Unknown')
            path_data = path.attrib.get('d', '')
            
            if path_data:
                points = parse_svg_path(path_data)
                polygons[group_id][territory_name] = points

    # Save as JSON
    with open(output_file, 'w') as outfile:
        json.dump(polygons, outfile, indent=4)

# Usage
svg_to_json('../WaWmap_RGB_ID/linePolygonsNotSimplified.svg', 'territories.json')


# Cleanup
"""
1. Search the .json file for any "Unknown" labels/IDs. (Ex. "MIDWAY_ISLAND" is "Unknown")
2. Remove duplicate paths from "polygonData"
3. Each group is separate, so "polygonData" doesn't contain the grouped paths. Expand "polygonData" to encompass the grouped paths.
"""