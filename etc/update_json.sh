#!/bin/bash

# throwaway script for updating 1.20.5 json files to 1.21.1


transform_crafting_shapeless() {
    echo "$1" | jq '
        .ingredients = [
            .ingredients[] |
            if has("item") then .item
            elif has("tag") then "#" + .tag
            else .
            end
        ]
        | .result = {
            id: (.result.item // .result.id),
            count: (.result.count // 1)
        }
    '
}

transform_crafting_shaped() {
    echo "$1" | jq '
        .key = (
            .key | with_entries(
                .value = (
                    if .value.item then .value.item
                    elif .value.tag then "#" + .value.tag
                    else .value
                    end
                )
            )
        )
        | .result = {
            id: (.result.item // .result.id),
            count: (.result.count // 1)
        }
    '
}

normalize_ingredient() {
    echo "$1" | jq '
        .ingredient = (
            if (.ingredient | type) == "object" then
                if .ingredient.item then .ingredient.item
                elif .ingredient.tag then "#" + .ingredient.tag
                else .ingredient
                end
            else .ingredient
            end
        )
    '
}

transform_campfire_cooking() { normalize_ingredient "$1"; }
transform_smoking() { normalize_ingredient "$1"; }
transform_smelting() { normalize_ingredient "$1"; }
transform_blasting() { normalize_ingredient "$1"; }

transform_default() {
    local type="$1"
    echo "Unknown type: $type" >&2
    echo "$2"
    exit 1
}

main() {
    local input
    input=$(cat)
    local type
    type=$(echo "$input" | jq -r '.type // empty')
    case "$type" in
        "minecraft:crafting_shapeless")
            transform_crafting_shapeless "$input"
            ;;
        "minecraft:crafting_shaped")
            transform_crafting_shaped "$input"
            ;;
        "minecraft:campfire_cooking")
            transform_campfire_cooking "$input"
            ;;
        "minecraft:smoking")
            transform_smoking "$input"
            ;;
        "minecraft:smelting")
            transform_smelting "$input"
            ;;
        "minecraft:blasting")
            transform_blasting "$input"
            ;;
        *)
            transform_default "$type" "$input"
            ;;
    esac
}

main
