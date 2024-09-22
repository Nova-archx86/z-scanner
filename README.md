# Z-scanner
A simple yet, effective port scanner written in zig inspired by the nmap project.

# Disclaimer
This software comes without any warrenty and I am not responsible
for the way that you use this software. Scan responsibly. 

### Installation
Download the latest build from releases and copy it to somewhere on your $PATH  (ex: /usr/local/bin)

### Building from source

Requirements:
1. at least zig 0.13.0 or higher

Clone the repo using git move into the source directory
~~~ 
git clone https://github.com/Nova-archx86/z-scanner
    
cd z-scanner
~~~
Install all dependencies
~~~
zig fetch --save https://github.com/Hejsil/zig-clap/archive/refs/tags/0.9.1.tar.gz
~~~
Or (if using the master branch of zig)
~~~
zig fetch --save git+https://github.com/Hejsil/zig-clap
~~~
Run zig build.
~~~ 
zig build
~~~

### Usage
-p can be used to specify single or multiple ports 
--target or -t is used to specify the remote host to scan.
~~~
zscan -p 22 --target <host>
~~~
or 
~~~    
zscan -p 22-1023 --target <host>
~~~
