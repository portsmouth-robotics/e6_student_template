# 1. Getting started with your group repository

This guide takes you from signing in on a lab PC to running your group's first ROS 2 program.

**By the end, you should have:** your own group's repository open in VS Code, a successfully built ROS 2 package, and a running `student_node`.

[← Back to the guide index](../README.md) · [Next: Running the robot →](02-running-the-robot.md)

## Before you begin

You will need:

- A GitHub account with your **University of Portsmouth email address added and verified**.
- An invitation to your group's **private repository** under [portsmouth-robotics](https://github.com/portsmouth-robotics), accepted using that GitHub account.
- A lab PC started in **Ubuntu (Linux)**, not Windows.

If you already have a GitHub account, you can add and verify your university email address without creating another account. See [GitHub's instructions for adding an email address](https://docs.github.com/en/account-and-profile/how-tos/email-preferences/adding-an-email-address-to-your-github-account).

**You do not need to create a repository or rename the ROS 2 package.** Both have been prepared for your group. If you cannot access your assigned repository, contact the teaching staff rather than creating a new one.

> **Shared PC reminder:** Your work must be saved to GitHub before you leave. Files kept only on a lab PC may not be available next time. See [Before you leave the lab](../IMPORTANT.md).

## Step 1 — Open VS Code and sign in

1. Open **Visual Studio Code** on the Ubuntu desktop.
2. Open the **Accounts** menu (person icon in VS Code) and choose **Sign in with GitHub**.
3. Follow the prompts in your browser to authorise VS Code to use your GitHub account.
4. Return to VS Code when prompted.

If you've already signed in during this session, you can skip this step.

**Check:** VS Code should show that you are signed in to GitHub.

<!-- SCREENSHOT: Sign-in controls and browser authorisation. Use appropriate cropped/annotated images from the existing images/ sequence (approximately 01–04). -->

## Step 2 — Clone your assigned repository

*Cloning* means downloading a working copy of your group's files from GitHub onto the lab PC. Your GitHub repository remains the shared online copy.

1. In VS Code, open the **Source Control** panel (branch icon in the left-hand sidebar).
2. Choose **Clone Repository** or **Clone Git Repository**.
3. Select **Clone from GitHub** if prompted.
4. Find and select **your assigned group repository** under `portsmouth-robotics`. Make sure the group number is correct.

If the repository does not appear, check that you accepted its invitation and signed in with the correct GitHub account. You can also open your assigned repository on github.com, copy its HTTPS URL, and paste that URL into VS Code's cloning prompt.

<!-- SCREENSHOT: Clone Repository, GitHub repository selector, and choosing the correct group repository. -->

## Step 3 — Choose the right folder

VS Code will ask where to put the cloned repository.

Navigate to:

```text
~/dobot_ws/src/student_work/
```

Select **this folder as the destination**. VS Code creates a new subfolder for your repository inside it.

For example, if your repository is called `e6_group_08`, you should end up with:

```text
~/dobot_ws/src/student_work/e6_group_08/
```

**Do not** select `~/dobot_ws` itself as the clone destination, or create a second `student_work` folder inside the first.

<!-- SCREENSHOT: Folder chooser showing the student_work directory. -->

## Step 4 — Open the project

1. When VS Code asks whether to open the cloned repository, choose **Open**.
2. If a **Do you trust the authors of the files in this folder?** prompt appears, verify you're opening your assigned repository, then choose **Yes, I trust the authors**.
3. In the **Explorer** panel, look for `README.md`, `setup.py`, `package.xml`, and the Python source folder named for your group.

These files form a **ROS 2 Python package**. We'll explain how they fit together in [Understanding your package](03-understanding-the-package.md).

**Check:** You can see the project files in the VS Code Explorer.

<!-- SCREENSHOT: Trust prompt and Explorer showing the opened project. -->

## Step 5 — Open a terminal

A *terminal* is where you type commands to run software in Linux.

In VS Code, select **Terminal → New Terminal** from the top menu.

You can check which directory the terminal is currently using by typing:

```bash
pwd
```

You'll use the terminal to build the ROS 2 package and run your programs.

<!-- SCREENSHOT: VS Code Terminal menu and integrated terminal. -->

## Step 6 — Build your ROS 2 package

A *build* prepares your package so ROS 2 can find and run its programs.

First, find the package name in the `name` field of `package.xml`. It should already be set to your group-specific name.

From the terminal, move to the ROS 2 workspace:

```bash
cd ~/dobot_ws
```

Then build the package, replacing `e6_group_08` below with the **actual package name shown in your `package.xml`**:

```bash
colcon build --packages-select e6_group_08
```

Wait for the build to finish. Look for a summary showing that the package completed successfully.

Next, tell the current terminal about the newly built package:

```bash
source ~/dobot_ws/install/setup.bash
```

This command is called *sourcing the workspace*. It makes ROS 2 aware of the packages you've built. You normally need to source the workspace in each new terminal before running your own nodes.

**Check:** The build finishes without errors.

<!-- SCREENSHOT: Successful colcon build and source command, if a clear screenshot is available. -->

## Step 7 — Run the starter program

The repository contains a minimal program called `student_node`. It doesn't move the robot; it simply starts a ROS 2 node and prints a message.

Run it, replacing the example package name with your own:

```bash
ros2 run e6_group_08 student_node
```

You should see a message similar to:

```text
[INFO] [...] [e6_student_node]: E6 student node started.
```

The program will keep running until you stop it. Press **Ctrl+C** in the terminal to finish.

If ROS 2 says it cannot find the package or executable, check that the build succeeded, the package name is correct, and you've sourced `install/setup.bash`.

**You have now run a Python ROS 2 node from your group's repository.**

<!-- SCREENSHOT: student_node running in the terminal. -->

## What next?

Continue with [2. Running the robot](02-running-the-robot.md), where you'll start the Dobot driver, view the robot in RViz, and try the installed lab support tools.

For a deeper explanation of the source files and how to add your own programs, see [3. Understanding your ROS 2 package](03-understanding-the-package.md).

**Before leaving the lab:** Complete the [Git and VS Code setup and saving guide](git-and-vscode.md), including setting your Git commit name and email address, then [follow the save-and-sign-out checklist](../IMPORTANT.md). Your Linux profile may be cleared between sessions, so do not rely on Git settings or files being retained locally. Any changes you've made must be committed and pushed to GitHub.
