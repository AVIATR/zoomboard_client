# Instructions.

https://1drv.ms/w/s!AvtrLa2QOP73xFRLTc9sFVAVY87z

## For HTTP streaming
sudo rm /mnt/hls/stream*; sudo avconv -f video4linux2 -r 5 -s hd1080 -i /dev/video0 -vf "format=yuv420p,framerate=5" -c:v libx264 -profile:v:0 high -level 3.0 -flags +cgop -g 1 -hls_time 0.1 -hls_allow_cache 0 -an -preset ultrafast /mnt/hls/stream.m3u8

