# PsLocations
Powershell command line interface (cli) for powershell to bookmark locations on the file system

WORK IN PROGRESS, NOT YET READY FOR USE, BUT SOON HOPE :)

- **DONE** All commands to be in first version implemented and being dogfooded on my mac
- **DOING** Currently writing Pester tests
- **DOING** Dogfooding and testing on my windows machine
- **NEXT** Dogfooding and testing on my linux machine (wsl on my windows machine)
- **DOING** User documentation here in readme
- **NEXT** Publish to the gallery

# Loc Command Line Interface -- Work in progress

The `Loc` command line interface (CLI) is a tool for managing and navigating folder bookmarks with ease. This guide provides detailed usage instructions for each action available in the `Loc` CLI.

## Basic commands to manage and use locations (aka bookmarks)

Bookmarks are called locations in this context and allow terminal command line users to move to much used working directories with out a series of cd or tedious path completions. To add current working directory as a location

```
loc add . 'Repository root of my amazing project'
```
The . says use directory name as name for location and last parameter is a mandatory description. If you want to use another name for the location than the directory name

```
loc add DaAmazingProject 'Repository root of my amazing project'
```

To list locations

```
loc l
```

To move to a location

```
loc DaAmazingProject
```

If you remember the position of the location as listed by ```loc l```, say 0 you can move to location

```
loc 0
```

Also ```loc go <name | position>``` and ```loc goto <name | position>``` will work

To remove a location (the bookmark, not the actual bookmarked directory!)

```
loc remove <location-name>
```

or 

```
loc remove <location-pos>
```

If current working directory is the directory you need to remove the bookmark for

```
loc remove .
```

If you need to rename a location

```
loc rename <current-name> <new-name>
```

To change the description of a location

```
loc edit <location-name | location-pos> <new-description>
```

You can add notes to locations, adding a note

```
loc note <location-name | location-pos> <note>
```

List notes for a location

```
loc notes <location-name | location-pos>
```
