# reformat JSON

import json

def reformat_json(input_file, output_file):
    try:
        # Load the JSON data
        with open(input_file, 'r') as f:
            data = json.load(f)
        
        # Reformat and write to output file
        with open(output_file, 'w') as f:
            json.dump(data, f, indent=None, separators=(',', ': '))
        
        print(f"Reformatted JSON has been saved to {output_file}.")
    except Exception as e:
        print(f"Error: {e}")

# Example usage
input_file = "territories.json"
output_file = "territories_reformatted.json"
reformat_json(input_file, output_file)
