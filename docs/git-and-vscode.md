# Git and VS Code: working together and saving your work

Your group has **one private GitHub repository shared between two students**. Git lets both of you work on the same project and keep a record of changes.

**Most important rule: commit and push your work before leaving the lab.** The lab PCs are shared and your local files or login settings may not survive until your next session.

[← Back to the documentation index](../README.md) · [Getting started](01-getting-started.md) · [Before leaving the lab](../IMPORTANT.md)

## The five words you need

| Term | What it means |
| --- | --- |
| **Clone** | Download a working copy of your GitHub repository to a lab PC |
| **Pull** | Bring your teammate's latest changes **from GitHub** onto your PC |
| **Commit** | Save a named snapshot of your changes **locally**, with a short message |
| **Push** | Send your local commits **to GitHub**, where your teammate can access them |
| **Sync Changes** | VS Code's shortcut for exchanging changes with GitHub; it may pull and push |

**A commit is not the same as a push.** If your latest commit only exists on the lab PC, it is not yet safely stored in the shared online repository.

## Before your first lab session: GitHub access

You should have:

1. A GitHub account with your **University of Portsmouth email address added and verified**. You can keep your existing personal GitHub account.
2. Accepted the invitation to your group's **private repository** in the `portsmouth-robotics` organisation.
3. Checked that you can open the assigned repository at [github.com/portsmouth-robotics](https://github.com/portsmouth-robotics).

Your repository and ROS 2 package are **already created and named for your group**. You do not need to create a repository, add your teammate, or rename any package.

If you cannot access your repository, tell the teaching staff rather than making a different repository.

## Step 1 — Sign in to VS Code

On the Ubuntu lab PC:

1. Open **VS Code**.
2. Select the **Accounts** icon (person symbol) and choose **Sign in with GitHub**.
3. Complete the browser authorisation prompts using the account with access to your group repository.
4. Open your cloned group repository, or [clone it using the Getting Started guide](01-getting-started.md) if this is a new PC or session.

**Check:** the Source Control view shows your group's repository. Make sure you're working in the right group's files.

<!-- SCREENSHOT TODO: Accounts menu, sign-in, and VS Code Source Control overview. -->

## Step 2 — Tell Git your name and email

Before your first commit **on each lab PC or new Linux profile**, configure the author name and email address Git will record.

Open **Terminal → New Terminal** in VS Code and enter the following using **your own details**:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.name@myport.ac.uk"
```

Use the university email address you have **verified on your GitHub account**. The email does not need to be your primary GitHub address.

Check the settings:

```bash
git config --global --get user.name
git config --global --get user.email
```

**These are not GitHub login credentials.** They identify the author of each commit; they do not sign you in, and you must not put passwords or access tokens into these commands.

Because Git's global settings belong to the current Linux user profile, **if both teammates use the same Linux login, check and change these settings before each person's commits.** Otherwise, changes could be credited to the wrong person.

<!-- SCREENSHOT TODO: Integrated terminal showing Git config commands and verification. -->

## A normal lab session: pull → work → commit → push

Use this routine each time you work on the group project.

### Step 3 — Pull before you start

Your teammate may have made changes since you last worked.

1. Open the correct group repository in VS Code.
2. Go to **Source Control** (branch icon in the sidebar).
3. Use the **…** menu and choose **Pull** (usually under **Pull, Push**).
4. Wait for it to finish, then check any changed files.

If this is your first time on a PC and you haven't cloned the repository, clone it first. A fresh clone already contains the latest committed files from GitHub, so a separate pull is usually unnecessary.

**If Git says there are local changes that prevent pulling:** stop and check those changes. Do not discard them simply to make the error go away.

<!-- SCREENSHOT TODO: Source Control menu showing Pull. -->

### Step 4 — Edit your code

Make changes in the inner Python source folder of your group repository, not in the workspace `build/` or `install/` directories.

**Save your files regularly** with **Ctrl+S**. You can see changed files in the Source Control panel.

While working in pairs:

- Decide who's working on which file or feature.
- Let each other know before editing the **same file** on separate PCs.
- Keep changes reasonably small and push them regularly; don't wait until the entire project is finished.
- If one student has pushed changes, the other should pull before continuing with work that depends on them.

**Git doesn't merge your work live like a shared document editor.** It exchanges saved commits, and two people editing the same lines can cause conflicts.

### Step 5 — Review and stage your changes

1. Open **Source Control** in VS Code.
2. Review the changed files listed under **Changes**. Click a file to see what changed.
3. Stage the files you want in this commit using the **+** beside a file (or **Stage All Changes** if everything belongs together).
4. Check the staged list before committing.

You should commit your Python source files and package configuration changes, such as `setup.py`, when they are part of your work.

**Do not commit:** passwords, tokens, private credentials, or unrelated files. Ask for help if you're unsure whether a newly generated file belongs in the repository.

<!-- SCREENSHOT TODO: Source Control changes/diff and staging controls. -->

### Step 6 — Commit your work

1. Type a **short commit message** into the Source Control message box, describing what changed.
2. Select **Commit**.
3. Check that the commit finishes successfully.

Good commit messages describe the work:

```text
Add pose subscriber
Display orientation in read_pose
Fix vacuum status parsing
```

Less helpful:

```text
stuff
changes
done
```

A commit is a **local snapshot**. If you stop here, your teammate still won't receive it from GitHub.

<!-- SCREENSHOT TODO: Commit message and Commit button. -->

### Step 7 — Push to GitHub

1. In Source Control, choose **Push** from the **…** menu, or use the visible **Sync Changes** button.
2. If VS Code asks you to authorise GitHub, follow the prompts.
3. Wait until the operation finishes and any pending outgoing changes disappear.
4. Open your **group repository on github.com** in the browser.
5. Check that your latest commit appears on GitHub and the changed files are visible.

**This last check matters:** it confirms you have actually saved your work somewhere you can access from another lab PC.

<!-- SCREENSHOT TODO: Push/Sync Changes and corresponding commit on GitHub. -->

## At the next session, or on another lab PC

The Linux user profile may be reset, and your local clone might not exist.

If the repository folder is missing, **clone the same group repository again** into `~/dobot_ws/src/student_work/` using [Getting Started](01-getting-started.md). Do **not** create a new repository.

If your local clone is still there, open it and **pull** before starting new work. Recheck your Git author identity before your next commit.

For ROS 2, remember that files downloaded from GitHub are **source files**. If you have cloned a new copy or pulled Python/package changes, rebuild your group package and source the workspace before running it:

```bash
cd ~/dobot_ws
colcon build --packages-select YOUR_PACKAGE_NAME
source ~/dobot_ws/install/setup.bash
```

Replace `YOUR_PACKAGE_NAME` with the actual name in your group's `package.xml`.

## Two students working on the same repository

**Simple approach for this coursework:** both students work in the group's repository using the default branch, coordinating their edits and committing/pushing their own work.

An example:

1. Student A pulls, edits `read_pose.py`, commits and pushes.
2. Student B pulls, sees the new `read_pose.py`, then adds another improvement.
3. Student B commits and pushes.
4. Student A pulls to receive Student B's changes.

This works well when you **communicate and avoid editing the same lines at the same time**.

If both students use the same local login on a lab machine, Git's name and email will not automatically follow the person typing. Check `git config --global user.name` and `user.email` before committing.

## Common problems

### “Please tell me who you are”

Git doesn't know the author name/email for your commit.

Run the `git config --global user.name` and `git config --global user.email` commands from Step 2, then try committing again.

### “Authentication failed” / “Permission denied”

Check you're signed in to **the right GitHub account**, and that you've accepted the repository invitation. Git author name/email and GitHub authentication are separate things.

Don't paste your GitHub password or a token into the repository or terminal history to try to fix a sign-in problem. Ask staff if the authorisation prompts do not work.

### “Push rejected” / “Updates were rejected”

GitHub may have newer commits from your teammate, so it won't accept your push unchanged.

**Don't force-push.** Instead:

1. Keep your local work safe—commit it if it is ready.
2. Use **Pull** to integrate the newer remote commits.
3. If Git reports a conflict, follow the section below.
4. After resolving any issues, **Push** again.

If VS Code reports **divergent branches** or asks you to choose a merge/rebase strategy, **stop and ask teaching staff for help** rather than experimenting with destructive commands.

### “Merge conflict”

This happens when Git can't automatically combine changes, often because both students edited the same lines.

In VS Code, the conflicting file may be marked and you may see options to keep the **current**, **incoming**, or **both** versions.

- Read both versions and discuss with your teammate what the correct final file should contain.
- Don't automatically choose “accept all” or delete conflict markers without understanding them.
- Check the resulting Python code and run your tests.
- Then complete the merge/commit process and push.

**Don't use `git push --force` or `git reset --hard` to make a conflict disappear.** Those can overwrite or discard work. Get help if you're unsure.

### “Nothing to commit” but your changes seem missing

Make sure you saved the file (**Ctrl+S**) and opened the correct repository. Also check whether you've only changed a file outside the cloned repository.

### VS Code says “Publish Branch”

If you're on a new branch rather than the group's normal default branch, ask staff to check before publishing or switching. You shouldn't need to create extra branches for the basic coursework workflow.

## Before you leave the lab

1. Save **all** files.
2. Review, stage and **commit** changes using your own Git author identity.
3. **Push** to GitHub.
4. Open GitHub and verify your latest commit is online.
5. Stop your ROS 2 programs safely.
6. **Sign out of GitHub in VS Code and the browser**, and sign out of any other accounts used on the shared PC.

Use the full [end-of-session checklist](../IMPORTANT.md).

**Remember:** **Saved in VS Code ≠ committed locally ≠ pushed to GitHub.** Your work is protected from a lab-PC profile reset only once it is on GitHub.

<!-- SCREENSHOT TODO: Add annotated sign-in, Source Control, Pull, Stage, Commit, Push, verification and conflict screenshots after text review. -->
