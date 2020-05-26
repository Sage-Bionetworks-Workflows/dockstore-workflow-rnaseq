#! /usr/bin/env python3

"""Git URL

Creates a github url for a resource in clone repository.
"""


import argparse
import git
import os


def github_url(path='.', raw=False):
    """ Construct a github url

    Args:
        path (str): path to a resource in current clone
        raw (bool): whether url should be the raw file or a regular github url
    """
    repo = git.Repo('.', search_parent_directories=True)
    assert not repo.bare
    # TODO: handle case where the remote is not named 'origin'
    origin = repo.remotes.origin
    assert origin.exists()
    remote_url = list(origin.urls)[0]
    if remote_url.startswith('git@'):
        # remove git@ from beginning
        remote_url = remote_url[4:]
        # replace colon with forward-slash
        remote_url = remote_url.replace(':', '/')
        # add https protocol
        remote_url = f'https://{remote_url}'

    # remove .git from end
    if remote_url.endswith('.git'):
        remote_url = remote_url[:-4]

    blob = 'blob/'
    if raw:
        # make it the raw url
        remote_url = remote_url.replace('github', 'raw.githubusercontent')
        blob = ''

    # path to object relative to repo root
    abs_path = os.path.abspath(path)
    path_from_root = abs_path.replace(repo.working_tree_dir,'')

    # latest commit SHA
    sha = repo.rev_parse('HEAD').hexsha

    return f'{remote_url}/{blob}{sha}{path_from_root}'


def main():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        '--path',
        default='.',
        help='Relative path')
    parser.add_argument(
        '--raw',
        action='store_true',
        help='Optionally generate the url to the raw file')
    args = parser.parse_args()
    print(github_url(args.path, args.raw))


if __name__ == '__main__':
    main()
