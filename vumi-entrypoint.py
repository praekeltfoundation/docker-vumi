#!/usr/bin/env python
from __future__ import print_function

import os
import sys


class ProcessRunner(object):
    args = []

    def __init__(self, executable):
        self.executable = executable

    def add_env_arg(self, env_key, default=None):
        """
        Add an argument ``opt_key`` with the value of the ``env_key``
        environment variable if it is set.
        """
        env_val = os.environ.get(env_key, default)
        if env_val is not None:
            self.args.append(env_val)

    def add_env_opt(self, opt_key, env_key, default=None):
        """
        Add the option ``opt_key`` with the value of the ``env_key``
        environment variable if it is set.
        """
        env_val = os.environ.get(env_key, default)
        if env_val is not None:
            self.args += [opt_key, env_val]

    def add_args(self, args):
        """ Add a list of extra arguments. """
        self.args += args

    def exec_process(self, user=None, dry_run='RUNNER_DRY_RUN' in os.environ):
        """
        Exec the process, switching to the given user first if provided.

        :param user: the user or UID to switch to before execution
        :param dry_run: if True, print the command to be executed and exit
        """
        user_args = ['su-exec', user] if user is not None else []
        final_args = user_args + [self.executable] + self.args

        if dry_run:
            print(*final_args)
            sys.exit(0)

        os.execvp(final_args[0], final_args)


def vumi_opts():
    set_opts = []
    for env_key, env_val in os.environ.items():
        if env_key.startswith('VUMI_OPT_'):
            opt_key = env_key[len('VUMI_OPT_'):].lower()
            set_opts.append('%s:%s' % (opt_key, env_val,))
    return set_opts

if __name__ == '__main__':
    # Generate Twisted's plugin cache just before running -- all plugins should
    # be installed at this point. Twisted is installed site-wide, so the root
    # user is needed to perform this operation. See:
    # http://twistedmatrix.com/documents/current/core/howto/plugin.html#plugin-caching
    from twisted.plugin import IPlugin, getPlugins
    list(getPlugins(IPlugin))

    runner = ProcessRunner('twistd')
    runner.add_args(['--nodaemon', '--pidfile', ''])

    # Basics
    runner.add_env_arg('TWISTD_COMMAND', default='vumi_worker')
    runner.add_env_opt('--worker-class', 'WORKER_CLASS')
    runner.add_env_opt('--config', 'CONFIG_FILE')

    # AMQP
    runner.add_env_opt('--hostname', 'AMQP_HOST')
    runner.add_env_opt('--port', 'AMQP_PORT')
    runner.add_env_opt('--username', 'AMQP_USERNAME')
    runner.add_env_opt('--password', 'AMQP_PASSWORD')

    # Sentry
    runner.add_env_opt('--sentry', 'SENTRY_DSN')

    # Vumi
    for set_opt in vumi_opts():
        runner.add_args(['--set-option', set_opt])

    # Any extra arguments
    runner.add_args(sys.argv[1:])

    runner.exec_process(user='vumi')
