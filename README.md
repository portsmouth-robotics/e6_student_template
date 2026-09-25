# DOBOT Magician E6 ROS 2 Student Template

This repository is a starting point for the ROS 2 section of the M34189 Decision Making and Robot Kinematics coursework.

It contains a minimal ROS 2 Python package for you to develop your own DOBOT Magician E6 application.

## Before you start

The lab PCs already contain:

- ROS 2 Humble
- the DOBOT E6 ROS 2 driver
- the `e6_lab_support` package
- the required network configuration for the robot

Your own work should be kept inside:

```text
~/dobot_ws/src/student_work/
```

Each group should have its own repository and ROS 2 package.

---

## 1. Create your group repository

On GitHub, open the template repository and choose Use this template → Create a new repository.

Give the repository a sensible group-specific name, for example:

```text
e6_group_08
```
### Invite your group members

Once the group repository has been created, invite the other member of your group so you can both push changes.

On GitHub:

1. Open your group repository.
2. Go to **Settings**.
3. Open **Collaborators** or **Collaborators and teams**.
4. Choose **Add people**.
5. Search for your group member's GitHub username or email address.
6. Send the invitation.

Your group member will need to accept the invitation before they can push changes to the repository.

Each student should sign in to GitHub using their own account. Do not share login details or use another student's GitHub session.

### Clone the repository to the PC

Use **VS Code** to clone your repository.

1. Open VS Code.
2. Select **Clone Git Repository**.
3. Sign in to GitHub when prompted.
4. Choose your group repository.
5. Clone it into:

```text
~/dobot_ws/src/student_work/
```

6. Open the cloned repository in VS Code.

Using VS Code for Git authentication and normal Git operations avoids having to manage GitHub credentials separately in the terminal.

---

## 2. Rename the ROS 2 package

The template initially uses the package name:

```text
e6_student_template
```

Each group must give its ROS 2 package a unique name.

Run:

```bash
./rename_package.sh e6_group_08
```

Replace `08` with your own group number.

The script updates the package name throughout the project.

You only need to run this once.

---

## 3. Build your package

From the ROS 2 workspace:

```bash
cd ~/dobot_ws
colcon build --packages-select e6_group_08
source install/setup.bash
```

Replace `e6_group_08` with your own package name.

You will need to source the workspace again in each new terminal:

```bash
source ~/dobot_ws/install/setup.bash
```

---

# Starting the DOBOT E6

The DOBOT driver must be running before you can communicate with the robot.

## Terminal 1 — Start the robot driver

```bash
ros2 launch dobot_bringup_v4 dobot_bringup_ros2.launch.py
```

The lab PCs are preconfigured with the DOBOT IP address and robot type in .bashrc, so no extra launch arguments are required.

Leave this terminal running.

---

## Terminal 2 — Start RViz

```bash
ros2 launch dobot_rviz dobot_rviz.launch.py live_hardware:=true
```

RViz provides a live visualisation of the E6.

When everything is working correctly, the robot model in RViz should follow the real robot as it moves.

Leave this terminal running.


---

## Terminal 3 — Configure the robot

Run:

```bash
ros2 run e6_lab_support robot_setup
```

This performs the standard lab setup:

- requests control of the robot;
- enables the robot;
- selects User 0, the robot base coordinate frame;
- configures Tool 1 as the vacuum gripper TCP;
- applies the 91 mm tool offset;
- sets the vacuum-tool payload.

After that, use this terminal for commands, your own ROS 2 nodes, or the lab support tools.

For example:
```bash
ros2 run e6_lab_support pose_monitor
```
or:
```bash
ros2 run e6_group_08 student_node
```

# Useful lab tools

The `e6_lab_support` package contains several utilities to help you work with the E6.

These are reference and diagnostic tools. You are expected to develop your own coursework application in your group package.

## Pose monitor

```bash
ros2 run e6_lab_support pose_monitor
```

The pose monitor shows the current position of the active tool centre point.

It displays:

- X, Y and Z position in millimetres;
- Rx, Ry and Rz orientation in degrees;
- the active User and Tool frames.

Press **Enter** to toggle drag mode.

When drag mode is enabled, the robot can be moved by hand. Press **Enter** again to lock the joints.

This is useful for teaching positions which can then be used in your own program.

### Coordinate frames

The standard lab setup uses:

```text
User 0 — robot base coordinate system
Tool 1 — vacuum gripper TCP
```

Cartesian coordinates are therefore interpreted as the position of the vacuum gripper TCP relative to the robot base frame.

---

## Hardware test

```bash
ros2 run e6_lab_support hardware_test
```

This provides a simple test of the vacuum system and tool digital input.

It can be useful when checking that the robot hardware and ROS connection are working correctly before debugging your own program.

---

## Movement demo

```bash
ros2 run e6_lab_support movement_demo
```

This demonstrates two common DOBOT movement commands:

- `MovJ` — joint-interpolated movement;
- `MovL` — linear Cartesian movement.

Read the source code for this example as well as running it. It contains additional comments explaining how the ROS 2 service calls are constructed.

---

# Your student node

The template includes:

```text
e6_student_template/student_node.py
```

After running the rename script, this directory will use your group package name instead.

The supplied node is intentionally minimal.

Run it using:

```bash
ros2 run e6_group_08 student_node
```

You should extend this node, or create additional nodes, to develop your coursework solution.

---

# Useful DOBOT ROS 2 services

The E6 ROS driver exposes robot commands as ROS 2 services.

Some services you are likely to encounter include:

```text
RequestControl
EnableRobot
MovJ
MovL
RelJointMovJ
ToolDOInstant
ToolDI
GetPose
GetAngle
StartDrag
StopDrag
```

You can view available services using:

```bash
ros2 service list
```

You can inspect the definition of a service using:

```bash
ros2 interface show dobot_msgs_v4/srv/MovJ
```

For example, the `MovJ` and `MovL` services contain a `mode` field.

In this driver:

```text
mode = true   -> a-f represent joint coordinates
mode = false  -> a-f represent Cartesian coordinates
```

For Cartesian movement:

```text
a = X
b = Y
c = Z
d = Rx
e = Ry
f = Rz
```

---

# ROS 2 commands you will use frequently

List nodes:

```bash
ros2 node list
```

List topics:

```bash
ros2 topic list
```

Inspect a topic:

```bash
ros2 topic echo <topic>
```

List services:

```bash
ros2 service list
```

Inspect a service definition:

```bash
ros2 interface show <interface>
```

Build your package:

```bash
cd ~/dobot_ws
colcon build --packages-select <your_package_name>
```

Source the workspace:

```bash
source ~/dobot_ws/install/setup.bash
```

---

# Git and VS Code

Use **VS Code** for normal Git operations during this coursework.

You do not normally need to use Git commands in the terminal.

## Signing in to GitHub

Use the GitHub sign-in option inside VS Code when prompted.

Make sure you are signed in to the correct GitHub account before making changes.

If you are using a shared lab PC, sign out of GitHub in VS Code at the end of your session.

## Saving your work

Use the **Source Control** panel in VS Code to:

1. Review the files you have changed.
2. Stage the changes you want to save.
3. Enter a short commit message describing what you changed.
4. Commit the changes.
5. Use **Sync Changes** or **Push** to send your commits to GitHub.

Commit your work regularly rather than waiting until the end of a lab session.

If another member of your group has made changes, use VS Code's Git controls to pull or sync before you start making new changes.

Do not share one person's logged-in GitHub session between groups.

---

# Useful documentation

## ROS 2 Humble

ROS 2 Humble documentation:

https://docs.ros.org/en/humble/

Useful sections include:

- Nodes
- Topics
- Services
- Python packages
- Launch files

## DOBOT ROS 2 driver

The lab uses the DOBOT six-axis ROS 2 V4 driver:

https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4

The repository contains the ROS service definitions used by the E6.

You can also inspect the installed interfaces directly using `ros2 interface show`.

---

# Important notes

- Always make sure the robot workspace is clear before commanding movement.
- Run `robot_setup` after starting the DOBOT driver.
- Cartesian positions in the standard lab configuration use User 0 and Tool 1.
- Do not assume that a ROS service returning successfully means the physical motion is safe.
- Keep movements small while testing new code.
- Use the pose monitor and drag mode to teach safe positions before using them in programs.

---

# Coursework responsibility

The supplied template and `e6_lab_support` tools are intended to help you access the robot and understand the ROS 2 interfaces.

You are responsible for developing and understanding your own coursework implementation, including your application logic, robot motion, and pick-and-place sequence.
