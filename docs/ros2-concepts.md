# ROS 2 concepts in the E6 lab

ROS 2 (Robot Operating System 2) lets separate programs exchange information and request actions. You do **not** need to understand all of ROS 2 before you can use it. This page explains the parts you will encounter in our DOBOT Magician E6 lab.

**The central idea:** your Python program communicates with the **Dobot ROS 2 driver**, and the driver communicates with the physical robot.

[← Documentation index](../README.md) · [Start the robot](02-running-the-robot.md) · [Your first node](04-reading-robot-position.md)

## The big picture

```text
Your Python program (ROS 2 node)
       |                         ^
       | service request         | topic messages / service responses
       v                         |
          DOBOT ROS 2 driver
                   |
                   | communicates with the robot
                   v
             Physical E6
```

The driver exposes interfaces for reading the robot's state and requesting actions. Other programs, such as RViz and the lab support tools, use ROS 2 to interact with the same system.

## Quick reference: what does each word mean?

| Term | Plain-English meaning | Example on the E6 |
| --- | --- | --- |
| **Workspace** | Folder containing packages that you build together | `~/dobot_ws` |
| **Package** | Group of code and configuration files | Your group package; `e6_lab_support` |
| **Node** | Running program participating in ROS 2 | Your `read_pose` node; the Dobot driver |
| **Topic** | Named stream of messages | `/dobot_msgs_v4/msg/ToolVectorActual` |
| **Publisher** | Sends messages on a topic | The driver publishes the current tool pose |
| **Subscriber** | Receives messages from a topic | Your `read_pose.py` program |
| **Message** | Structured data with named fields | `ToolVectorActual` has X, Y, Z, Rx, Ry, Rz |
| **Callback** | Python function that runs when an event is handled | `pose_callback(self, msg)` |
| **Service** | Named request/response interface | `/dobot_bringup_ros2/srv/GetPose` |
| **Client** | Sends a request to a service | Your node requesting `GetPose` or `MovJ` |
| **Launch file** | Starts and configures ROS 2 software | `dobot_bringup_ros2.launch.py` |

These terms are connected, but they are not interchangeable: a **package** contains code, a **node** runs it, and **topics/services** let nodes communicate.

## 1. Packages and nodes: what are you actually running?

Try:

```bash
ros2 run e6_lab_support pose_monitor
```

Here, `e6_lab_support` is a **package**, and `pose_monitor` is an **executable** provided by that package. The executable creates a ROS 2 node that listens to the driver's live tool position.

You can see active nodes with:

```bash
ros2 node list
```

Your own group package works in the same way. In [Understanding your package](03-understanding-the-package.md), you'll see how `setup.py` connects your Python file's `main()` function to `ros2 run`.

**Practical point:** a Python file does not automatically become a runnable ROS 2 executable just because you put it in your package.

## 2. Topics: how the robot reports what is happening

The Dobot driver publishes live tool-position data on:

```text
/dobot_msgs_v4/msg/ToolVectorActual
```

Try these commands with the driver running:

```bash
ros2 topic list
ros2 topic type /dobot_msgs_v4/msg/ToolVectorActual
ros2 interface show dobot_msgs_v4/msg/ToolVectorActual
ros2 topic echo /dobot_msgs_v4/msg/ToolVectorActual
```

The interface contains `x`, `y`, `z` (millimetres) and `rx`, `ry`, `rz` (degrees). The driver **publishes** messages; your node **subscribes** to receive them. Each received message can trigger your callback.

The [guided pose-reading exercise](04-reading-robot-position.md) takes you through creating that subscriber yourself. [Using topics](using-topics.md) explains how to explore the data further.

**Physical effect:** when the robot's tool position changes, the incoming values change. Reading a topic does **not** make the arm move.

## 3. Services: how you request information or actions

A service handles a **request** and returns a **response**. For example:

- `GetPose`: ask the driver for the current pose.
- `MovJ` and `MovL`: ask the robot to move.
- `ToolDOInstant`: switch the vacuum output on or off.
- `ToolDI`: read the vacuum-loss input.

With the driver running, inspect a real service:

```bash
ros2 service type /dobot_bringup_ros2/srv/GetPose
ros2 interface show dobot_msgs_v4/srv/GetPose
```

A service interface has request fields **above** `---` and response fields **below** it. Your Python code creates a **client**, fills out a request and calls the service.

For a read-only example, see [Using services](using-services.md). For physical actions, see [Controlling movement](controlling-movement.md) and [Controlling the vacuum gripper](controlling-the-gripper.md).

**Physical effect:** calling `MovJ` may cause real movement, but a returned service response does not necessarily mean the queued movement has finished. Always check the robot's actual state before relying on completion.

## 4. Messages and service types: where do the fields come from?

ROS 2 interfaces define the data that programs exchange. You don't have to guess what fields a message or service request contains.

```bash
ros2 interface show dobot_msgs_v4/msg/ToolVectorActual
ros2 interface show dobot_msgs_v4/srv/MovJ
```

In Python, the same interfaces are imported from different modules:

```python
from dobot_msgs_v4.msg import ToolVectorActual
from dobot_msgs_v4.srv import MovJ
```

- A **message** such as `ToolVectorActual` holds data published on a topic.
- A **service type** such as `MovJ` defines both request and response fields.

The driver repository includes the [message definitions](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/tree/main/dobot_msgs_v4/msg) and [service definitions](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/tree/main/dobot_msgs_v4/srv). These tell you the fields and types; the driver code and DOBOT manuals explain the commands' meaning and restrictions.

## 5. Callbacks and spinning: how does Python respond?

When you create a subscriber, you give it a callback function:

```python
self.subscription = self.create_subscription(
    ToolVectorActual,
    '/dobot_msgs_v4/msg/ToolVectorActual',
    self.pose_callback,
    10
)
```

When a pose message arrives, ROS 2 calls `self.pose_callback(msg)` with the new data. Your `main()` normally calls `rclpy.spin(node)` so the node continues processing events instead of immediately exiting.

A service client can also use `call_async()`, which returns a **future** that completes when a response arrives. How you wait for that future depends on whether your node is already spinning. The [services guide](using-services.md) covers this important distinction.

**Practical point:** subscribing doesn't automatically print anything. Your callback must actually do something with the received message.

## 6. ROS 2 tools: what do you type when you're stuck?

| Question | Useful command |
| --- | --- |
| What nodes are running? | `ros2 node list` |
| What topics exist? | `ros2 topic list` |
| What is coming through a topic? | `ros2 topic echo <topic_name>` |
| What type does a topic use? | `ros2 topic type <topic_name>` |
| What services exist? | `ros2 service list` |
| What type does a service use? | `ros2 service type <service_name>` |
| What fields are in an interface? | `ros2 interface show <type_name>` |
| What executables are in a package? | `ros2 pkg executables <package_name>` |

Replace placeholders such as `<topic_name>` with real names you discover. **Do not type the angle brackets literally.**

If a command cannot find a package, check that the relevant ROS 2 environment has been sourced. To run your group's own package after building it:

```bash
source ~/dobot_ws/install/setup.bash
```

See [Troubleshooting](troubleshooting.md) for common problems.

## 7. Connect the concepts to the coursework

Consider three things your application will need to do:

1. **Know where the arm is:** subscribe to the live pose topic, or request a pose using `GetPose`.
2. **Move the arm safely:** create service clients for commands such as `MovJ` or `MovL`, choosing appropriate taught positions and paths.
3. **Operate the gripper:** use `ToolDOInstant` to command vacuum and `ToolDI` to check the vacuum-loss signal.

These pieces do **not** automatically form a reliable pick-and-place program. Your group must decide how to order actions, check for failures, and establish that motion is complete before moving on.

**Quick self-check:** Can you explain which parts of the system *publish information*, which parts *request actions*, and what actually communicates with the robot? If so, you've understood the core ROS 2 ideas needed to start exploring.

## Further reading

- [ROS 2 Humble documentation](https://docs.ros.org/en/humble/)
- [Understanding nodes](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Nodes/Understanding-ROS2-Nodes.html)
- [Understanding topics](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Topics/Understanding-ROS2-Topics.html)
- [Understanding services](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Services/Understanding-ROS2-Services.html)
- [Lab support example programs](https://github.com/portsmouth-robotics/e6_lab_support)
