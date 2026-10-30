# 4. Guided exercise: read the robot's position

In this exercise, you'll **write your own ROS 2 Python node** that receives live position data from the DOBOT E6 and prints it in a terminal.

You will use a **subscriber** to listen for messages from the robot. This example only **reads** the robot's position; it does not send movement commands.

**By the end, you should be able to:** create a new Python file, register it as a ROS 2 executable, subscribe to the E6 pose topic, and see live data arriving in your own program.

[← Back to the guide index](../README.md) · [← Previous: Understanding your package](03-understanding-the-package.md)

## Before you start

You should have completed the earlier guides:

1. [Clone and open your group repository](01-getting-started.md).
2. [Start the Dobot driver and run robot setup](02-running-the-robot.md).
3. [Learn where your Python files live and what `setup.py` does](03-understanding-the-package.md).

**Keep the Dobot driver running** in its own terminal. You can leave RViz running too. Do your Python editing in VS Code and run the commands below in another terminal.

The robot should be powered, connected and stationary. There's no need to move the arm to complete the basic exercise.

> **Safety:** Reading pose data is harmless, but if you later use drag mode to observe changing coordinates, do so only with appropriate supervision, the work area clear and the robot arm properly supported.

## Step 1 — Find the topic we want to read

A ROS 2 **topic** is a named channel that carries messages. The Dobot driver **publishes** the current robot pose, and your program will **subscribe** to it.

With the driver running, open a fresh terminal and enter:

```bash
ros2 topic list
```

Look for this topic:

```text
/dobot_msgs_v4/msg/ToolVectorActual
```

Find its message type:

```bash
ros2 topic type /dobot_msgs_v4/msg/ToolVectorActual
```

You should see:

```text
dobot_msgs_v4/msg/ToolVectorActual
```

The **topic name** identifies where messages are published. The **message type** defines what information each message contains.

Inspect that type:

```bash
ros2 interface show dobot_msgs_v4/msg/ToolVectorActual
```

Look for the fields `x`, `y`, `z`, `rx`, `ry` and `rz`. The first three represent tool position in **millimetres**; the last three represent orientation in **degrees**.

You can also look directly at the messages being published:

```bash
ros2 topic echo /dobot_msgs_v4/msg/ToolVectorActual
```

Press **Ctrl+C** to stop the output.

**Checkpoint:** You can see pose messages arriving without writing any Python yet. If no messages appear, check that the Dobot driver is running and connected.

## Step 2 — Create your Python file

In VS Code, open your group repository. Inside the **inner Python source folder** (the one containing `student_node.py` and `__init__.py`), create a new file called:

```text
read_pose.py
```

For example, your repository might contain:

```text
e6_group_08/
├── setup.py
├── package.xml
└── e6_group_08/
    ├── __init__.py
    ├── student_node.py
    └── read_pose.py       ← your new file
```

The names in your repository may differ. Use the group package name prepared for you.

## Step 3 — Import the ROS 2 tools

At the top of `read_pose.py`, add:

```python
import rclpy
from rclpy.node import Node
from dobot_msgs_v4.msg import ToolVectorActual
```

Here's what you're importing:

- `rclpy` gives Python access to ROS 2.
- `Node` provides the building blocks for a ROS 2 node.
- `ToolVectorActual` is the **Dobot message type** you discovered in Step 1. Importing it tells Python what kind of data to expect.

**Notice the connection:** `ros2 interface show` lets you inspect a message type at the terminal; the Python import lets your program use that same message type.

## Step 4 — Create a node class

Below the imports, add:

```python
class ReadPose(Node):
    def __init__(self):
        super().__init__('read_pose')
        self.get_logger().info('Waiting for E6 pose messages...')
```

This defines a class named `ReadPose` that inherits from the ROS 2 `Node` class.

When the class is created, its `__init__` method runs. The `super().__init__('read_pose')` line gives the running ROS 2 node its name, and the next line prints a startup message.

Right now, your node doesn't receive any data. We'll add that next.

## Step 5 — Subscribe to the robot's pose

Inside `__init__`, **after the logger line**, add:

```python
        self.subscription = self.create_subscription(
            ToolVectorActual,
            '/dobot_msgs_v4/msg/ToolVectorActual',
            self.pose_callback,
            10
        )
```

This tells ROS 2:

- **`ToolVectorActual`** — the type of message to receive.
- **`'/dobot_msgs_v4/msg/ToolVectorActual'`** — the topic to listen to.
- **`self.pose_callback`** — the function to run each time a message arrives.
- **`10`** — the depth of the message queue, so a small number of messages can be buffered.

You are creating a *subscriber*. The Dobot driver is already publishing the messages; you don't need to make it publish them again.

Your code now refers to `self.pose_callback`, but that method doesn't exist yet. Let's create it.

## Step 6 — Add the callback

Below `__init__`, but still **inside the `ReadPose` class**, add:

```python
    def pose_callback(self, msg):
        self.get_logger().info(
            f'X: {msg.x:.1f} mm, '
            f'Y: {msg.y:.1f} mm, '
            f'Z: {msg.z:.1f} mm'
        )
```

A **callback** is a function that ROS 2 calls when something happens — in this case, when a new pose message is received.

The `msg` argument contains the latest `ToolVectorActual` message. You can access its fields using `msg.x`, `msg.y` and `msg.z`.

The `f'...'` syntax is a Python formatted string. The `:.1f` displays a number to one decimal place.

For now, we're displaying only the **position**. Later, you could also show `msg.rx`, `msg.ry` and `msg.rz` to display orientation.

**Checkpoint:** Your class now has two methods: `__init__`, which sets up the subscriber, and `pose_callback`, which handles incoming messages.

## Step 7 — Add the main function

Below the class (no longer indented inside it), add:

```python
def main(args=None):
    rclpy.init(args=args)
    node = ReadPose()

    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()


if __name__ == '__main__':
    main()
```

The steps are:

1. **`rclpy.init()`** starts ROS 2 support in your Python process.
2. **`ReadPose()`** creates your node, including its subscriber.
3. **`rclpy.spin(node)`** keeps the node processing incoming messages. Without this, your program would finish before it could do its job.
4. **`finally`** ensures the node and ROS 2 resources are cleaned up when the program stops.

The last two lines also let you run the file directly with Python. For this exercise, we'll run it through ROS 2 instead.

**Save** `read_pose.py` in VS Code before moving on.

If you're stuck, compare the overall structure with the supplied `student_node.py`. You should recognise the same pattern: imports → node class → `main()`.

## Step 8 — Register your new executable

Creating a Python file does **not** automatically add it to ROS 2's executable list.

Open `setup.py` in the **top level** of your repository. Find `entry_points` and its `console_scripts` list. Keep the existing `student_node` entry and add one for your new file:

```python
entry_points={
    'console_scripts': [
        'student_node = e6_group_08.student_node:main',
        'read_pose = e6_group_08.read_pose:main',
    ],
},
```

**Replace `e6_group_08` in both lines with your group's actual Python package name.** Your `setup.py` already contains the correct name in the existing `student_node` entry, so use that as the pattern. Make sure each entry has a comma.

The new line means that:

```bash
ros2 run e6_group_08 read_pose
```

will call the `main()` function in `e6_group_08/read_pose.py`.

Save `setup.py`.

## Step 9 — Build and run your node

Open another terminal in VS Code. From the ROS 2 workspace, **replace the example group package name** in the build command:

```bash
cd ~/dobot_ws
colcon build --packages-select e6_group_08
```

When the build succeeds, source the workspace:

```bash
source ~/dobot_ws/install/setup.bash
```

Then run your new executable, again using your package name:

```bash
ros2 run e6_group_08 read_pose
```

You should see the startup message, followed by repeated lines resembling:

```text
[INFO] [...] [read_pose]: Waiting for E6 pose messages...
[INFO] [...] [read_pose]: X: -100.0 mm, Y: 150.0 mm, Z: 250.0 mm
[INFO] [...] [read_pose]: X: -100.0 mm, Y: 150.0 mm, Z: 250.0 mm
```

These are **illustrative numbers**, not positions you should command the robot to reach. Your real readings will depend on the arm's current pose.

**Success!** Your own Python node is now receiving live data from the real E6.

Press **Ctrl+C** when you want to stop the program.

## Step 10 — Experiment and understand what you've built

Try these small changes, one at a time:

1. **Display orientation as well as position.** Extend the callback to print `msg.rx`, `msg.ry` and `msg.rz`. Refer to the fields you saw using `ros2 interface show`.
2. **Change the displayed precision.** Try `:.2f` instead of `:.1f` and observe the difference.
3. **Observe changing coordinates.** With supervision, use the lab's `pose_monitor` drag mode to gently move the arm, then lock the joints again. Watch the values change in your own node. Never force the robot or leave it in drag mode.

After changing the Python file, save it and rebuild before running your updated installed executable. Follow the normal source-and-run steps again.

For a more advanced implementation, read the source of [`e6_lab_support/pose_monitor.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/pose_monitor.py). It subscribes to the **same topic**, but also handles drag mode and displays additional information. You don't need to understand every line yet.

## If it doesn't work

| What you see | What to check |
| --- | --- |
| `Package not found` | Use the group package name from `package.xml`; check the build succeeded and source `install/setup.bash`. |
| `No executable found` | Check the `read_pose` entry in `setup.py` and rebuild the package. |
| Python import or indentation error | Check spelling, indentation and that `pose_callback` is inside the class. |
| Startup message but no pose values | Is the Dobot driver running? Does `ros2 topic echo /dobot_msgs_v4/msg/ToolVectorActual` show any messages? |
| Your changes don't appear | Save the file, rebuild, source the workspace and run the new executable again. |

For more help, see [Troubleshooting](troubleshooting.md).

## What you've learned

You've connected several ROS 2 ideas to something real:

- A **topic** is where the driver publishes live data.
- A **message type** describes the values in each message.
- A **subscriber** tells your node which topic to listen to.
- A **callback** runs your Python code when a message arrives.
- An **entry point** in `setup.py` makes your node executable with `ros2 run`.

**Next:** Explore [using topics](using-topics.md) and [using services](using-services.md). Services are how you'll ask the Dobot driver to perform actions, rather than just report information.

Before leaving, [commit and push your work to GitHub](git-and-vscode.md), then follow the [end-of-session checklist](../IMPORTANT.md). Your `read_pose.py` file and `setup.py` changes should both appear in your repository online.
