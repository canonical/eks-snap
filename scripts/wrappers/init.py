#!/usr/bin/env python3

import click

# from common.utils import ensure_started, exit_if_no_permission, is_cluster_locked, xable
# from status import get_status, get_available_addons, get_current_arch


@click.command()
def init():
    """
    Initialise the EKS cluster
    """
    if click.confirm('Do you want to enable EBS support?'):
        click.echo('')
        click.echo('A user with proper IAM permissions need to be specified. See ')
        click.prompt('The access key id of the authorised user: ')
        click.prompt('The secret access key of the authorised user: ')
        click.echo('Enabling EBS')



if __name__ == '__main__':
    init(prog_name='eks init')
