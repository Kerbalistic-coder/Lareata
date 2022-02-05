# Lareata Root Class

## Extending and Name
extends Node2D
class_name LareataRoot

## Variables (All variables have getters and setters unless otherwise specified)
array world_map no getset
array light_map no getset
int map_width
int map_height
bool map_generated

## Functions (Getsets are omitted unless otherwise specified)
### map_width setter (int value)
Sets map_width. Must check if map is already generated.
### map_height setter (int value)
Sets map_height. Must check if map is already generated.
