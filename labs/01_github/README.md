# GitHub Lab: Fork & Clone a Repository

## Goal

By the end of this lab, you will:

1. Set up SSH keys for GitHub  
2. Fork an existing GitHub repo using the GitHub UI  
3. Clone your fork locally using Git and SSH  
4. Make and push commits to your fork  
> Note: Ensure you are logged into your [GitHub account](https://github.com/login) for this lab

---

## Modue 00: Ensure git is installed locally and configured

```bash
# Ensure Git is Installed
git --version

# If not...
brew install git

# If you had to install this for the first time, then you need to do this next step: Replace "you@example.com" and "Your Name" with your actual email and name (doesn't have to be a real email)
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Verify the values are 
git config --get user.email
git config --get user.name

# Prepare Your Workspace
mkdir -p ~/chainguard-app-building
cd ~/chainguard-app-building

```

If you see the email and user name you entered, you are done with this module

#### Module complete


## Module 1: Set up local SSH keys for integrating Git with GitHub

```bash
# If you don’t have an SSH key yet:
ssh-keygen
# Step through the questions it asks

# Check out the files it created:
ls -l ~/.ssh

# Get the public key contents:
cat ~/.ssh/id_rsa.pub
# or your ssh key file might be named like this:
cat ~/.ssh/id_ed25519.pub
# Copy the entire contents

```

---

Paste the key contents to your GitHub account:

- Go to [GitHub SSH Keys Settings](https://github.com/settings/keys)

- Click **“New SSH key”**, a new form will appear with a field for pasting in your key

- Paste the key, name it something like `app-bldg`, and add an expiration

![image](ssh_key2.png?)

Test the connection:

```bash
ssh -T git@github.com
```

If successful, you’ll see:

"Hi <your-username>! You've successfully authenticated..."

#### Module complete

---

## Module 2: Fork a Repository via GitHub UI

1. Visit this repo: [https://github.com/Sayre-Tnunu/app-building-for-chainguard-csms](https://github.com/Sayre-Tnunu/app-building-for-chainguard-csms)
2. Click the **Fork** button (top-right of the page)
3. Choose your personal account as the destination

Once the fork completes, you will be taken to **your own copy** of the repo (e.g. `yourusername/app-building-for-chainguard-csms`)


#### Module complete

---

## Module 3: Clone Your Fork via SSH

Return to your fork’s page, click the green **“Code”** button, select **SSH**, and copy the link (e.g. `git@github.com:yourusername/app-building-for-chainguard-csms.git`)

Then:

```bash
cd ~/chainguard-app-building

# Clone your copy of the repo to your local environment
git clone git@github.com:yourusername/app-building-for-chainguard-csms.git

# Verify a new subirectory is now visible:
ls -l

# Result should look like this:
# drwxr-xr-x  7 anthony.sayre  staff  224 Aug  3 12:45 app-building-for-chainguard-csms

# Navigate to the newly cloned directory (folder)
cd app-building-for-chainguard-csms

# What subfolders and files are inside the app-building-for-chainguard-csms folder?
ls 

# Now check out the hidden folder!
ls -a

# See what's inside the hidden folder
ls .git

```

#### Module complete

---

## Module 4: Make and push commits to your fork 

Set your Git identity:


```bash
# Create a file
echo "hello from my fork $MACGUFFIN" > demofile

# Review the file
cat demofile

# Check to see if the git program noticed the new file
git status
# the new file should display in red

# Tell git to start tracking the new file
git add demofile

# Check status again
git status
# The new file should now disoplay in green (git is now tracking the file)

# Commit (make a local back up of your changes)
git commit -m "add demofile $MACGUFFIN"

# Push! (send the new local commit of your repo to your remote repo in GitHub!)
git push
```

Check your fork on GitHub—you should see the file appear. Open your browser to this address

```http
https://github.com/yourusername/app-building-for-chainguard-csms
```

> [NOTE]: You can actually open the web address for your remote repo from the command line. 

> Make sure you are in your local copy of the repo:

> ```bash
> cd ~/chainguard-app-building/app-building-for-chainguard-csms
>```

> Enter this command in the terminal:

> ```bash
> # Use open command + git command + pipe + sed to open the web browser with command line:
> open "$(git remote get-url origin | sed -E 's#^git@([^:]+):#https://\1/#; s#\.git$##')"
> ```


Should look similar to this:

![image](verifynewfile.png?)


End of module when you have verified your new file is added to the remote repo

#### Module complete

---


<details>
<summary><strong>Extra Credit: Merge your changed fork back to the instructor's version of the repo</strong></summary>

Ensure you are in your development environment (the clone of the fork you created), 

In a web browser, ensure that you have your fork of the repo open in GitHub. Remember you can open the repo from the command line again:


```bash
# Ensure you are in the correct repo:
cd ~/chainguard-app-building/app-building-for-chainguard-csms/

# Use open command + git command + pipe + sed to open the web browser with command line:
open "$(git remote get-url origin | sed -E 's#^git@([^:]+):#https://\1/#; s#\.git$##')"
```

In the GitHub repo, find the 'Contribute' dropdown (upper-left), open the dropdown, review branch commit info, click 'Open pull request' button:

![image](merge1.png?)

Review the branch info, click the Pull request dropdown, ensure `Create draft pull request` is chosen:

![image](createdraftpr.png?)

Click `Draft pull request` button:
![image](createdraftpr2.png?)

You are done with the extra credit when you have created the pull request. 

A new PR should now exist back at the orinigal version of the repo of this class material with your unique file in it!

#### End of extra credit module

</details>

<details>
<summary><strong>Extra Extra Credit: Create a Repo Using the GitHub API</strong></summary>

## Create a Repo Using the GitHub API

You can also create a GitHub repository programmatically using the GitHub API. This is useful for automation or scripting use cases.

### Step 1: Create a GitHub Personal Access Token

- Log in to [GitHub](https://github.com/login)
- Navigate to [https://github.com/settings/tokens](https://github.com/settings/tokens)
- Click **"Generate new token (classic)"**

![image](classic-api-token.png?)

- Select the `repo` scope and set a short expiration

![image](classic-api-token-settings.png?)

- Copy the token (you will only see it once)

### Step 2: Store the token as an environment variable

```bash
# Open your shell config (e.g., ~/.zshrc)
open -a TextEdit ~/.zshrc

# Add this line to the end, using your actual token
export GITHUB_API_TOKEN="ghp_YourActualTokenHere"

# Apply the update
source ~/.zshrc
```

### Step 3: Use curl to create a new GitHub repo

```bash
cd ~/chainguard-app-building

curl \
  -X POST \
  -H "Authorization: token ${GITHUB_API_TOKEN}" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{
    "name": "mywebserver",
    "auto_init": true,
    "private": false
  }' \
  | tee repo_metadata.json
```

### Step 4: Clone your new repo

```bash
# If you have jq installed:
brew install jq

git clone $(jq -r '.ssh_url' repo_metadata.json)

cd mywebserver
```

Congratulations! You now have a repo created and cloned entirely through automation!

</details>

| Previous: [Linux/Bash](/labs/00_bash_cloudshell) | Next: [Chainguard in CI](/labs/01a_chainguard_ci) |
|-------------------------------------------:|:--------------------------------------------------|