# GitHub Lab: Fork & Clone a Repository

## Goal

By the end of this lab, you will:

1. Set up SSH keys for GitHub  
2. Fork an existing GitHub repo using the GitHub UI  
3. Clone your fork locally using Git and SSH  
4. Make and push commits to your fork  
> Note: Ensure you are logged into your [GitHub account](https://github.com/login) for this lab

---

## Module 1: Set up local SSH keys for GitHub

```bash
# Ensure Git is Installed
git --version

# If not...
brew install git

# Prepare Your Workspace
mkdir -p ~/chainguard-app-building
cd ~/chainguard-app-building

# If you don’t have an SSH key yet:
ssh-keygen
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

### Module complete

---

## Module 2: Fork a Repository via GitHub UI

1. Visit this repo: [https://github.com/Sayre-Tnunu/app-building-for-chainguard-csms](https://github.com/Sayre-Tnunu/app-building-for-chainguard-csms)
2. Click the **Fork** button (top-right of the page)
3. Choose your personal account as the destination

Once the fork completes, you will be taken to **your own copy** of the repo (e.g. `yourusername/app-building-for-chainguard-csms`)

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

```

---

## Module 4: Make and push commits to your fork 

Set your Git identity:


```bash
# Replace "you@example.com" and "Your Name" with your actual email and name (doesn't have to be a real email)
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Create a file
echo "hello from my fork" > demofile

# Track the file
git add demofile

# Commit
git commit -m "add demofile"

# Push it!
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
> open "$(git remote get-url origin | sed -E 's#^git@([^:]+):#https://\1/#; s#\.git$##')"
> ```

End of module when you have verified your new file is added to the rempte repo

---

<details>
<summary><strong>Extra Credit: Create a Repo Using the GitHub API</strong></summary>

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