# Using ROS 2 topics with the DOBOT E6

A **topic** is how ROS 2 nodes share a stream of information. The Dobot driver publishes the robot's current state, and your program can subscribe to that information.

**What you'll learn:** how to discover topics, inspect their messages, and use a subscriber and callback in your own Python node. We'll use the **actual tool position** as our example.

[← Documentation index](../README.md) · [Guided pose-reading exercise](04-reading-robot-position.md) · [Using services](using-services.md)

## Why use a topic?

Imagine watching the position of the vacuum gripper as the robot moves:

- The **Dobot driver** is the *publisher*: it sends updated pose messages.
- The **topic** is the named channel carrying those messages.
- Your **subscriber** receives them.
- Your **callback** is the Python method ROS 2 runs for each received message.

You don't have to request every new position individually. The driver publishes updates, and subscribed nodes receive them as they arrive.

This is different from a **service**, where your program sends a specific request and waits for a response. See [Using services](using-services.md) for an example that requests the current pose with `GetPose`.

## 1. Find the real robot's topics

First [start the Dobot driver](02-running-the-robot.md). Open another terminal and run:

```bash
ros2 topic list
```

Find:

```text
/dobot_msgs_v4/msg/ToolVectorActual
```

This is the topic used by the lab's pose monitor. Ask ROS 2 what type of message it carries:

```bash
ros2 topic type /dobot_msgs_v4/msg/ToolVectorActual
```

Expected type:

```text
dobot_msgs_v4/msg/ToolVectorActual
```

Now see how the messages are defined:

```bash
ros2 interface show dobot_msgs_v4/msg/ToolVectorActual
```

You should find six fields:

```text
float64 x
float64 y
float64 z
float64 rx
float64 ry
float64 rz
```

For this robot, `x`, `y`, `z` are position in **millimetres**, and `rx`, `ry`, `rz` describe orientation in **degrees**. The coordinates refer to the robot's tool pose; the active user and tool frames matter when interpreting them. Our standard setup selects **User 0** (base) and **Tool 1** (vacuum TCP).

**Connection to Python:** the interface name is also the message type you import with `from dobot_msgs_v4.msg import ToolVectorActual`.

## 2. Watch the data without writing a program

Run:

```bash
ros2 topic echo /dobot_msgs_v4/msg/ToolVectorActual
```

You should see successive messages containing those six fields. Even while the robot is stationary, the driver may continue publishing the current pose.

Press **Ctrl+C** to stop the output.

Two other useful commands:

```bash
ros2 topic info /dobot_msgs_v4/msg/ToolVectorActual
ros2 topic hz /dobot_msgs_v4/msg/ToolVectorActual
```

- `topic info` helps you see how many publishers and subscribers are connected.
- `topic hz` measures approximately how often messages arrive. Stop it with **Ctrl+C**. Don't assume this rate is the speed at which the robot physically moves.

**Checkpoint:** You can find the pose topic, inspect its fields and see live messages before writing code.

If no messages appear, verify that the driver is running and connected; see [Troubleshooting](troubleshooting.md).

## 3. Receive the same messages in Python

If you completed [Guide 04: Reading the robot's position](04-reading-robot-position.md), you've already created a subscriber. Here's the key part again:

```python
from dobot_msgs_v4.msg import ToolVectorActual

# Inside your ROS 2 Node class's __init__ method:
self.subscription = self.create_subscription(
    ToolVectorActual,
    '/dobot_msgs_v4/msg/ToolVectorActual',
    self.pose_callback,
    10
)
```

The four arguments are:

| Argument | Purpose |
| --- | --- |
| `ToolVectorActual` | The message type, which determines the fields available to your Python code |
| Topic name | Which named stream to listen to |
| `self.pose_callback` | The method to run for each received message |
| `10` | Queue depth, allowing a small number of incoming messages to be buffered |

The callback is a method in the **same node class**:

```python
def pose_callback(self, msg):
    self.get_logger().info(
        f'X={msg.x:.1f}, Y={msg.y:.1f}, Z={msg.z:.1f} mm'
    )
```

Each time a message is delivered, ROS 2 gives it to your callback as `msg`. The fields you use (`msg.x`, `msg.y`, etc.) come from the `ToolVectorActual` message definition you inspected earlier.

Your program must also keep processing ROS 2 events—typically with `rclpy.spin(node)` in `main()`—or the callback won't run.

**Try it:** run your `read_pose` node from Guide 04. Compare its printed values with `ros2 topic echo`. Both are listening to the *same* stream from the driver.

## 4. Make the data useful in your own program

You don't have to print every message. Your node can **remember the latest pose** and use it elsewhere:

```python
# In __init__, before creating the subscription:
self.current_pose = None

# In the node class:
def pose_callback(self, msg):
    self.current_pose = msg
```

Now `self.current_pose` holds the most recently received pose, or `None` until the first message arrives. A different method in your node can check it before using any position values:

```python
if self.current_pose is None:
    self.get_logger().info('Still waiting for pose data')
else:
    self.get_logger().info(f'Latest X: {self.current_pose.x:.1f} mm')
```

This snippet belongs **inside a method of your class**; it isn't a complete standalone program.

**Why is this useful for coursework?** Reading current positions can help you check taught locations, observe actual motion, and collect measurements. You still need to decide what to measure and how to assess accuracy; receiving pose messages alone does not establish physical placement accuracy.

For an example that stores and displays the latest pose, inspect [`e6_lab_support/pose_monitor.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/pose_monitor.py). It uses the same `ToolVectorActual` topic as your exercise.

## 5. What about publishers?

So far, you've made a **subscriber** because the driver already publishes the robot's pose. But your own Python node can publish information too.

For example, you might eventually publish a simple status message from your application so another node can see whether your program is **waiting**, **moving**, or **finished**. This does *not* directly control the Dobot—publishing your own topic does not cause the robot to move unless another node is explicitly programmed to act on it.

The basic pattern in a Python ROS 2 node is:

```python
from std_msgs.msg import String

# In __init__:
self.status_publisher = self.create_publisher(
    String,
    'student_status',
    10
)

# When you want to publish a status:
message = String()
message.data = 'waiting'
self.status_publisher.publish(message)
```

This is an **illustration**, not a required part of the E6 exercise. It introduces a separate ROS 2 message dependency (`std_msgs`), which your package would need declared in `package.xml` if you choose to use it. You do not need to add a publisher to complete the pick-and-place task.

For a complete worked publisher/subscriber pair, see the [official ROS 2 Humble Python tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html).

## 6. Know when to use a topic or a service

| You want to… | Likely approach |
| --- | --- |
| Continuously watch the tool's position | **Subscribe** to `ToolVectorActual` |
| Request the current pose once | **Call** the `GetPose` service |
| Ask the robot to move to a target pose | **Call** a movement service such as `MovJ` or `MovL` |
| Switch the vacuum gripper on or off | **Call** `ToolDOInstant` |
| Read the vacuum-loss digital input | **Call** `ToolDI` |

The service examples are described in [Using services](using-services.md). For the physical actions, continue to [Controlling movement](controlling-movement.md) and [Controlling the gripper](controlling-the-gripper.md).

## 7. Explore further

Try answering these without changing the robot's state:

1. Which command shows the **type** of a topic, and which shows the **fields** of that type?
2. Which callback receives pose messages in the lab's `pose_monitor.py`?
3. What happens if your node has started but no pose message has arrived yet?
4. How would you modify `read_pose.py` to display `rx`, `ry`, and `rz`?
5. Why would you use a service rather than a topic when you want to command the vacuum?

References: [Understanding ROS 2 topics](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Topics/Understanding-ROS2-Topics.html), [Python publisher/subscriber tutorial](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html), and the [Dobot ToolVectorActual message definition](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/msg/ToolVectorActual.msg).

If you've edited your group's code, remember to [commit and push it to GitHub](git-and-vscode.md) before leaving the lab.
