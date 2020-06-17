#! /usr/bin/env python3

"""Run Toil

Runs a CWL (https://www.commonwl.org/) workflow on a toil
(http://toil.ucsc-cgl.org/) cluster in AWS. This uses configuration-driven
options. The configuration directory is "jobs".

Run example: ./run-toil.py --dry-run jobs/test-main-paired
Run ./run-toil.py -h for more information on the tool arguments, or see the
README in this directory for further usage and configuration advice.
"""

import argparse
import atexit
import errno
import json
import logging
import os
import subprocess

default_jobdir = 'jobs/default'
default_options_path = 'jobs/default/options.json'
synapse_config_path = '/etc/synapse/.synapseConfig'

log_format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
logging.basicConfig(format=log_format)
script_name = os.path.basename(__file__)
log = logging.getLogger(script_name)
log.setLevel(logging.DEBUG)


class Options(object):
    """
    Options contains configuration for running a workflow.

    Attributes:
        fields (list of str): the list of required option fields
    """
    fields = [
        'cluster_name',
        'run_name',
        'log_level',
        'retry_count',
        'target_time',
        'default_disk',
        'node_types',
        'max_nodes',
        'node_storage',
        'preemptable_compensation',
        'rescue_frequency',
        'cwl',
        'job_directory',
        'custom_options_path',
        'cwl_args_path',
        'restart',
        'dry_run',
        'jobstore',
        'dest_bucket',
        'log_file',
        'log_path',
        'worker_logs_dir'
    ]

    def __init__(self, options_dict):
        """
        Creates an Options instance. Fields are created dynamically from the
        dictionary used to initialize the class instance. Some further fields
        will be derived from those. The instance will fail validation if any
        required fields are missing.

        Args:
        options_dict: a dictionary of configuration options
        """
        self.__dict__.update(options_dict)

        self.jobstore = 'aws:{}:{}-{}'.format(
            self.zone[:-1], self.cluster_name, self.run_name)
        self.dest_bucket = 's3://{}-out'.format(self.cluster_name)
        self.log_file = '/var/log/toil/{}.log'.format(self.run_name)
        self.log_path = '/var/log/toil/workers/{}'.format(self.run_name)
        self.worker_logs_dir = '/var/log/toil/workers/{}'.format(self.run_name)
        self._validate()

    def _validate(self):
        """Verifies that all the expected fields are present"""
        for field in self.fields:
            error_message = 'required option missing: {}'.format(field)
            assert field in self.__dict__, error_message

    def print(self):
        """Prints all fields"""
        for key in sorted(self.__dict__.keys()):
            value = self.__dict__[key]
            log.debug(f'opts: {key} = {value}')


class ToilCommand:
    """
    Base class for toil commands.

    Attributes:
        options (Options): configuration object used to construct the command
    """
    command = ['echo', 'No toil command set']

    def __init__(self, options):
        self.options = options

    def run(self):
        command_str = ' '.join(self.command)
        log.info(f'Toil Command: {command_str}')
        if not self.options.dry_run:
            subprocess.check_output(self.command)


class ToilCleanCommand(ToilCommand):
    """
    Cleans a jobstore.

    Attributes:
        options (Options): configuration object used to construct the command
    """
    def __init__(self, options):
        super().__init__(options)
        self.command = ['toil', 'clean', options.jobstore]


class ToilRunCommand(ToilCommand):
    """
    Cleans a jobstore.

    Attributes:
        options (Options): configuration object used to construct the command
        provisioner (str): the cloud provisioner for the cluster (AWS)
        batch_system (str): the workflow orchestrator (Mesos)
    """
    provisioner = 'aws'
    batch_system = 'mesos'

    def __init__(self, options):
        super().__init__(options)

        self.command = [
            'toil-cwl-runner',
            '--provisioner', 'aws',
            '--batchSystem', 'mesos',
            '--jobStore', options.jobstore,
            '--logLevel', options.log_level,
            '--logFile', options.log_file,
            '--writeLogs', options.worker_logs_dir,
            '--retryCount', options.retry_count,
            '--metrics',
            '--runCwlInternalJobsOnWorkers',
            '--targetTime', options.target_time,
            '--defaultDisk', options.default_disk,
            '--nodeTypes', options.node_types,
            '--maxNodes', options.max_nodes,
            '--nodeStorage', options.node_storage,
            '--destBucket', options.dest_bucket,
            '--rescueJobsFrequency', options.rescue_frequency,
            '--preserve-entire-environment'
        ]
        # Add some options only if node_types contains the spot syntax
        if options.node_types.find(':') > -1:
            self.command.extend([
                '--defaultPreemptable',
                '--preemptableCompensation', options.preemptable_compensation
            ])

        if options.restart:
            self.command.append('--restart')

        # Finally, add the cwl file and its arguments file
        self.command.extend([options.cwl, options.cwl_args_path])


def parse_args():
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument(
        'job_directory',
        help='Directory containing options.json and requirements files')
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '--clean',
        help='Clean (remove) the jobstore, and start the job fresh',
        action='store_true')
    group.add_argument(
        '--restart',
        help='Restart a job that was previously interrupted',
        action='store_true')
    parser.add_argument(
        '--dry-run',
        help='Show the toil command that would be run, but don\'t run it',
        action='store_true')
    return parser.parse_args()


def directory_exists(dir_path):
    """Check that the directory at dir_path exists"""
    error_message = 'directory missing: {}'.format(dir_path)
    test = os.path.exists(dir_path) and not os.path.isfile(dir_path)
    assert test, error_message


def file_exists(file_path):
    """Check that the file at file_path exists"""
    error_message = 'file missing: {}'.format(file_path)
    test = os.path.exists(file_path) and os.path.isfile(file_path)
    assert test, error_message


def validate_paths(job_directory, custom_options_path, cwl_args_path):
    """Validate directories and files are present"""
    directory_exists(job_directory)
    file_exists(custom_options_path)
    file_exists(cwl_args_path)


def make_log_directories(log_path):
    """Make directories for the main toil log and the worker logs"""
    log.debug('Making log directories: {}'.format(log_path))
    try:
        os.makedirs(log_path)
        log.debug('Path {} created.'.format(log_path))
    except OSError as e:
        if e.errno == errno.EEXIST:
            log.warning('Directory {} already exists.'.format(log_path))
        else:
            raise


def get_opts(default_options_path, args):
    """
    Merge custom options into defaults and add some args. Use this to construct
    an Options instance.
    """
    job_directory = args.job_directory
    custom_options_path = '{}/options.json'.format(job_directory)
    cwl_args_path = '{}/job.json'.format(job_directory)

    validate_paths(job_directory, custom_options_path, cwl_args_path)

    # load default options
    with open(default_options_path) as json_file:
        opts = json.load(json_file)

    # load custom options
    with open(custom_options_path) as json_file:
        custom_opts = json.load(json_file)

    # merge custom options into defaults
    opts.update(custom_opts)

    # Add argument-based options
    opts['job_directory'] = job_directory
    opts['custom_options_path'] = custom_options_path
    opts['cwl_args_path'] = cwl_args_path
    opts['restart'] = args.restart
    opts['dry_run'] = args.dry_run

    return Options(opts)


def add_environment_vars(options):
    """Add values to environment that will be used by ToilRunCommand"""
    os.environ['TOIL_AWS_ZONE'] = options.zone
    os.environ['TMPDIR'] = options.tmpdir
    for key in sorted(os.environ.keys()):
        value = os.environ[key]
        log.debug(f'env: {key} = {value}')


def main():
    args = parse_args()

    # Get the options object
    options = get_opts(default_options_path, args)

    header = 'BEGIN TOIL DRY RUN' if options.dry_run else 'BEGIN TOIL RUN'
    log.info(f'---------- {header} ----------')
    options.print()

    # Validate that the specified cwl file exists
    file_exists(options.cwl)

    # Validate that the .synapseConfig file is present
    file_exists(synapse_config_path)

    # Add environment variables that will be passed to Toil
    add_environment_vars(options)

    # Make directories for main and worker logs
    make_log_directories(options.log_path)

    # Clean jobstore
    if args.clean:
        ToilCleanCommand(options).run()

    # Run the toil job
    ToilRunCommand(options).run()


main()

