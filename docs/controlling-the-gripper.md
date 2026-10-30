# Controlling the vacuum gripper

The DOBOT Magician E6 in our lab has a **vacuum gripper**. You can switch the vacuum on and off through a ROS 2 **digital output**, and check the vacuum-loss signal through a **digital input**.

This guide shows how to discover those interfaces, test them with the supplied lab program, and use them in your own Python code. It does **not** provide a finished pick-and-place sequence.

[← Documentation index](../README.md) · [Using services](using-services.md) · [Controlling movement](controlling-movement.md)

> **Safety:** Test the gripper with the robot stationary and its work area clear. Ensure the gripper is not carrying an object that could fall when vacuum is released. Never rely on suction alone to keep an object safe around people. Follow the teaching staff's instructions before moving the arm with an object attached.

## 1. Two different signals: command and feedback

The vacuum system uses two signals in our lab configuration:

| Signal | Purpose | ROS 2 interface |
| --- | --- | --- |
| **Tool DO1** — digital output 1 | Commands the vacuum **on or off** | `ToolDOInstant` service |
| **Tool DI2** — digital input 2 | Reports the **vacuum-loss** signal | `ToolDI` service |

These are not the same thing. **Commanding the vacuum on does not prove that a cube is attached.** The input provides additional feedback that can help your application detect a lost seal.

In the supplied `hardware_test.py` example, DI2 is interpreted as:

- **0** — vacuum-loss signal not asserted (*seal OK* in the test output).
- **1** — vacuum-loss signal asserted (*vacuum lost* in the test output).

The input's interpretation is specific to this lab's wiring and sensor. A value of 0 is **not, by itself, proof that an object is held**, especially when the vacuum is off. Verify behaviour on your physical station before using the signal to make decisions.

## 2. Discover the services in ROS 2

Start the driver, as in [Running the robot](02-running-the-robot.md). Run the usual robot setup and check the results:

```bash
ros2 run e6_lab_support robot_setup
```

Then list services:

```bash
ros2 service list
```

Find these entries:

```text
/dobot_bringup_ros2/srv/ToolDOInstant
/dobot_bringup_ros2/srv/ToolDI
```

Find their types:

```bash
ros2 service type /dobot_bringup_ros2/srv/ToolDOInstant
ros2 service type /dobot_bringup_ros2/srv/ToolDI
```

Inspect the request and response definitions:

```bash
ros2 interface show dobot_msgs_v4/srv/ToolDOInstant
ros2 interface show dobot_msgs_v4/srv/ToolDI
```

The driver defines them as:

**ToolDOInstant:**
```text
int32 index
int32 status
---
int32 res
```

**ToolDI:**
```text
int32 index
---
string robot_return
int32 res
```

Above the `---` are request fields; below are response fields. Notice that the output service needs **both the channel number and desired state**, whereas the input service only needs the channel number.

**Checkpoint:** You can explain why `ToolDOInstant` needs `status` but `ToolDI` doesn't.

## 3. Run the lab's hardware test

With the robot stationary and the work area checked, run:

```bash
ros2 run e6_lab_support hardware_test
```

This program:

1. Requests control of the robot and enables it.
2. Turns vacuum **on** through Tool DO1.
3. Repeatedly reads the vacuum-loss status from Tool DI2.
4. Displays the reported input state.
5. Waits for **Enter**, then sends the command to turn the vacuum **off**.

**What to observe:** When you test the gripper against an appropriate object or surface, see how DI2 responds when the suction seal is established and when the seal is broken. Only do this as instructed by staff, with the robot stationary and without putting hands in an unsafe position.

**Before leaving this step, check that the vacuum is off.** If the program exits unexpectedly, verify the output state rather than assuming its normal cleanup sequence completed.

Read the working source: [`hardware_test.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py).

## 4. Switch the vacuum using a service request

The vacuum command uses `ToolDOInstant`. In the lab setup:

- `index = 1` selects **Tool DO1**.
- `status = 1` requests **vacuum on**.
- `status = 0` requests **vacuum off**.

You can inspect the complete request format with:

```bash
ros2 interface show dobot_msgs_v4/srv/ToolDOInstant
```

To switch the vacuum on from a terminal **only when the stationary test is safe**, use:

```bash
ros2 service call /dobot_bringup_ros2/srv/ToolDOInstant dobot_msgs_v4/srv/ToolDOInstant "{index: 1, status: 1}"
```

To switch it off:

```bash
ros2 service call /dobot_bringup_ros2/srv/ToolDOInstant dobot_msgs_v4/srv/ToolDOInstant "{index: 1, status: 0}"
```

**Do not leave the vacuum running unintentionally.** Check the returned `res` value and verify what happened on the physical hardware.

This is the same interface the Python hardware test uses.

## 5. Read the vacuum-loss signal

To request the state of Tool DI2:

```bash
ros2 service call /dobot_bringup_ros2/srv/ToolDI dobot_msgs_v4/srv/ToolDI "{index: 2}"
```

The service response contains `robot_return` and `res`. The example code removes surrounding braces from the `robot_return` string before checking whether it is `0` or `1`.

This is **one reading**. If you want to track changes over time, your own code needs to request the value again when appropriate. Unlike a continuously published topic, this input is read through a service request.

**Checkpoint:** You can identify which command *changes* the vacuum output and which command merely *reads* the vacuum-loss input.

## 6. Use these interfaces in Python

The working [`hardware_test.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py) contains the complete implementation. The pieces below show what to look for and adapt in your own node.

### Import and create clients

```python
from dobot_msgs_v4.srv import ToolDOInstant, ToolDI

# Inside your ROS 2 node's __init__ method:
self.tool_do = self.create_client(
    ToolDOInstant,
    '/dobot_bringup_ros2/srv/ToolDOInstant'
)
self.tool_di = self.create_client(
    ToolDI,
    '/dobot_bringup_ros2/srv/ToolDI'
)
```

This sets up access to the two services; it **doesn't switch the vacuum on** yet.

### Construct an output request

```python
request = ToolDOInstant.Request()
request.index = 1
request.status = 1  # vacuum ON
```

For vacuum **off**, the same request type uses `request.status = 0`.

### Construct an input request

```python
request = ToolDI.Request()
request.index = 2
```

There is no `status` field on this request: you're asking for the input's current state.

### Call the service

The lab example includes a helper method:

```python
def call_service(self, client, request):
    client.wait_for_service()
    future = client.call_async(request)
    rclpy.spin_until_future_complete(self, future)
    return future.result()
```

When using that helper, a request can be sent like this:

```python
response = self.call_service(self.tool_di, request)
```

**Important:** This helper is intended for a program making requests while its node is **not already being spun by another callback**. If your node is already processing subscriptions or timers, use a suitable asynchronous pattern rather than copying the blocking wait inside a callback. See [Using services](using-services.md) for more detail.

For the input response, the supplied program uses:

```python
state = response.robot_return.strip('{}')
```

Then compares `state` with `'0'` and `'1'`. In your own code, also check for failed service calls or unexpected responses instead of assuming every request succeeded.

## 7. Apply this to your coursework

The vacuum is one part of a reliable pick-and-place operation. Your group needs to consider more than simply switching it on and off.

Think about:

1. **Before pickup:** How will you know the tool is positioned correctly relative to the cube?
2. **At pickup:** When should you turn the vacuum on?
3. **After pickup:** What evidence will you use to decide whether the vacuum seal is established?
4. **During transport:** What should the program do if vacuum-loss feedback indicates a problem?
5. **At placement:** How will you release the cube without disturbing its final position?
6. **On failure:** What is a safe response if a command fails or the cube is not held?

These are application-design decisions your group should make, implement and explain.

**Do not treat DI2 as a complete object-detection or task-success sensor.** The coursework also requires physical placement accuracy and task success evaluation, which need an appropriate measurement method.

## 8. Investigate the code yourself

Use `hardware_test.py` and the interface commands to answer these questions:

- Where does the program create the two service clients?
- Which request switches the output on? Which switches it off?
- Why does `hardware_test.py` use `index = 2` to read the input but `index = 1` for the output?
- Where does it interpret `robot_return`?
- If the program crashes while suction is on, what should the operator check before leaving the station?

For the service definitions, see [ToolDOInstant.srv](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/srv/ToolDOInstant.srv) and [ToolDI.srv](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4/blob/main/dobot_msgs_v4/srv/ToolDI.srv). The Dobot manuals on Moodle provide additional information about the hardware and I/O.

## Further reading and next steps

- [Using ROS 2 services](using-services.md) — how requests, responses and Python service clients work.
- [Controlling robot movement](controlling-movement.md) — moving to safe, taught poses.
- [The lab hardware test source](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py) — complete working example.
- [ROS 2 Humble: Understanding services](https://docs.ros.org/en/humble/Tutorials/Beginner-CLI-Tools/Understanding-ROS2-Services/Understanding-ROS2-Services.html).

Remember to [commit and push your work](git-and-vscode.md) and follow the [before-leaving checklist](../IMPORTANT.md).
