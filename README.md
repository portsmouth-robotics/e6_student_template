# DOBOT Magician E6 — ROS 2 Student Workspace

Welcome to your group's ROS 2 workspace for **M34189 Decision Making and Robot Kinematics**.

Your group has been given a GitHub repository containing a starter Python ROS 2 package. You will use it to develop and test **your own** application for controlling the DOBOT Magician E6. The ROS 2 work is one part of the coursework, which also involves Blockly and Python implementations.

**Your repository and ROS 2 package have already been created and named for your group.** You do not need to create a repository or rename the package yourself.

> **New to Linux, GitHub or ROS 2?** That's fine. Follow the getting-started guides in order. They are designed for the lab PCs and introduce concepts through practical examples on the robot.

## Start here: four steps

| Step | Guide | What you'll accomplish |
| --- | --- | --- |
| 1 | [Get started with your group repository](docs/01-getting-started.md) | Sign in, clone your assigned repository, and open it in VS Code. |
| 2 | [Run and connect to the robot](docs/02-running-the-robot.md) | Start the Dobot driver, RViz, and lab support tools; check that the system is working. |
| 3 | [Understand your ROS 2 package](docs/03-understanding-the-package.md) | See where the Python files live and how ROS 2 finds your programs. |
| 4 | [Exercise: read the robot's position](docs/04-reading-robot-position.md) | Create and run a small Python ROS 2 node that displays data from the E6. |

The guides include practical exercises and reference material. The troubleshooting guide and screenshot annotations are still being developed.

## Practical reference guides

Use these when you need to understand a particular piece of your program.

- [ROS 2 concepts in this lab](docs/ros2-concepts.md) — nodes, topics, messages, services, and clients, explained through the E6.
- [Using ROS 2 services](docs/using-services.md) — discover commands, inspect their request types, and call them from Python.
- [Using ROS 2 topics](docs/using-topics.md) — read live robot data using subscribers and callbacks.
- [Controlling robot movement](docs/controlling-movement.md) — `MovJ`, `MovL`, coordinate frames, and taught positions.
- [Controlling the vacuum gripper](docs/controlling-the-gripper.md) — digital outputs and the vacuum-loss input.

## Working safely and saving your work

- [Git and VS Code workflow](docs/git-and-vscode.md) — working together, committing, pushing, and pulling changes.
- **[Before you leave the lab](IMPORTANT.md)** — checklist to make sure your work is saved to GitHub.
- [Troubleshooting](docs/troubleshooting.md) — common setup and connection problems.

**Important:** The lab PCs are shared machines. Do not assume files left only on a lab PC will be available at your next session. Commit and push your work, and verify it appears on GitHub before leaving.

Before moving the robot, check that its workspace is clear and that the proposed movement is safe. Use small, controlled movements when testing new code.

## What's provided in the lab

The lab PCs are configured with ROS 2 Humble, the Dobot E6 ROS 2 driver, the `e6_lab_support` package, and the required robot network settings.

The installed `e6_lab_support` tools include:

| Tool | Purpose |
| --- | --- |
| `robot_setup` | Request control, enable the robot, and configure the reference and tool frames. |
| `pose_monitor` | Display the live tool position; toggle drag mode. |
| `hardware_test` | Test the vacuum system and digital input. |
| `movement_demo` | Demonstrate `MovJ` and `MovL`. |

You can [read the lab support source code](https://github.com/portsmouth-robotics/e6_lab_support) to see how these tools use ROS 2. They are references, not a finished coursework submission.

## Further documentation

- [ROS 2 Humble documentation](https://docs.ros.org/en/humble/)
- [ROS 2 Python client library (`rclpy`)](https://docs.ros.org/en/humble/p/rclpy/)
- [University of Portsmouth's DOBOT ROS 2 driver](https://github.com/portsmouth-robotics/DOBOT_6Axis_ROS2_V4)
- **M34189 coursework brief and DOBOT manual:** see Moodle for the authoritative module documents.

## Your coursework

Your group is responsible for developing, understanding, testing and evaluating its own pick-and-place implementation. The coursework includes comparing Blockly, Python and ROS 2 approaches using cycle time, positioning accuracy and task success rate. Refer to the **coursework brief on Moodle** for the complete requirements, assessment criteria, and submission instructions.
