#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq is not installed. Please install it to use this script."
    exit 1
fi

# Check if input file is provided
if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <input.json> <output.json>"
    exit 1
fi

input_file="$1"
output_file="$2"

# Check if input file exists
if [ ! -f "$input_file" ]
then
    echo "Error: Input file '$input_file' not found."
    exit 1
fi

# jq script to transform keys from camelCase to snake_case
jq_script='
def camelToSnake:
  if type == "string" then
    explode
    | map(if . >= 65 and . <= 90 then [95, . + 32] else [.] end)
    | flatten
    | implode
  else
    .
  end;

.[]
| with_entries(.key |= camelToSnake)
| {
  text: .text,
  type: (.type | if . then . else "default_type" end),
  alias: (.alias | if . then . else "default_alias" end),
  notes: (.notes | if . then . else "default_notes" end),
  checklist: (.checklist | if . then . else [] end)
}
'

# Transform JSON using jq
jq "$jq_script" "$input_file" > "$output_file"

echo "JSON transformed and saved to '$output_file'"