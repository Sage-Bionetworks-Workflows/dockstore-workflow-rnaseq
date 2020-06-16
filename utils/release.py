#! /usr/bin/env python

import argparse
import sys

import semver
import git


parser = argparse.ArgumentParser(
  description='Create a git release')
parser.add_argument(
  '--major',
  action='store_true',
  help='creates a major release')
args = parser.parse_args()
major_bump = args.major

repo = git.Repo('.') # Assumes script is run from repo root
assert not repo.is_dirty(), 'Cannot create a release: repo is dirty. Commit first, then rerun script.'

# Ensure everything is up to date
repo.remote().fetch()
branch = repo.active_branch
if branch.name != 'master':
  raise Exception(f'The active branch is {branch}, not master. Please switch to master before performing a release.')

# This assumes the remote is named origin
commits_behind = len(list(repo.iter_commits('master..origin/master')))
if commits_behind != 0:
  raise Exception(f'Branch is {commits_behind} commits behind remote. Pull before attempting release.')

# Ensure the branch has a tracking_branch set
tracking_branch = branch.tracking_branch()
if tracking_branch is None:
  raise Exception('Please set a tracking branch before attempting release.')

# Find the latest tag
tags = repo.tags
tags_sorted = sorted(repo.tags, key=lambda t: t.commit.committed_date)
last_tag = str(tags_sorted[-1])

# Use semver to create the new version
current_version = semver.VersionInfo.parse(last_tag[1:])
if major_bump:
  new_version = current_version.bump_major()
else:
  new_version = current_version.bump_minor()

# Create and push the new tag
new_tagname = f'v{str(new_version)}'
new_tag = repo.create_tag(new_tagname)
repo.remote().push(new_tag)

