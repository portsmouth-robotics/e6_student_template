# Using ROS 2 services with the DOBOT E6

A **service** lets one ROS 2 node ask another node to do something or return information. In this lab, your Python program can send requests to the **Dobot driver**, which communicates with the real robot.

**Start with a read-only request:** ask the E6 for its current pose. After that, you'll learn where to find the movement and vacuum services needed for your own coursework.

[← Documentation index](../README.md) · [ROS 2 concepts](ros2-concepts.md) · [Topics](using-topics.md)

## The idea: request → response

Imagine asking the driver, “Where is the robot's tool right now?”

1. Your Python node acts as a **client**.
2. The Dobot driver provides a **service**.
3. Your client sends a **request** containing any parameters the service needs.
4. The driver sends a **response**, including data or a result code.

Unlike a **topic**, which continuously publishes messages, a service responds to individual requests. See [Reading the robot's position](04-reading-robot-position.md) for a topic subscriber that receives pose updates continuously.

## 1. Discover the services

Start the driver as described in [Running the robot](02-running-the-robot.md). In another Ubuntu terminal, run:

```bash
ros2 service list
```

You'll see many services. Some of the E6 driver's services are:

```text
/dobot_bringup_ros2/srv/GetPose
/dobot_bringup_ros2/srv/MovJ
/dobot_bringup_ros2/srv/MovL
/dobot_bringup_ros2/srv/ToolDOInstant
/dobot_bringup_ros2/srv/ToolDI
```

**What do these do?** `GetPose` requests the tool pose; `MovJ` and `MovL` request movement; `ToolDOInstant` changes a digital output (used for the vacuum); `ToolDI` reads a tool digital input.

These are **service names**. To find out what a service expects, ask ROS 2 for its **service type**:

```bash
ros2 service type /dobot_bringup_ros2/srv/GetPose
```

It should report:

```text
dobot_msgs_v4/srv/GetPose
```

Now inspect the type:

```bash
ros2 interface show dobot_msgs_v4/srv/GetPose
```

The driver defines this interface:

```text
int32 user
int32 tool
---
string robot_return
int32 res
```

Everything **above** `---` belongs to the request; everything **below** it belongs to the response.

Here, `user` specifies a user coordinate frame and `tool` specifies a tool frame. For our standard setup, use **User 0** (base) and **Tool 1** (vacuum tool centre point).

**Checkpoint:** You can discover a service, identify its type, and inspect the fields you must provide.

## 2. Make a read-only request from the terminal

With the driver connected and the robot configured using `robot_setup`, try:

```bash
ros2 service call /dobot_bringup_ros2/srv/GetPose dobot_msgs_v4/srv/GetPose "{user: 0, tool: 1}"
```

This sends one request to the service. It **does not command motion**.

Look at the response. It contains:

- `robot_return`: the driver's text response containing the pose data;
- `res`: a result/status code.

The actual pose depends on the physical robot's position. Don't treat an arbitrary value or the mere presence of a response as proof that everything succeeded; inspect the returned result.

**Why use the terminal first?** It proves you have the right service name, type, and request fields before trying to write Python.

**Checkpoint:** You receive a service response from the E6.

## 3. Use the same service from Python

Open your group's `student_node.py`, or refer back to [the package structure guide](03-understanding-the-package.md) if you're not sure where it lives.

You can use a ROS 2 **service client** inside a Python node. The simplest pattern is demonstrated by the lab's [`robot_setup.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/robot_setup.py).

### A. Import the service type

Alongside your other imports:

```python
from dobot_msgs_v4.srv import GetPose
```

You found the name `GetPose` using `ros2 service type` and `ros2 interface show`.

### B. Create a service client

Inside your node's `__init__` method:

```python
self.get_pose_client = self.create_client(
    GetPose,
    '/dobot_bringup_ros2/srv/GetPose'
)
```

This tells ROS 2 which **service type** and **service name** the client uses. It doesn't send a request yet.

### C. Construct a request

When you're ready to make the request:

```python
request = GetPose.Request()
request.user = 0
request.tool = 1
```

These fields match those shown by `ros2 interface show`.

### D. Call the service and examine the response

For a **one-off request in a node that is not already spinning**, the pattern is:

```python
if not self.get_pose_client.wait_for_service(timeout_sec=5.0):
    self.get_logger().error('GetPose service is not available')
    return

future = self.get_pose_client.call_async(request)
rclpy.spin_until_future_complete(self, future)

response = future.result()
if response is None:
    self.get_logger().error('GetPose request failed')
    return

self.get_logger().info(f'Result code: {response.res}')
self.get_logger().info(f'Pose: {response.robot_return}')
```

**What is a future?** `call_async()` starts the request without immediately blocking for a response; a *future* represents the result that will arrive later. `spin_until_future_complete` allows ROS 2 to process events until that response arrives.

**Important:** This example assumes your node is **not already running under** `rclpy.spin(node)`. If you're calling services from a subscriber callback or a timer in an already-spinning node, use asynchronous callbacks or another suitable executor pattern. Don't blindly call `spin_until_future_complete` from inside an active callback. The [`pose_monitor.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/pose_monitor.py) example shows how to attach a completion callback to a future.

The code snippets above are the **pieces** of a client, not a complete new script. Study how `robot_setup.py` combines them with a node class, a `run_setup()` method and `main()`.

## 4. Find other services needed for your coursework

The same process works with movement and gripper commands:

| Task | Service type | Existing example |
| --- | --- | --- |
| Request current pose | `GetPose` | This guide |
| Move through joint-interpolated motion | `MovJ` | [movement_demo.py](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py) |
| Move along a Cartesian straight line | `MovL` | [movement_demo.py](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py) |
| Switch vacuum output on/off | `ToolDOInstant` | [hardware_test.py](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py) |
| Read vacuum-loss input | `ToolDI` | [hardware_test.py](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py) |

For example, to inspect the movement request **without moving the robot**:

```bash
ros2 interface show dobot_msgs_v4/srv/MovJ
```

Its fields include `mode`, `a`–`f`, and `param_value`. In this driver:

- `mode: false` interprets `a`–`f` as Cartesian **X, Y, Z, Rx, Ry, Rz**.
- `mode: true` interprets them as joint coordinates.
- `param_value` carries optional movement settings. The lab's movement example uses `user=0`, `tool=1`, and reduced speed/acceleration settings.

**Do not copy example coordinates into a motion request without checking that they are safe for your station and task.** A service returning a response does not necessarily mean a queued physical movement has completed.

To inspect the vacuum services:

```bash
ros2 interface show dobot_msgs_v4/srv/ToolDOInstant
ros2 interface show dobot_msgs_v4/srv/ToolDI
```

The lab setup uses output **DO1** to control the vacuum and input **DI2** to read the vacuum-loss signal. See [Controlling the gripper](controlling-the-gripper.md) for the details.

## 5. Where to find authoritative information

There are three useful layers of reference:

1. **Your running system:** `ros2 service list`, `ros2 service type`, and `ros2 interface show` tell you what is available and what fields the ROS 2 interface exposes.
2. **The installed driver source:** the [University of Portsmouth DOBOT ROS 2 driver](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4) contains the service definitions under `dobot_msgs_v4/srv/` and the code that translates ROS 2 requests into robot commands. For instance, see [GetPose.srv](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/srv/GetPose.srv).
3. **The DOBOT documentation:** the robot manual on Moodle and the manufacturer's communication/API documentation explain the meaning, parameters, and constraints of robot commands. A ROS 2 `.srv` definition lists *field names and types*; it does not necessarily explain all physical effects or restrictions.

For general ROS 2 background, see the official [Understanding services](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Services/Understanding-ROS2-Services.html) and [Writing a Python service and client](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Service-And-Client.html) tutorials.

## 6. A practical investigation

Before you write any movement logic, try answering these questions using the commands and links above:

1. What is the full service name and service type for `MovL`?
2. Which fields describe its requested target pose?
3. How does the driver distinguish joint coordinates from Cartesian coordinates?
4. Where in `movement_demo.py` is the client created, and where is the request sent?
5. Which vacuum service has an `index` and `status` request, and which only has `index`?

You should be able to work out the answers from the service definitions and source code—without moving the robot.

**Next:** [Controlling movement](controlling-movement.md) or [Controlling the gripper](controlling-the-gripper.md). Both connect these service concepts to the actions your robot needs to perform.

Before leaving the lab, [commit and push your changes](git-and-vscode.md) and follow the [end-of-session checklist](../IMPORTANT.md).
