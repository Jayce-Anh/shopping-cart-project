################################# CONVERT ENV #################################
#!/usr/bin/env python3
# This script converts .env files to JSON for AWS Secrets Manager

import json
from collections import OrderedDict

# ============== CONFIGURATION ==============
FILE_INPUT = '.env.example'   # Change this to your input file
FILE_OUTPUT = 'env.json'      # Change this to your output file
# ===========================================

# Read input file - preserving order
env_dict = OrderedDict()
with open(FILE_INPUT, 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        
        # Skip empty lines and comments
        if not line or line.startswith('#'):
            continue
        
        # Split on first = only
        if '=' in line:
            key, value = line.split('=', 1)
            # Remove quotes from values
            value = value.strip().strip('"').strip("'")
            env_dict[key.strip()] = value

# Write to JSON file
with open(FILE_OUTPUT, 'w', encoding='utf-8') as f:
    json.dump(env_dict, f, indent=2, ensure_ascii=False)

print(f'✓ Created {FILE_OUTPUT} successfully!')

