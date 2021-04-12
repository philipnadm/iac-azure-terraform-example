## Part one: Github basics

Starting from scratch, in the end of this you will end up with a development environment on your computer. Ready to deploy infrastructure.


### Step 1: Fork this github project
   - More info: [How to fork a repo](https://docs.github.com/en/free-pro-team@latest/github/getting-started-with-github/fork-a-repo)
   - Fork the [this github project](https://github.com/philipnadm/iac-azure-terraform-example/)


**Result:**
```
   This will give you your own copy of this project
   It allows you to freely experiment with changes without affecting the original project.
```

---

### Step 2: Clone this project
   - More info: [Cloning a repo](https://docs.github.com/en/free-pro-team@latest/github/creating-cloning-and-archiving-repositories/cloning-a-repository)
   - Remember to clone your own fork and NOT this project

**Result:**
```
    This will create a local copy on your computer and sync between the two locations
```

---

### Step 3: The files listed in .gitignore will not be added to git
   - More info: [gitignore](https://git-scm.com/docs/gitignore)
   - Specifies intentionally untracked files to ignore
   - **Action:**   Create the file: terraform.tfvars in the root folder of the project 
   - This file will not be included in git because of .gitignore

 **example:** *terraform.tfvars*
```
# local file, that is'nt under versioncontrol
#Define application name, used to prefix all resources with your unique name
app_name = "<insert_your_unique_name"
```

---

### Step 4: Open project in VS Code or other IDE
  - Tip: use the built-in function in Github Desktop

---

### Step 5: Do a change
  - There is a default value in the file ```azure-variable.tf``` containing a default password. This should be removed.

 **File:** *azure-variable.tf*
```
# remove the following line
default     = "S3cr3tP@ssw0rd"
```
 **File:** *terraform.tfvars*
```
# add the following line
linux_admin_password = "<your secret pwd>"
```

*Note:* The password should be stored in a Vault, but that is not covered by this introduction

**Result:**
```
    The password is now moved to a file that is only stored on your PC and the changed file azure-variable.tf is ready to be pushed to git.
```

---

### Step 6: Commit
  - More info: [Git commit](https://github.com/git-guides/git-commit)
  - This will only commit you changes to your local clone of the project
  - **Remember** Always add a commit message describing the change

---

### Step 7: Push your changes to github
  - More info: [Git push](https://github.com/git-guides/git-push)
  - This uploads all local branch commits to the corresponding remote branch.

