# steamcli

`steamcli` is a small commandline tool for launching and querying information
about installed Steam games. All information comes from .acf files in the
`steamapps` folder.

# Compiling / Running

Make sure [racket](https://racket-lang.org/) is installed, cd into the project
directory and run:

``` 
chmod u+x ./steamcli.rkt

./steamcli.rkt
```

You can also compile steamcli into a binary by running

```
raco exe steamcli.rkt
```
or simply `make`

# Usage

'$ ./steamcli.rkt' outputs

```
Usage: ./steamcli [list]
       ./steamcli [launch <appid>]
       ./steamcli [dump]
'list' prints every app and the corresponding appid
'launch <appid>' tells Steam to run app with <appid>
'dump' prints metadata for every app
```

# Example output

### Listing

```
$ ./steamcli list 

224760   FEZ 
220      Half-Life 2 
266010   LYNE 
400      Portal 
219680   Proteus 
105600   Terraria 
...
```

### Launching

```
$ ./steamcli launch 224760

Found game 'FEZ'
Execute 'steam -applaunch 224760' [y/n]? y
Executing...
[... followed by steam client output]
```

### Dumping

```
# ./steamcli dump

'((("appid" "224760")
   ("Universe" "1")
   ("name" "FEZ")
   ("StateFlags" "4")
   ("installdir" "FEZ")
   ("LastUpdated" "1480805440")
   ("UpdateResult" "0")
   ("SizeOnDisk" "441317193")
   ("buildid" "1493264")
   ("LastOwner" "76561198050229973")
   ("BytesToDownload" "750480")
   ("BytesDownloaded" "750480")
   ("AutoUpdateBehavior" "0")
   ("AllowOtherDownloadsWhileRunning" "0")
   ("Language" "english")
   ("224762" "5672754372855605298"))
 ...
```

## Notes

- Currently only works on Linux, and `steam` must be in your $PATH

### TODO
  - \*steam-path\* is platform specific, should be updated to work on Mac/Windows

### Feature ideas
  - launch app based on name?
  - allow searching for app names? (... or just use grep?)
  - allow more general purpose metadata querying?
