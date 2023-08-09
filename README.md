# MaxSizeContainer for Godot 4.x
A custom Container node for Godot Egine 4.x which limits the size of child nodes.
All Control nodes have a `rect_min_size` property, but they lack `rect_max_size`. **MaxSizeContainer** addresses this issue.

![DemoGif](./readme_files/demo.gif)

![DemoGif](./readme_files/modes.gif)

About     | Current Release
----------|-----------------------
Version   | 1.3
Date      | August 9, 2023
Platform  | Godot 4.x (tested on 4.2-dev2)
License   | [MIT License](LICENSE.md)
Authors   | Matthieu Huvé (Godot 3.x original)<br>Benedikt Wicklein (Godot 4 Beta)<br>Brom Bresenham (Godot 4.x)

# Installation
- Copy `addons/MaxSizeContainer` into your project (final path should be `res://addons/MaxSizeContainer`).

![FileSystem](./readme_files/filesystem.png)

- In the Godot Editor, go to **Project Settings > Plugins** and enable the **MaxSizeContainer** plugin.

![PluginMenu](./readme_files/plugin_menu.png)


# Usage
To be limited in size, a Control node must be child of a **MaxSizeContainer**.

 - From the editor, press **Add a new node**, and select **MaxSizeContainer**

![AddNewNodeMenu](./readme_files/add_new_node.png)

*Note: to add the Container from script, you must use this code:*

```gdscript
var MaxSizeContainer = preload("res://addons/MaxSizeContainer/max_size_container.gd")

add_child(MaxSizeContainer.new())
```

 - Add any Control node as a child of MaxSizeContainer.

 *Note: only one child is supported*

 - Select the mode, the limit (pixel size or aspect ratio, depending on the mode), and how you want the child node aligned when it reaches the maximum size.
![Properties](./readme_files/properties-2.png)
![Properties](./readme_files/modes.png)
*(In Pixel Size mode, -1 means no limit)*

# Examples
*(Screenshots from older version)*

- Let's start from this scene.

| ![SceneTree](./readme_files/tree_base.png) | ![SmallWindow](./readme_files/main_small.png)  | ![LargeWindow](./readme_files/main_without.png) |
|:---:|:---:|:---:|
| Scene tree | Small window | Large window |

When the window is enlarged, the main scene takes all the available space, as it is set as Expand.

 - To prevent that and make the text more readable, let's add a **MaxSizeContainer**, child of `MainScreen (ScrollContainer)` and parent of `VBoxContainer`:

| ![SceneTree](./readme_files/tree_with_one_container.png) | ![Parameters](./readme_files/inspector_fun_1_base.png)  | ![LargeWindow](./readme_files/main_basic.png) |
|:---:|:---:|:---:|
| Scene tree | Parameters | Large window |

- You can also nest different **MaxSizeContainers** together, and have fun:

| ![SceneTreeAndParameters](./readme_files/tree_and_inspector_fun.png) | ![LargeWindow](./readme_files/main_fun.png) |
|:---:|:---:|
| Scene tree and parameters | Large window |

# Troubleshooting

If the container doesn't work, try these solutions:

- Make sure there is only one child node, and it inherits from **Control**
- Make sure the child node's size flag are set to **Fill** vertically and horizontally.
- Make sure `max_size` is bigger than the minimum possible size of the child.

# License

See [License file](https://github.com/brombres/Godot-MaxSizeContainer/blob/master/LICENSE.md)
This README page was greatly inspired by [jmb462](https://github.com/jmb462/GodotQuickSettings/blob/main/README.md).
