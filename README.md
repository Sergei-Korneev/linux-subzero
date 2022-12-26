# Linux Subzero



![subzero](sz.gif)

[Picture source](https://www.deviantart.com/jjbamortalkombat/art/Mortal-Kombat-2-Sub-Zero-gif-freeze-595259507)


***

The idea came to my head one day when I got pissed off by my CPU consuming 100% and heating up to 100 deg Celsius (that was Firefox of course ;)).         

So I decided

![idol](McAfee.gif)

to write some simple  software to stop this.

This bash script sends CONT signal to the all processes spawned by the window you are clicking on, and STOP signal to previous window with its processes.  

**Pros:** Less CPU and battery consuming.

**Cons:** Some background processes such as firefox may also stop their useful activity (e.g. downloading something).

## Installation

- ```sudo dnf (apt) install xdotool```

- chmod +x subzero.sh 

- run ./subzero.sh normal or subzero.sh unfreeze to unfreeze all windows 

I have tested it on Fedora + i3 
