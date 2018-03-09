# Install Tactotron

Initial points:
  - OS used in these notes was Ubuntu 17.10
  - Set up the virtual machine -> documentation indicates that you need at LEAST 40GB space to train models - in this case I use a separately mounted disk with space at 60GB+
  - The name of the VM instance in this guide is ```comp-vcpu8```
  - The name of the training/data disk image in this guide is ```training```

Ensure that the instance has ssh private/public key acccess to old Linode server using gcloud utility in Windows Command Prompt:

```
gcloud compute scp rubikscomplex_20160309 cdavoren@comp-vcpu8:/home/cdavoren/.ssh
```

```bash
$ sudo apt update
$ sudo apt dist-upgrade
$ sudo apt install build-essential
$ sudo passwd [LOGIN]
```

## Basic Server Setup

  1. Set local password for user using ```sudo passwd [USER]``` (will be required for ZSH installation)
  2. Install Git (https://www.kernel.org/pub/software/scm/git/)
  
      *Remember:*
      ```bash
      $ sudo apt install gettext libz-dev libcurl4-openssl-dev
      ```
  1. Install Stow (http://ftp.gnu.org/gnu/stow/)
  
      *To avoid warning about Perl module Test::Output:*
      ```bash
      $ sudo cpan -f Test::Output
      ```
  1. Clone dotfiles repo to use configurations (beware hardcoded references to old login 'davorian')
  1. Install zsh 
     ```
     $ sudo apt install zsh
     ```
     Setup zsh via oh-my-zsh (use README.md curl command - https://github.com/robbyrussell/oh-my-zsh)

## Attach Training/Data Disk Image

1. Attach image via gcloud command:
    ```
    gcloud compute instances attach-disk comp-vcpu8 --disk training
    ```
1. Check that it's attached properly by running ```lsblk``` - should see sdb in the disk list
1. Mount image in appropriate named & created directory e.g. /mnt/training
    ```bash
    $ sudo mkdir /mnt/training
    $ sudo mount -o discard,defaults /dev/sdb /mnt/training
    ```
1. Format the image if it hasn't been already:
    ```bash
    $ sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb
    ```
- Ensure all users have access to the disk
    ```bash
    $ sudo chmod a+w /mnt/training
    ```
- Backup current fstab file:
    ```bash
    $ sudo cp /etc/fstab /etc/fstab.backup
    ```
- Find UUID of new device:
    ```bash
    $ sudo blkid /dev/sdb
    ```
- Add device to fstab file with line:
    ```fstab
    UUID=[UUID_VALUE] /mnt/training ext4 discard,defaults,nofail 0 2
    ```

## Python Setup

To create a virtualenv for python3 use:
```
$ sudo apt install python3-pip
$ sudo apt install python3-venv
$ sudo apt install wheel
$ python3 -m venv [ENV_NAME]
```

**Try to use ENV_NAME values that are meaningful to the current project (prevents confusion when changing directories)**

## Tensorflow Requirements

### Installing Bazel

Uses custom apt repository

```
$ sudo apt install openjdk-8-jdk
$ echo "deb [arch=amd64] http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://bazel.build/bazel-release.pub.gpg | sudo apt-key add -
$ sudo apt update
$ sudo apt install bazel
```

## Tensorflow Compilation (non-GPU)

**Create a virtualenv FIRST for this, do NOT check out r1.0 as the documentation suggests as this does not recognise the latest version of bazel.**

```bash
$ git clone https://github.com/tensorflow/tensorflow 
$ cd tensorflow
$ python3 -m venv --system-site-packages env-tens
$ . ./env-tens/bin/activate
$ pip install numpy six wheel 
$ ./configure
$ bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
$ bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
```
Now wait a very long time.  There are nearly 5000 compilation targets here.

## Train Models

```bash
$ git clone https://github.com/keithito/tacotron
$ cd tacotron
$ python3 -m venv --system-site-packages env-kei
$ . ./env-kei/bin/activate
$ pip3 install -r requirements.txt
```

Edit `hparams.py` accordingly.  Apparently not much improvement after ~250k steps although provided samples are 877k steps.  (?How to configure "steps", what does this mean?  Read the published paper?)

