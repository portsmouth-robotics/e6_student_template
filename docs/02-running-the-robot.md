# 2. Running the DOBOT E6 with ROS 2

In this guide you'll start the software that communicates with the robot, display its live state in RViz, and try some of the lab's ready-made ROS 2 tools.

**By the end, you should be able to:** start and configure the E6, read its tool position, and understand which program is responsible for each part of the system.

[← Back to the guide index](../README.md) · [← Previous: Getting started](01-getting-started.md) · [Next: Understanding the package →](03-understanding-the-package.md)

## Before starting

Use an **Ubuntu lab PC connected to its assigned E6**. Confirm the robot is powered and ready, and that there are no people, tools, cables or other obstacles in its working area.

**Robot safety:** Keep clear of the robot's moving parts. Before running any movement example, make sure the robot and gripper have a clear path. Do not use untested coordinates or move the robot outside its intended working area. Ask for help if the robot reports an error or behaves unexpectedly.

The lab PCs already have **ROS 2 Humble**, the DOBOT driver, and the `e6_lab_support` package installed. The robot's IP address and type are preconfigured in the lab Linux environment; you shouldn't need to enter them.

## Why do we need several programs?

ROS 2 is a system in which separate programs, called **nodes**, can exchange information and request actions. We will start several programs, each in its own terminal:

| Terminal | Program | What it does |
| --- | --- | --- |
| **1** | Dobot driver | Connects ROS 2 to the real E6 and provides services and live robot data. |
| **2** | RViz | Shows a 3D representation of the robot using information from ROS 2. |
| **3** | Robot setup and tools | Configures the robot and lets you try diagnostic and example programs. |

**Keep terminals 1 and 2 running.** You can reuse terminal 3 for different commands.

For a short explanation of nodes, topics and services, see [ROS 2 concepts in this lab](ros2-concepts.md).

## Step 1 — Start the Dobot driver (Terminal 1)

1. Open VS Code and select **Terminal → New Terminal**.
2. Run:

```bash
ros2 launch dobot_bringup_v4 dobot_bringup_ros2.launch.py
```

A *launch file* starts and configures ROS 2 software. In this case it starts the driver that communicates with the E6.

**Check:** The command stays running and produces startup messages. Watch for connection errors. Leave this terminal open; don't press Ctrl+C.

If ROS reports `package not found`, see [Troubleshooting](troubleshooting.md). If the driver cannot connect to the robot, check the robot's power and connection and ask for assistance rather than changing network settings at random.

<!-- SCREENSHOT TODO: Driver terminal and its normal startup output. -->

## Step 2 — Open RViz (Terminal 2)

1. Open a **second** terminal in VS Code (the **+** in the Terminal panel, or Terminal → New Terminal).
2. Run:

```bash
ros2 launch dobot_rviz dobot_rviz.launch.py live_hardware:=true
```

**RViz** is a visualisation tool. It shows what ROS 2 knows about the robot; it is not the program that commands robot motion.

**Check:** An RViz window opens with a model of the E6. When the robot moves, the model should update to reflect its current position. Leave this terminal running too.

<!-- SCREENSHOT TODO: RViz with live E6 model, and the second terminal. -->

## Step 3 — Configure the robot (Terminal 3)

Open a **third** terminal and run:

```bash
ros2 run e6_lab_support robot_setup
```

The `ros2 run` command starts an executable from an installed ROS 2 package. Here, `e6_lab_support` is the package and `robot_setup` is the executable.

The setup program:

- requests control of the E6 and enables it;
- selects **User 0**, the robot-base coordinate frame;
- configures and selects **Tool 1**, the vacuum gripper's tool centre point (TCP), with a **91 mm Z offset**;
- sets the vacuum tool's approximate payload.

Why does this matter? A movement command can specify a position for the **tip of the vacuum gripper** relative to the **base of the robot**, rather than for the robot's bare mounting flange. The same reference frames must be used consistently when teaching and commanding positions.

**Check:** The program reports the result for each operation and finishes with `Robot setup complete.` **Read the individual results too:** the final printed message alone does not guarantee that every command succeeded. If setup fails, do not attempt a movement demo.

<!-- SCREENSHOT TODO: robot_setup command and successful individual results. -->

## Step 4 — See live position data

In Terminal 3, run:

```bash
ros2 run e6_lab_support pose_monitor
```

The tool shows the current Cartesian pose of the active **Tool 1** TCP:

- **X, Y, Z** — position in millimetres;
- **Rx, Ry, Rz** — orientation in degrees.

**Check:** The terminal displays the current pose. This information comes from a ROS 2 **topic** published by the driver. The monitor is a **subscriber**: it receives updated pose messages as the robot's state changes.

The tool can also toggle **drag mode** with **Enter**. Only try this with appropriate supervision and the robot's working area clear: drag mode releases the joints for guided hand movement, and the arm must be supported and moved carefully. Press Enter again to lock the joints. Avoid forcing the arm. Do not leave it in drag mode.

Press **Ctrl+C** to close the pose monitor.

**See the actual Python implementation:** [`pose_monitor.py` in e6_lab_support](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/pose_monitor.py). You'll create a much smaller pose-reading node yourself in [Exercise 4](04-reading-robot-position.md).

<!-- SCREENSHOT TODO: pose monitor output, with frame and position labels annotated. -->

## Step 5 — See how the vacuum gripper is controlled (optional demonstration)

With the robot configured and stationary, run:

```bash
ros2 run e6_lab_support hardware_test
```

This example turns on the vacuum output and reads the tool's vacuum-loss input. The output and input are separate: one **commands** the vacuum and the other **reports** its state.

The tool prompts you to press **Enter** to stop monitoring and switch the vacuum off. Follow the prompt and check that the vacuum turns off when finished.

**Code to explore:** [`hardware_test.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/hardware_test.py). Later, the [gripper guide](controlling-the-gripper.md) will show you how to use the same ROS 2 services in your own application.

<!-- SCREENSHOT TODO: hardware test showing vacuum input status. -->

## Step 6 — Observe robot movement (supervised demonstration)

**Only run this after `robot_setup` has completed successfully, with the robot's work area checked and teaching staff satisfied that the demo poses are safe for this station.**

```bash
ros2 run e6_lab_support movement_demo
```

This demonstration uses two commands:

- **MovJ:** a joint-interpolated move; the TCP's path is not necessarily a straight line.
- **MovL:** a linear Cartesian move; the TCP travels along a straight path.

The program waits for you to press Enter before starting. It moves between two positions that were taught and checked for the lab example. Observe the physical arm and the corresponding motion in RViz.

A useful detail: Dobot movement commands are **queued**. A ROS 2 service response can acknowledge a command before the robot has physically finished moving. This matters when you later build a sequence of movements or measure cycle times.

Choose **q**, then Enter, when prompted to stop repeating the demonstration.

**Code to explore:** [`movement_demo.py`](https://github.com/portsmouth-robotics/e6_lab_support/blob/main/e6_lab_support/movement_demo.py). See also [Controlling movement](controlling-movement.md).

<!-- SCREENSHOT TODO: movement demo terminal and RViz. -->

## What did you just run?

You have seen two sides of ROS 2 communication:

- **Topics** continuously send data, such as the robot's current pose. The pose monitor subscribes to one.
- **Services** accept requests and return responses, such as enabling the robot, reading an input or requesting a movement.

The Dobot driver connects these ROS 2 interfaces to the physical E6. The lab tools show how a Python program uses them. Your coursework will involve creating your own program that uses these interfaces to perform the required task.

## Finishing and next steps

Stop the demonstration tools cleanly, then stop RViz and the driver with **Ctrl+C** in their respective terminals when no longer needed. Leave the robot in a safe condition and follow staff instructions for powering down.

Next, read [3. Understanding your ROS 2 package](03-understanding-the-package.md), then [4. Create your own pose reader](04-reading-robot-position.md).

Remember to [save your changes to GitHub](git-and-vscode.md) and use the [before-leaving checklist](../IMPORTANT.md).
