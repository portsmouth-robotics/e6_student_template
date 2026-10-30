# Troubleshooting the E6 ROS 2 lab

**Something not working?** Find the symptom below and try the checks in order. Most problems are caused by opening the wrong folder, using the wrong package name, forgetting to source the workspace, or starting the ROS 2 programs in the wrong order.

[← Documentation index](../README.md) · [Getting started](01-getting-started.md) · [Running the robot](02-running-the-robot.md)

> **Safety:** If the robot moves unexpectedly, reports a safety fault, or there is any possibility of a collision, stop the activity and alert teaching staff. Do not clear safety faults, change controller settings, disable protective functions, or try random movement commands to diagnose a problem.

## Start here: four quick checks

1. **Are you in Ubuntu?** The ROS 2 coursework environment is installed on the Ubuntu side of the lab PCs.
2. **Is the correct group repository open in VS Code?** Look for your group's `package.xml` and `setup.py`.
3. **Are you using the correct package name?** Check `package.xml`; replace any example such as `e6_group_08` in the guides with your own name.
4. **Which programs are running?** The Dobot **driver** must run for live robot topics and services to exist. RViz is a separate program, and `robot_setup` is run after the driver connects.

If those look right, find your symptom below.

## GitHub and VS Code problems

### I cannot see my group's private repository

- Open [github.com](https://github.com) and check that you're signed in with the GitHub account invited by staff.
- Make sure you **accepted the repository invitation**, not just received the email.
- Check that your university email address was added and verified on the invited GitHub account.
- Confirm the repository name or group number with teaching staff.
- If the repo is visible on GitHub but not in VS Code's clone list, copy the repository's **HTTPS URL** from GitHub and paste it into **Clone Repository** in VS Code.

**Do not create a replacement repository.** Contact staff if the invitation is missing or the permissions are wrong.

### VS Code cannot find GitHub / sign-in keeps failing

Check your browser is using the correct GitHub account and complete the authorisation prompts. Then return to VS Code. Sign-in and your Git **author name/email** are different settings; configuring `git user.email` does not sign you into GitHub.

If authentication repeatedly fails, ask staff rather than entering passwords or access tokens into files or untrusted prompts.

### Git says “Please tell me who you are”

Your commit identity is not configured in the current Linux profile. In the integrated terminal, use **your own** name and verified university email:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.name@myport.ac.uk"
```

If the other group member used the same Linux account, check these settings before each person's commits.

### I committed but my teammate cannot see my changes

A **commit** saves changes locally. You must also **Push** or **Sync Changes** in VS Code. Open the repository on GitHub and check the commit appears there. Your teammate then needs to **Pull** those changes.

### Git rejected my push / there is a merge conflict

Your teammate may have pushed newer changes. Don't force-push or reset the repository.

1. Save and commit your local work if it is ready.
2. Try **Pull** to bring in remote changes.
3. If a conflict appears, compare both versions and agree with your teammate how to combine them.
4. Ask teaching staff for help with divergent branches, merge/rebase prompts or confusing conflict markers.

See [Git and VS Code](git-and-vscode.md) for the full process.

### The repository has disappeared since last week

Lab PC profiles may be cleared between sessions. Check GitHub for your most recent **pushed** commit, then clone the **same group repository** again into:

```text
~/dobot_ws/src/student_work/
```

Follow [Getting started](01-getting-started.md). Do not create another GitHub repository.

## ROS 2 package and build problems

### `ros2: command not found`

You may be in Windows rather than Ubuntu, or ROS 2 is not loaded in the current shell.

On an Ubuntu lab PC, try:

```bash
source /opt/ros/humble/setup.bash
ros2 --help
```

If `/opt/ros/humble/setup.bash` does not exist, or `ros2` is still unavailable, tell staff. Don't attempt to reinstall ROS 2 on the managed PC.

### `colcon: command not found`

`colcon` is required to build ROS 2 packages. It should already be installed on the Ubuntu lab image. Ask teaching staff if it is missing rather than installing packages yourself.

### “Package not found” when using `ros2 run`

First check the name in your own `package.xml`. Then build **from the workspace**, not from inside the cloned repository:

```bash
cd ~/dobot_ws
colcon build --packages-select YOUR_PACKAGE_NAME
source ~/dobot_ws/install/setup.bash
```

Replace `YOUR_PACKAGE_NAME` with the real package name.

Run:

```bash
ros2 pkg list | grep YOUR_PACKAGE_NAME
ros2 pkg executables YOUR_PACKAGE_NAME
```

If the package still isn't found, verify that your group's cloned directory is **inside** `~/dobot_ws/src/student_work/` and that the build succeeded. Don't substitute the GitHub repository name for the package name unless they're actually the same.

### “No executable found” for my new Python program

Check all of the following:

- Your `.py` file is in the **inner Python source directory**, alongside `student_node.py`.
- The program defines a `main()` function.
- `setup.py` has a correctly spelled entry in `console_scripts`.
- You've **saved** the edited files, rebuilt the package and sourced the workspace.
- You're using the executable name on the **left** of the entry point, not necessarily the Python filename.

For example, this entry:

```python
'read_pose = YOUR_PACKAGE_NAME.read_pose:main',
```

makes `ros2 run YOUR_PACKAGE_NAME read_pose` available after rebuilding. Use the actual Python package name in `setup.py`; don't paste `YOUR_PACKAGE_NAME` literally.

See [Understanding your package](03-understanding-the-package.md).

### Build failed with a Python syntax or indentation error

Open the named file and look at the **first meaningful error** in the terminal. Common causes include:

- missing colon after `class`, `def`, `if`, or `else`;
- incorrect indentation (Python uses indentation to group code);
- missing commas or quotation marks in `setup.py`;
- misspelled imports or class names.

Save the file, try the build again, and read the error location carefully. If an error references an old file version, make sure you saved the file **before** building.

### My program runs, but changes I made aren't appearing

You may be running a previously built version of the package.

1. Save all files in VS Code.
2. Rebuild your package with `colcon build --packages-select YOUR_PACKAGE_NAME`.
3. Run `source ~/dobot_ws/install/setup.bash` **in the terminal where you will run the program**.
4. Restart the program.

New terminals don't automatically inherit a previous terminal's sourcing.

## Dobot driver and network problems

### Driver cannot connect to the E6

First check that:

1. You're using the **Ubuntu lab PC assigned to that robot**, not a different station.
2. The robot has power and its controller has started.
3. The robot-to-PC Ethernet cable is connected.
4. You're using the lab's normal launch command:

```bash
ros2 launch dobot_bringup_v4 dobot_bringup_ros2.launch.py
```

The robot network is preconfigured on the lab image. **Do not change IP addresses or unplug other lab-network connections without staff approval.**

If staff ask you to collect diagnostic information, these are read-only checks:

```bash
ip -br addr
ip route get 192.168.5.1
ping -c 3 192.168.5.1
```

The E6 uses `192.168.5.1` in the standard lab setup. The `ip route get` output should point through the robot's Ethernet connection, **not** the university network/default gateway. If it routes through the university network, or ping cannot reach the robot, show staff the output.

**Do not guess an interface name or alter network routing yourself.** Robot Ethernet interfaces can have different device names on different lab PCs.

### `ros2 service list` does not show the Dobot services

The Dobot **driver** must be running and properly connected before it can offer its robot-control services.

- Check the driver terminal for errors.
- Run `ros2 node list` and `ros2 service list` from another Ubuntu terminal.
- If ROS 2 itself works but the Dobot services are missing, the problem is likely with the driver or its ROS 2 environment rather than your Python code.

Ask staff if it doesn't recover after starting the correct driver.

### `ros2 topic echo` shows nothing

Check the driver and try:

```bash
ros2 topic list
ros2 topic type /dobot_msgs_v4/msg/ToolVectorActual
ros2 topic echo /dobot_msgs_v4/msg/ToolVectorActual
```

If the topic isn't present, the driver may not be running or connected. If it exists but no messages arrive, report the symptom and driver terminal output to staff.

See [Using topics](using-topics.md).

### The service request never completes

Check the service name, type, and request fields using:

```bash
ros2 service list
ros2 service type /dobot_bringup_ros2/srv/GetPose
ros2 interface show dobot_msgs_v4/srv/GetPose
```

For Python, make sure your node is processing callbacks and that you're using an appropriate asynchronous service-call pattern. A blocking wait inside a callback of an already-spinning node can prevent completion.

See [Using services](using-services.md). If a robot-control service continues to fail, stop testing it and report the error.

## RViz and robot behaviour

### RViz doesn't open / robot model is missing

Start the driver first, then open RViz in **another terminal**:

```bash
ros2 launch dobot_rviz dobot_rviz.launch.py live_hardware:=true
```

Read both terminals for errors. RViz visualises ROS 2 data; it does **not** establish the connection to the physical robot on its own.

If the RViz model appears but doesn't update, check that the driver is running and publishing live state. Don't try to fix a display problem by commanding robot motion.

### `robot_setup` reports an error

`robot_setup` requests control, enables the robot and configures its User 0 and Tool 1 frames. It runs after the driver is connected:

```bash
ros2 run e6_lab_support robot_setup
```

**Read the result of each operation**, not just the final “setup complete” line. If any step fails, do not run movement demonstrations. Show teaching staff the output so they can diagnose the cause.

### The robot doesn't move when I call `MovJ` or `MovL`

A ROS 2 service response does **not** prove that a movement has completed, or even that it was accepted successfully.

- Check the returned result/error information.
- Confirm that `robot_setup` succeeded and the robot is ready.
- Make sure a suitable user frame, tool frame and **staff-approved target** were used.
- Don't repeatedly resend a failed movement request or change coordinates at random.

Ask for assistance if the robot does not respond as expected.

### The robot moved, but the path was not what I expected

`MovJ` uses **joint-interpolated** motion: the TCP may not travel in a straight line. `MovL` requests a **straight Cartesian path** for the TCP.

**Stop and review the planned motion before trying again**, especially if there was a near miss. Check the target pose, tool frame, user frame and clearance. See [Controlling movement](controlling-movement.md).

### Vacuum is on but the cube isn't held / DI2 shows an unexpected state

On the lab's vacuum setup:

- `ToolDOInstant` with **index 1** commands the vacuum output.
- `ToolDI` with **index 2** reads the vacuum-loss input.
- In the hardware test, DI2 is interpreted as **0** when vacuum-loss is not asserted and **1** when vacuum-loss is asserted.

Turning on DO1 is **not proof of a successful pickup**. DI2 is also not a complete object-presence sensor.

Test with the robot stationary and the work area clear:

```bash
ros2 run e6_lab_support hardware_test
```

Follow the tool's prompts to turn vacuum off. If the test is interrupted, **verify that the vacuum output is actually off**. Don't command motion with an uncertain grip or attempt to catch a falling object.

See [Controlling the gripper](controlling-the-gripper.md).

### The robot is in drag mode or has a safety fault

**Stop and ask teaching staff.** Do not force the arm or try to override a safety state. If drag mode was deliberately enabled, follow the supervised procedure for safely supporting and locking the arm before leaving it.

## When asking for help: bring useful evidence

You don't need to diagnose the whole problem. It helps staff if you can answer:

1. **Which step were you following?** Include the guide and step number.
2. **What command did you run?** Copy the exact line.
3. **What happened instead?** Include the **first relevant error** and a few lines around it (or a screenshot).
4. **What still works?** For example: “RViz opens, but no pose messages arrive.”
5. **Which lab station and group repository?**

**Never share passwords, access tokens or other private credentials** when copying terminal output.

## Useful links

- [Getting started](01-getting-started.md)
- [Running the robot](02-running-the-robot.md)
- [Understanding your package](03-understanding-the-package.md)
- [Reading the robot's position](04-reading-robot-position.md)
- [Git and VS Code](git-and-vscode.md)
- [Services](using-services.md) · [Topics](using-topics.md) · [Movement](controlling-movement.md) · [Vacuum gripper](controlling-the-gripper.md)

**Before leaving:** [Commit and push your code](git-and-vscode.md) and check the [end-of-session checklist](../IMPORTANT.md).
