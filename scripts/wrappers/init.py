#!/usr/bin/env python3

import os
import click
import shutil
from pathlib import Path


@click.command()
def init():
    """
    Initialise the EKS cluster
    """
    if click.confirm('Do you want to enable EBS support?'):
        click.echo('A user with proper IAM permissions need to be specified.')
        key = click.prompt('The access key id of the authorised user')
        access = click.prompt('The secret access key of the authorised user')
        source_dir = "{}/actions/aws-ebs-csi-driver".format(os.getenv('SNAP'))
        destination_dir = "{}/actions/aws-ebs-csi-driver".format(os.getenv('SNAP_DATA'))
        shutil.rmtree(destination_dir, ignore_errors=True)
        shutil.copytree(source_dir, destination_dir)
        with open("{}/secret.yaml".format(source_dir), "rt") as f:
            data = f.read()
            data = data.replace('{{key_id}}', key)
            data = data.replace('{{access_key}}', access)
            secrets_file = "{}/secret.yaml".format(destination_dir)
            os.chmod(secrets_file, 0o600)
            with open(secrets_file, "w+") as s:
                s.write(data)
        Path('{}/var/lock/ebs-ready'.format(os.getenv('SNAP_DATA'))).touch()
        click.echo('')
    if click.confirm('Do you want to enable EFS support?'):
        fsid = click.prompt('The EFS file system ID')
        size = click.prompt('The size in GB of the volume to be created')
        source_dir = "{}/actions/aws-efs-csi-driver".format(os.getenv('SNAP'))
        destination_dir = "{}/actions/aws-efs-csi-driver".format(os.getenv('SNAP_DATA'))
        shutil.rmtree(destination_dir, ignore_errors=True)
        shutil.copytree(source_dir, destination_dir)
        with open("{}/setup/pv.yaml".format(source_dir), "rt") as f:
            data = f.read()
            data = data.replace('{{fsid}}', fsid)
            data = data.replace('{{size}}', size)
            with open("{}/setup/pv.yaml".format(destination_dir), "w+") as s:
                s.write(data)
        Path('{}/var/lock/efs-ready'.format(os.getenv('SNAP_DATA'))).touch()
        click.echo('')


if __name__ == '__main__':
    init(prog_name='eks init')
