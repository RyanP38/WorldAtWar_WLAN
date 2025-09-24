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


# Example usage
svg_path = """
m 759.26,648.42 -11.32,-3.16 -2.28,-8.4 -1.49,-7.16 -0.09,-10.52 -4.75,-3.5 -12.93,-0.38 -5.64,-1.23 -8.06,3.38 -4.1,-4.51 -5.01,-3.62 -2.77,-7.63 1,-7.34 1.46,-6.74
V 579.92
l -3.84,-4.29 -3.73,-5.99 -3.97,-4.06 0.73,-6.74 1.69,-6.16 0.3,-11.12 7.94,-6.69 4.7,-5.29 10.58,-1.58 2.38,-5.87 2.26,-3.67 5.7,-2.04 3.71,-4.32 2.63,-6.48 2.47,-4.41 10.81,-3.61 6.78,1.9 4.02,3.74 7.67,-0.26 5.58,-4.48 7.61,-1.58 4.76,-3.6 4.06,-3.62 5.46,2.02 6.48,2.02 4.84,-2.81 6.35,-2.61 9.91,3.72 6.03,1.7 9.22,2.94 1.21,6.55 1.6,4.55 2.6,4.75 -1,7.22 0.88,7.08 3.18,4.96 3.07,10.95 -4.97,5.94 -3.06,8.56 -2.7,8.38 -1.47,7.25 0.35,19.08 1.02,6.11 -2.48,6.05 -4.14,6.9 -5.13,3.36 -7.71,0.94 -6.77,1.7 -3.83,4.49 -4.46,6.01 -5.08,-0.44 -5.74,2.43 -3.57,4.29 -1.92,6.49 -5.39,2.87 -10.02,2.17 -5.24,3.47 -6.39,-0.36
z
"""
coordinates = parse_svg_path(svg_path)
print(coordinates)
