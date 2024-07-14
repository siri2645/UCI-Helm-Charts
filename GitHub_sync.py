#Steps: 
# 1. pip install PyGithub
# 2. Export token in .bashrc or bash_profile with this names PRIMARY_GITHUB_TOKEN, SECONDARY_GITHUB_TOKEN
# 3. run the python cdoe : python3 sync_github_repos.py --primary_repo primary_user/primary_repo --secondary_repo secondary_user/secondary_repo --temp_dir /tmp/dir


from github import Github, GithubException
import argparse
import subprocess
import os
import shutil

# Function to sync commits from primary to secondary repository
def sync_repos(primary_repo, secondary_repo, temp_dir):
    try:
        # Clone the primary repository
        primary_clone_path = os.path.join(temp_dir, "primary_repo")
        secondary_clone_path = os.path.join(temp_dir, "secondary_repo")
        
        if os.path.exists(primary_clone_path):
            shutil.rmtree(primary_clone_path)
        if os.path.exists(secondary_clone_path):
            shutil.rmtree(secondary_clone_path)
        
        subprocess.run(["git", "clone", primary_repo.clone_url, primary_clone_path], check=True)
        subprocess.run(["git", "clone", secondary_repo.clone_url, secondary_clone_path], check=True)

        # Fetch the latest commits from primary repository
        subprocess.run(["git", "fetch", "origin"], cwd=primary_clone_path, check=True)

        # Push the commits to the secondary repository
        subprocess.run(["git", "remote", "add", "secondary", secondary_repo.clone_url], cwd=primary_clone_path, check=True)
        subprocess.run(["git", "push", "secondary", "--all"], cwd=primary_clone_path, check=True)
        subprocess.run(["git", "push", "secondary", "--tags"], cwd=primary_clone_path, check=True)
        
        print(f"Successfully synced commits from {primary_repo.full_name} to {secondary_repo.full_name}")

    except subprocess.CalledProcessError as e:
        print(f"Error syncing repositories: {e}")
    finally:
        # Cleanup temporary directories
        if os.path.exists(primary_clone_path):
            shutil.rmtree(primary_clone_path)
        if os.path.exists(secondary_clone_path):
            shutil.rmtree(secondary_clone_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Sync commits from primary to secondary GitHub repository.')
    parser.add_argument('--primary_repo', type=str, required=True, help='Full name of the primary repository (e.g., user/repo)')
    parser.add_argument('--secondary_repo', type=str, required=True, help='Full name of the secondary repository (e.g., user/repo)')
    parser.add_argument('--temp_dir', type=str, default='/tmp', help='Temporary directory to clone repositories')

    args = parser.parse_args()

    primary_token = os.getenv('PRIMARY_GITHUB_TOKEN')
    secondary_token = os.getenv('SECONDARY_GITHUB_TOKEN')

    if not primary_token or not secondary_token:
        print("Error: PRIMARY_GITHUB_TOKEN and SECONDARY_GITHUB_TOKEN environment variables must be set.")
        exit(1)

    primary_g = Github(primary_token)
    secondary_g = Github(secondary_token)

    try:
        primary_repo = primary_g.get_repo(args.primary_repo)
        secondary_repo = secondary_g.get_repo(args.secondary_repo)
    except GithubException as e:
        print(f"Error accessing repository: {e}")
        exit(1)

    sync_repos(primary_repo, secondary_repo, args.temp_dir)
