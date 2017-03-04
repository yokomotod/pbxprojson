# pbxprojson

command line tool for convert project.pbxproj file to readable format for PR.

## Build

```sh
./install.sh
```

## Usage

```sh
.build/debug/Pbxprojson print --filepath <path_to_project.pbxproj>
```

process output json with [jq](https://stedolan.github.io/jq/)

```sh
.build/debug/Pbxprojson print --filepath <path_to_project.pbxproj> | jq .
```

