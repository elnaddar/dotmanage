#!/bin/bash

# Function to find the csproj file in the directory
find_csproj_file() {
    local dir="$1"
    local csproj_file=$(find "$dir" -maxdepth 1 -name "*.csproj" -print -quit)
    [[ -n "$csproj_file" ]] && echo "$csproj_file" || echo ""
}

# Function to get the namespace from the csproj file or folder's name
get_namespace() {
    local csproj_file="$1"
    local folder_name="$2"
    
    if [[ -f "$csproj_file" ]]; then
        namespace=$(xmllint --xpath "string(//RootNamespace)" "$csproj_file" 2>/dev/null)
        [[ -n "$namespace" ]] && echo "$namespace" && return
    fi
    
    echo "${folder_name//\//.}"
}

# Function to replace placeholders and create a file from a template
create_from_template() {
    local template="$1"
    local output="$2"
    sed "s/{{NAMESPACE}}/$namespace/g; s/{{CLASSNAME}}/$3/g" "$template" > "$output"
}

# Function to create a model
create_model() {
    local name=$1
    local namespace=$2
    local template="$TEMPLATE_DIR/Model.cs.template"
    local output="$MODEL_DIR/$name.cs"
    
    [[ ! -f "$template" ]] && echo "Template not found: $template" && exit 1
    create_from_template "$template" "$output" "$name"
    echo "Created Model: $output"
}

# Function to create a controller
create_controller() {
    local name=$1
    local namespace=$2
    local template="$TEMPLATE_DIR/Controller.cs.template"
    local output="$CONTROLLER_DIR/${name}Controller.cs"
    
    [[ ! -f "$template" ]] && echo "Template not found: $template" && exit 1
    create_from_template "$template" "$output" "$name"
    echo "Created Controller: $output"
}

# Function to create a view
create_view() {
    local controller_name=$1
    local view_name=${2:-Index}
    local namespace=$3
    local template="$TEMPLATE_DIR/View.cshtml.template"
    local output="$VIEW_DIR/$controller_name/$view_name.cshtml"
    
    mkdir -p "$VIEW_DIR/$controller_name"
    [[ ! -f "$template" ]] && echo "Template not found: $template" && exit 1
    sed "s/{{NAMESPACE}}/$namespace/g" "$template" > "$output"
    echo "Created View: $output"
}

# Main script execution
SCRIPT_DIR=$(dirname "$0")
WORKING_DIR=$(pwd)

# Directory paths
TEMPLATE_DIR="$SCRIPT_DIR/../Templates"
MODEL_DIR="Models"
CONTROLLER_DIR="Controllers"
VIEW_DIR="Views"

# Ensure directories exist
mkdir -p "$MODEL_DIR" "$CONTROLLER_DIR" "$VIEW_DIR"

# Find the csproj file
csproj_file=$(find_csproj_file "$WORKING_DIR")
[[ -z "$csproj_file" ]] && echo "No .csproj file found in the directory." && exit 1

# Get the namespace from the csproj file or folder's name
folder_name=$(basename "$WORKING_DIR")
namespace=$(get_namespace "$csproj_file" "$folder_name")

# Parse create options
view_name=""
controller_name=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -m|--model) create_model "$2" "$namespace"; shift 2 ;;
        -c|--controller) controller_name="$2"; create_controller "$controller_name" "$namespace"; shift 2 ;;
        -v|--view)
            if [[ -z "$controller_name" ]]; then
                view_name="$2"
                create_view "" "$view_name" "$namespace"
            else
                create_view "$controller_name" "$view_name" "$namespace"
            fi
            shift 2 ;;
        -n|--name) view_name="$2"; shift 2 ;;
        -vc|-cv)
            controller_name="$2";
            if [[ "$#" -gt 2 && ( "$3" == "-n" || "$3" == "--name" ) ]]; then
                view_name="$4"
                shift 2
            fi
            create_controller "$controller_name" "$namespace";
            [[ -n "$view_name" ]] && create_view "$controller_name" "$view_name" "$namespace" || create_view "$controller_name" "$namespace";
            shift 2 ;;
        -mc|-cm) create_model "$2" "$namespace"; create_controller "$2" "$namespace"; shift 2 ;;
        -mv|-vm) create_model "$2" "$namespace"; create_view "$2" "$view_name" "$namespace"; shift 2 ;;
        -mvc|-mcv|-vcm|-vmc|-cmv|-cvm)
            model_name="$2";
            create_model "$model_name" "$namespace";
            create_controller "$model_name" "$namespace";
            [[ -n "$view_name" ]] && create_view "$model_name" "$view_name" "$namespace" || create_view "$model_name" "$namespace";
            shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done