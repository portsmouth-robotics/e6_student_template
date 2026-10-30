# 3. Understanding your ROS 2 package

This guide explains the files in your group repository, how ROS 2 runs your Python code, and what you need to change when you add a new program.

**By the end, you should be able to:** find your code, identify your ROS 2 package name, and understand how to make another Python program available through `ros2 run`.

[← Back to the guide index](../README.md) · [← Previous: Running the robot](02-running-the-robot.md) · [Next: Read the robot position →](04-reading-robot-position.md)

## Workspace, package, and node: what's the difference?

These are three different things:

- **Workspace**: the folder where you keep and build your ROS 2 packages. On the lab computers, that is `~/dobot_ws`.
- **Package**: a collection of related code and configuration files that ROS 2 can build and discover. Your group's repository contains one Python ROS 2 package.
- **Node**: a running program that takes part in the ROS 2 system. A node may read messages from the robot, request actions, or both.

For example, when you run `ros2 run e6_group_08 student_node`, ROS 2 finds the executable named `student_node` in package `e6_group_08`. When it starts, the Python code creates a node named `e6_student_node`.

**Those three names do different jobs:** the ROS 2 package name, the executable name, and the node's runtime name do not have to be identical.

Learn more: [ROS 2 nodes](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Nodes/Understanding-ROS2-Nodes.html).

## What the repository contains

Your group-specific package name will already be configured. The example below uses `e6_group_08`; **use the actual names shown in your repository**.

```text
e6_group_08/                 ← the cloned GitHub repository
├── README.md                ← index of the student guides
├── IMPORTANT.md             ← end-of-lab checklist
├── docs/                    ← instructions and reference guides
├── images/                  ← screenshots used by the guides
├── package.xml              ← ROS 2 package name, type, dependencies
├── setup.py                 ← Python package installation and executable entries
├── setup.cfg                ← where Python executables are installed
├── resource/                ← ROS 2 package registration marker
├── e6_group_08/             ← Python source-code directory
│   ├── __init__.py          ← marks this as a Python package
│   └── student_node.py      ← your starter ROS 2 node
└── test/                    ← supplied package tests
```

**Where to write your code:** in the inner Python source directory, alongside `student_node.py`. Don't write your coursework Python nodes in `docs/`, `images/`, or the workspace's `build/` and `install/` folders.

The package configuration files have already been prepared for your group. **Do not rename the package or re-run a rename script.**

## The files you'll use most

### `student_node.py`: your Python program

Open the file inside the inner Python folder. The supplied starter includes:

```python
import rclpy
from rclpy.node import Node

class E6StudentNode(Node):
    def __init__(self):
        super().__init__('e6_student_node')
        self.get_logger().info('E6 student node started.')
```

Here's what happens:

1. `rclpy` is the Python interface to ROS 2.
2. `E6StudentNode(Node)` defines a class that **inherits** the capabilities of a ROS 2 node.
3. `super().__init__('e6_student_node')` creates the ROS 2 node with the runtime name `e6_student_node`.
4. `get_logger().info(...)` prints a message so you can see that it started.

Lower down, the `main()` function calls `rclpy.init()`, creates your node, and calls `rclpy.spin(node)`. **Spinning** lets ROS 2 process incoming messages and callbacks while the program runs. When it exits, the program cleans up the node and shuts ROS 2 down.

This starter node does not yet command the robot or subscribe to anything. It is a starting place for your application.

Learn more: [Writing a simple Python publisher and subscriber](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html).

### `package.xml`: the ROS 2 package description

This file declares your package's name and dependencies. For this coursework, important dependencies include:

- `rclpy` — write ROS 2 nodes in Python.
- `dobot_msgs_v4` — the Dobot-specific message and service definitions.

You normally **won't need to edit this file** to add another Python node that uses these existing dependencies. If you later introduce an additional ROS 2 dependency, you may need to declare it here.

### `setup.py`: how ROS 2 finds your Python programs

Open `setup.py` and look for `entry_points`. The template has an entry similar to:

```python
entry_points={
    'console_scripts': [
        'student_node = e6_group_08.student_node:main',
    ],
},
```

This line means:

- `student_node` (left) — the executable name after `ros2 run`;
- `e6_group_08.student_node` (middle) — the Python package and module (file);
- `main` (right) — the function to start in that file.

In other words, this command:

```bash
ros2 run e6_group_08 student_node
```

starts the `main()` function in `e6_group_08/student_node.py`.

**Important:** simply creating a new Python file is *not enough* to make it available through `ros2 run`. You must add an entry point and rebuild.

### `setup.cfg`, `resource/` and `__init__.py`

These are supporting package files:

- `setup.cfg` tells Python's packaging tools to place executables where ROS 2 expects them.
- `resource/` contains a marker so ROS 2 can find the installed package.
- `__init__.py` identifies the inner folder as a Python package.

Leave these alone for now; you shouldn't need to edit them for the first exercise.

## How you'll add a new program

In the next exercise, you'll make a simple node called `read_pose` that prints the E6's reported tool position. Here's the process you'll use:

1. Create a file named `read_pose.py` **inside the inner Python folder** (next to `student_node.py`).
2. Write a ROS 2 node in that file, including a `main()` function.
3. Add an entry to the `console_scripts` list in `setup.py`:

```python
'read_pose = e6_group_08.read_pose:main',
```

Keep the existing `student_node` entry as well. Remember to substitute **your actual group package name** for `e6_group_08`. The two entries need commas between them.

4. Build your package from the workspace directory:

```bash
cd ~/dobot_ws
colcon build --packages-select e6_group_08
```

5. Source the rebuilt workspace in the terminal you intend to use:

```bash
source ~/dobot_ws/install/setup.bash
```

6. Run your newly registered executable:

```bash
ros2 run e6_group_08 read_pose
```

**Why rebuild and source?** `colcon build` installs the executable information from `setup.py`; sourcing tells your terminal where to find the built packages. If you forget either step, ROS 2 may say it cannot find your new executable.

> **Checkpoint:** You should now understand where to create `read_pose.py`, which line in `setup.py` connects it to `ros2 run`, and why you'll build again after adding it. Don't create the whole program yet — the next guide will take you through it.

## How your program reaches the physical robot

Your Python node does not directly communicate with the robot's network socket. The **Dobot ROS 2 driver** runs separately and exposes ROS 2 interfaces your code can use.

For example:

- **Subscribe to a topic** to receive the robot's continuously updated pose.
- **Create a service client** to request a Dobot command such as `MovJ`, `MovL`, or `ToolDOInstant`.

The [pose monitor](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/pose_monitor.py) and [movement demo](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py) in `e6_lab_support` show working examples.

Read [ROS 2 concepts](ros2-concepts.md), [topics](using-topics.md), and [services](using-services.md) whenever you need more detail.

## Next: make your own node

Go to **[4. Guided exercise — Reading the robot's position](04-reading-robot-position.md)**. You'll create `read_pose.py` yourself and make it print real data from the E6.

Remember: changes made on the lab PC are not automatically backed up. [Commit and push them to GitHub](git-and-vscode.md) before leaving.
