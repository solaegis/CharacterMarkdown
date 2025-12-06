import re
import os

YAML_FILE = '/Users/lvavasour/git/CharacterMarkdown/examples/templates/champion_points.yaml'
OUTPUT_DIR = '/Users/lvavasour/git/CharacterMarkdown/examples/templates'

def parse_yaml(file_path):
    with open(file_path, 'r') as f:
        lines = f.readlines()

    data = {}
    current_section = None
    current_item = {}
    
    # Regex patterns
    section_pattern = re.compile(r'^(\w+):')
    item_start_pattern = re.compile(r'^\s+-\s+id:\s+(\d+)')
    key_value_pattern = re.compile(r'^\s+(\w+):\s*(.*)')
    prereq_pattern = re.compile(r'\{star:\s*"(.*?)",\s*min_points:\s*(\d+)\}')

    for line in lines:
        line = line.rstrip()
        if not line or line.strip().startswith('#'):
            continue

        # Check for section start (e.g., craft:)
        section_match = section_pattern.match(line)
        if section_match:
            current_section = section_match.group(1)
            data[current_section] = []
            current_item = {}
            continue

        # Check for item start (- id: ...)
        item_match = item_start_pattern.match(line)
        if item_match:
            if current_item and current_section:
                data[current_section].append(current_item)
            current_item = {'id': item_match.group(1)}
            continue

        # Parse key-values
        kv_match = key_value_pattern.match(line)
        if kv_match and current_item is not None:
            key = kv_match.group(1)
            value = kv_match.group(2)
            
            # Clean up value
            if value == 'null':
                value = None
            elif value == 'true':
                value = True
            elif value == 'false':
                value = False
            elif value.startswith('"') and value.endswith('"'):
                value = value[1:-1]
            elif value.isdigit():
                value = int(value)
            
            # Special handling for prerequisites
            if key == 'prerequisites':
                prereqs = []
                for p_match in prereq_pattern.finditer(value):
                    prereqs.append({
                        'star': p_match.group(1),
                        'min_points': p_match.group(2)
                    })
                current_item[key] = prereqs
            else:
                current_item[key] = value

    # Add last item
    if current_item and current_section:
        data[current_section].append(current_item)

    return data

def generate_mermaid(constellation_name, stars):
    lines = ["flowchart TB"]
    
    # Create a map of Name -> ID for linking
    name_to_id = {star['name']: star['id'] for star in stars}
    
    # Generate Nodes
    # To keep it somewhat organized, we can just list them. 
    # Mermaid handles layout.
    
    for star in stars:
        s_id = star['id']
        name = star['name']
        is_slottable = star.get('slottable', False)
        stages = star.get('stages', 0)
        pps = star.get('points_per_stage', 0)
        max_pts = star.get('max_points', 0)
        
        icon = "🔲 " if is_slottable else ""
        
        # Escape quotes in name if necessary (though usually fine in simple text)
        safe_name = name.replace('"', "'")
        
        label = f'{icon}{safe_name}<br/>{stages}stg × {pps}pts = {max_pts} max'
        
        lines.append(f'    {s_id}["{label}"]')

    lines.append("") # Spacer

    # Generate Edges
    for star in stars:
        target_id = star['id']
        prereqs = star.get('prerequisites', [])
        
        for prereq in prereqs:
            source_name = prereq['star']
            min_points = prereq['min_points']
            
            if source_name in name_to_id:
                source_id = name_to_id[source_name]
                lines.append(f'    {source_id} -->|"{min_points}pts"| {target_id}')
            else:
                print(f"Warning: Prerequisite '{source_name}' for '{star['name']}' not found in {constellation_name}")

    return "\n".join(lines)

def main():
    data = parse_yaml(YAML_FILE)
    
    for constellation in ['craft', 'warfare', 'fitness']:
        if constellation in data:
            print(f"Generating {constellation}.mmd...")
            mmd_content = generate_mermaid(constellation, data[constellation])
            output_path = os.path.join(OUTPUT_DIR, f'{constellation}.mmd')
            with open(output_path, 'w') as f:
                f.write(mmd_content)
            print(f"Wrote {output_path}")
        else:
            print(f"Warning: Section '{constellation}' not found in YAML")

if __name__ == '__main__':
    main()
