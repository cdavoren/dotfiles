# Install Tactotron

Initial points:
  - Set up the virtual machine -> documentation indicates that you need at LEAST 40GB space to train models - in this case I use a separately mounted disk with space at 60GB+
  - The name of the VM instance in this guide is ```comp-vcpu8```

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

Extras:
  - Install Git (https://www.kernel.org/pub/software/scm/git/)
  - Install Stow (http://ftp.gnu.org/gnu/stow/)
  - Install zsh via apt
  - Setup zsh via oh-my-zsh (use README.md curl command - https://github.com/robbyrussell/oh-my-zsh)
  - Clone dotfiles repo to use configurations (beware hardcoded references to old login 'davorian')

## Install Basic Tools

1. git (https://www.kernel.org/pub/software/scm/git/)
2. gnu stow (http://ftp.gnu.org/gnu/stow/)

## Python Setup

```bash
$ sudo install python3-pip python-venv
```

To create a virtualenv for python3 use:
```
$ python3 -m venv [ENV_NAME]
```
Try to use ENV_NAME values that are meaningful to the current project (prevents confusion when changing directories)

## Tensorflow (non-GPU)

```bash
$ sudo apt install openjdk-8-jdk
```

**Create a virtualenv FIRST**

```bash
$ pip install six numpy wheel
$ git clone https://github.com/tensorflow/tensorflow 
$ cd tensorflow
$ ./configure
$ bazel build --config=opt //tensorflow/tools/pip_package:build_pip_package
$ bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg
,``` 

Now wait a very long time.  There are at least 4000 compilation targets here.

## Train Models

```bash
$ git clone https://github.com/keithito/tacotron
```

Edit `hparams.py` accordingly.  Apparently not much improvement after ~250k steps although provided samples are 877k steps.  (?How to configure "steps", what does this mean?  Read the published paper?)

