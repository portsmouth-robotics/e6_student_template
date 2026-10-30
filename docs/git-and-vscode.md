# Git and VS Code: saving your work

> **This guide is being expanded.** The essential setup and end-of-session steps are below.

[← Back to the guide index](../README.md)

## Sign in to GitHub

Sign in to GitHub through VS Code's **Accounts** menu using the account that has access to your assigned private repository. This allows VS Code to clone, pull and push.

## Set your Git commit identity

Git needs a name and email address to record who made each commit. **These settings are not your GitHub login details.**

Open a terminal in VS Code and run the commands below, using **your own name** and **your verified university email address**:

```bash
git config --global user.name "Your Name"
git config --global user.email "your.name@myport.ac.uk"
```

Check them with:

```bash
git config --global --get user.name
git config --global --get user.email
```

Because student profiles on the lab PCs may be cleared between sessions, you may need to do this again next time.

## Save your work to GitHub

1. Save all edited files in VS Code.
2. Open the **Source Control** panel.
3. Review the changes; stage the files you intend to save.
4. Enter a short, meaningful commit message and **Commit**.
5. Choose **Push** or **Sync Changes** to send the commit to GitHub.
6. Open your repository on GitHub and confirm the latest commit appears.

Before starting a new work session, **Pull** changes made by your teammate so you're working from the latest shared version. Ask for help if Git reports a conflict rather than overwriting somebody else's work.

**A local commit is not a backup:** your work is only available to teammates and recoverable from another PC once you push it to GitHub.

## Before leaving the lab

Use the [end-of-session checklist](../IMPORTANT.md), including signing out of GitHub and other accounts on the shared PC.

<!-- TODO: Add screenshot-led steps for VS Code Source Control and common Git errors. -->
