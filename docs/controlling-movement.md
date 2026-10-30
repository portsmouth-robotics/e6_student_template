# Controlling robot movement with ROS 2

This guide explains how to request movement from the DOBOT Magician E6, how to choose between **MovJ** and **MovL**, and what the coordinates in a movement command mean.

**The goal is to understand and adapt the working lab examples, not to copy a complete pick-and-place solution.**

[← Documentation index](../README.md) · [Using services](using-services.md) · [Controlling the gripper](controlling-the-gripper.md)

> **Safety first:** Movement commands act on the physical robot. Before testing any new target, have the position and planned motion checked by teaching staff. Keep people and objects clear of the robot's workspace. Start with reduced speed and acceleration, avoid large or unexpected moves, and never assume that a command is safe just because ROS 2 accepts it. Know how to stop the robot using its physical safety controls.

## 1. Movement has two parts: destination and path

When you tell the E6 to move, you need to think about:

1. **Where should the robot's tool end up?** This is the target *pose*.
2. **How should the robot reach it?** This is the motion type and trajectory.

A *pose* describes both **position** and **orientation**. For the lab's Cartesian commands, it contains:

| Field | Meaning | Units |
| --- | --- | --- |
| X, Y, Z | Position of the active tool centre point (TCP) | millimetres |
| Rx, Ry, Rz | Orientation of the tool | degrees |

A target pose alone does not describe the complete path the robot will take, or guarantee that the path is free of obstacles.

## 2. MovJ and MovL: what's the difference?

The E6 driver exposes both commands as ROS 2 services.

| Command | What happens | Practical consequence |
| --- | --- | --- |
| **MovJ** | The robot interpolates its joints to reach the target. | The tool's path through space is **not necessarily straight**. |
| **MovL** | The robot moves the tool centre point along a **straight Cartesian path** to the target. | Useful when the tool's path matters, such as approaching an object vertically. |

Both commands can be sent a Cartesian target pose. **A Cartesian target does not automatically mean Cartesian straight-line motion**: `MovJ` can receive a Cartesian target and still take a joint-interpolated route.

In a pick-and-place application, students should think about where straight-line tool motion is necessary, and where joint movement might be more appropriate. They should justify their choices rather than treating `MovJ` and `MovL` as interchangeable.

**Try observing:** once the lab demonstration is approved for your station, watch the physical arm and RViz when the demonstration switches between `MovJ` and `MovL`. Ask yourself whether the vacuum tool follows a straight line in each case.

## 3. Which coordinate system are you using?

The same numbers can refer to different physical positions depending on the selected coordinate frames.

The standard lab configuration uses:

- **User 0**: the robot **base** coordinate frame.
- **Tool 1**: the vacuum gripper's **tool centre point (TCP)**, configured with a **91 mm Z offset** from the robot flange.

The TCP is the reference point we care about at the end of the vacuum gripper. If you command a Cartesian pose using Tool 1, the target applies to that TCP, not simply to the metal flange holding the tool.

Before teaching or commanding positions, start the driver and run:

```bash
ros2 run e6_lab_support robot_setup
```

Check the individual setup results, not only the final printed line. The program requests control, enables the robot, selects User 0 and Tool 1, configures the tool offset, and sets the payload.

You can then see the reported tool pose using:

```bash
ros2 run e6_lab_support pose_monitor
```

**Checkpoint:** You should be able to explain what “X = 100 mm in User 0 with Tool 1 selected” means physically, and why selecting the wrong tool frame could put the gripper in the wrong place.

For more detail, consult the DOBOT E6 manual available through Moodle.

## 4. Find and inspect the movement services

With the Dobot driver running:

```bash
ros2 service list
```

Look for:

```text
/dobot_bringup_ros2/srv/MovJ
/dobot_bringup_ros2/srv/MovL
```

Find the type of either service, then inspect its fields:

```bash
ros2 service type /dobot_bringup_ros2/srv/MovJ
ros2 interface show dobot_msgs_v4/srv/MovJ
```

The `MovJ` service definition includes:

```text
bool mode
float64 a
float64 b
float64 c
float64 d
float64 e
float64 f
string[] param_value
---
string robot_return
int32 res
```

The `MovL` interface has the same request and response field layout.

**Above the `---`** are the fields you send in a request. **Below** are the fields returned by the driver.

The `mode` field changes how `a` through `f` are interpreted:

| `mode` | Meaning of `a` through `f` |
| --- | --- |
| `False` | Cartesian X, Y, Z, Rx, Ry, Rz |
| `True` | Six joint coordinates |

These mode values are specific to this DOBOT ROS 2 driver. Don't assume other robot drivers use the same interface.

**Reference definitions:** [MovJ.srv](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/srv/MovJ.srv) and [MovL.srv](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/srv/MovL.srv).

## 5. Explore the working Python movement demonstration

Open [`e6_lab_support/movement_demo.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py).

The example contains separate functions for constructing a movement request, making a service call, and requesting `MovJ` or `MovL`. Separating these jobs makes it easier to reuse code without mixing up the two movement commands.

### Step A — Create a service client

Inside a ROS 2 node's `__init__` method, the movement demo creates clients like these:

```python
from dobot_msgs_v4.srv import MovJ, MovL

self.mov_j = self.create_client(
    MovJ,
    '/dobot_bringup_ros2/srv/MovJ'
)

self.mov_l = self.create_client(
    MovL,
    '/dobot_bringup_ros2/srv/MovL'
)
```

These clients let Python ask the Dobot driver to perform movement. **Creating a client does not cause movement**.

### Step B — Construct a movement request

The following example shows how a **previously taught and verified** pose can be put into a Cartesian request:

```python
# pose is a verified six-value tuple: (X, Y, Z, Rx, Ry, Rz)
request = MovJ.Request()
request.mode = False

request.a = float(pose[0])  # X in mm
request.b = float(pose[1])  # Y in mm
request.c = float(pose[2])  # Z in mm
request.d = float(pose[3])  # Rx in degrees
request.e = float(pose[4])  # Ry in degrees
request.f = float(pose[5])  # Rz in degrees

request.param_value = [
    'user=0',
    'tool=1',
    'a=20',
    'v=20',
    'cp=0',
]
```

This illustrates request construction; it isn't a complete executable node. The lab example provides the full working context.

The values in `param_value` mean:

- `user=0`: use the robot base frame.
- `tool=1`: target the vacuum TCP.
- `a=20` and `v=20`: reduce acceleration and velocity settings for the demonstration.
- `cp=0`: disable continuous-path blending so targets are treated separately.

**Do not insert unverified positions or change these parameters without checking the resulting physical motion.** The service interface describes how to format a command, not whether it is safe.

### Step C — Send the request and read the response

The lab example uses a helper method that waits for the service, sends the request asynchronously, and processes ROS 2 events until a response arrives:

```python
client.wait_for_service()
future = client.call_async(request)
rclpy.spin_until_future_complete(self, future)
response = future.result()
```

This pattern is for a node **not already spinning in another callback**. If your own node is continuously spinning, use a suitable asynchronous completion pattern instead; see [Using services](using-services.md) and the callbacks in `pose_monitor.py`.

Check the response's `res` and `robot_return` fields. A returned response is not necessarily evidence that the physical movement has finished or that it completed successfully.

## 6. How to teach and check a pose

Before writing any movement sequence, you need suitable target positions.

The lab's `pose_monitor` tool displays the current X, Y, Z, Rx, Ry and Rz values. It can also enter **drag mode**, which allows the robot to be repositioned manually.

Under supervision, with the workspace checked:

1. Run `robot_setup` and confirm it succeeded.
2. Run `pose_monitor`.
3. Follow the tool's instructions to enter drag mode, keeping the arm properly supported.
4. Carefully guide the tool to a suitable pose approved by teaching staff.
5. Exit drag mode and make sure the joints are locked.
6. Record **all six values** and identify the User and Tool frames in use.

**Do not use a position merely because it can be reached by hand.** The approach path, clearance, orientation, suction tool and workpiece must also be considered before commanding it automatically.

For a pick-and-place task, consider what happens **above the object**, **during the approach**, **at contact**, and **when leaving the object**. Those are different motion-planning decisions, even when the intended pick and place locations are already known.

## 7. A movement command is not the same as completed movement

This is especially important for the coursework.

The DOBOT motion commands are **queued**. Sending a `MovJ` or `MovL` service request and receiving a response can mean the command has been accepted or queued—not that the physical arm has reached the requested pose.

The supplied `movement_demo.py` uses:

```python
time.sleep(3.0)
```

between motions. These waits are for a simple demonstration. They **must not be treated as a reliable motion-completion test** or a general solution for sequencing a pick-and-place task.

When designing your own application, investigate how to establish that a movement has finished. Possibilities include monitoring reported pose against a target with a suitable tolerance, and investigating any robot execution-state feedback exposed by the driver. A pose-based check alone needs careful thought about measurement tolerance, orientation, settling time and errors.

**For cycle-time measurements:** define when a trial starts and ends, confirm the physical operation has completed, and use a consistent method across trials. Timing how quickly a ROS 2 service returns is not necessarily timing the robot's motion.

Your coursework specifically requires comparing average cycle time, placement accuracy and task success across the three programming approaches. The exact assessment requirements remain those in the brief on Moodle.

## 8. Try the approved lab demonstration

Once teaching staff have checked that the demo's taught poses and paths are suitable for your E6 station, and the work area is clear:

```bash
ros2 run e6_lab_support movement_demo
```

It uses two poses which were physically taught and checked for the lab example, and demonstrates the difference between the two movement types. Read the prompts before starting and use **q** at the end of a cycle to exit.

While observing, see whether you can identify:

- Which request uses `MovJ` and which uses `MovL`.
- Which coordinate frame and TCP are used.
- Whether the TCP takes a straight path in each case.
- Why the demonstration pauses between movements.
- Why you should not copy its timing strategy unchanged into a coursework solution.

**Do not assume the example's taught coordinates are safe on a different station or with a changed fixture.**

## 9. Apply what you've learned to your coursework

Before coding your own sequence, work through these questions:

1. What six values describe each pose you intend to use?
2. Which movements require the tool to follow a controlled straight-line path?
3. Where might a joint-interpolated movement be more appropriate?
4. How will you confirm that the robot has reached a target before starting the next action?
5. How will you avoid collisions with the table, object, gripper and other equipment?
6. How will you measure the completed cycle rather than just command submission time?

This guide deliberately does **not** supply a finished pick-and-place sequence. Your group is responsible for designing, testing and explaining its own implementation.

## Further resources

- [Using ROS 2 services](using-services.md) — discovering interfaces and creating clients.
- [Using ROS 2 topics](using-topics.md) — monitoring the robot's state.
- [Controlling the vacuum gripper](controlling-the-gripper.md) — operating the gripper and reading the vacuum-loss signal.
- [Working movement example (`movement_demo.py`)](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py).
- [DOBOT ROS 2 driver](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4) — service definitions and implementation.
- **DOBOT E6 manual on Moodle** — coordinate systems, movement commands and robot operating limits.

Remember to [commit and push your code](git-and-vscode.md) before leaving the lab.
