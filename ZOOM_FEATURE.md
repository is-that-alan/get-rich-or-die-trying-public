# Image Zoom Feature

This feature allows you to control the zoom level of scene images in the game. You can set zoom levels at different scopes:

## Scene-level Zoom

Add a `[ZOOM:X]` tag to your `scene.txt` file to set a default zoom for all panels in that scene:

```
[BGM:story_sad]
[TITLE:My Scene]
[ZOOM:1.1]
```

## Panel-level Zoom

Add a `[ZOOM:X]` tag to individual dialogue entries in your `.txt` files to set zoom for specific panels:

```
1
00:00:000 --> 00:02:000
[CHARACTER:外賣仔][COLOR:blue][ZOOM:0.9]
This panel will be zoomed out 10%

2
00:02:000 --> 00:04:000
[CHARACTER:外賣仔][COLOR:green][ZOOM:1.2]
This panel will be zoomed in 20%
```

## Zoom Values

- `0.9` = Zoom out 10% (image appears smaller)
- `1.0` = Normal size (no zoom)
- `1.1` = Zoom in 10% (image appears larger)
- `1.2` = Zoom in 20% (image appears larger)

## Priority Order

Zoom settings are applied in this priority order (highest to lowest):

1. Dialogue panel zoom (`[ZOOM:X]` in dialogue file)
2. Scene zoom (`[ZOOM:X]` in scene.txt)
3. Default zoom (1.0)

This means dialogue-level zoom will override scene-level zoom for that specific panel.

## Examples

### Scene with default zoom

```
[BGM:menu]
[TITLE:Intro Scene]
[ZOOM:1.05]
```

### Dialogue with varying zoom levels

```
1
00:00:000 --> 00:02:000
[ZOOM:0.8]
Wide shot - zoomed out

2
00:02:000 --> 00:04:000
[ZOOM:1.3]
Close-up - zoomed in

3
00:04:000 --> 00:06:000
Normal shot - uses scene default zoom
```
