To create the visualization, make sure `world.visualize = true` in `main.rs`, and then:

```
$ rm -rf vis/ vis.mp4
$ mkdir vis
$ cargo run --release < ../input/input15
$ ffmpeg -r 60 -i vis/%05d.png -pix_fmt yuv420p -r 60 vis.mp4
```

