# Install Tactotron

Set up the virtual machine -> documentation indicates that you need at LEASE 40GB space to train models

```bash
$ sudo apt update
$ sudo apt dist-upgrade
$ sudo apt install build-essential
$ sudo passwd [LOGIN]
```

1. Install git
2. Copy rubikscomplex.net key to instance using gcloud, e.g.:
```
gcloud compute scp rubikscomplex_20160309 cdavoren@voice4:/home/cdavoren/.ssh
```

## Install Basic Tools

1. git (https://www.kernel.org/pub/software/scm/git/)
2. gnu stow (http://ftp.gnu.org/gnu/stow/)

## Environment Setup

```bash
$ git clone rubikscomplex.net:/srv/git/dotfiles.git
$ rm .bashrc .bash_logout
$ cd dotfiles
$ stow bash
$ stow screen
$ stow tmux
```

## Python Setup

```bash
$ sudo install python3-pip
```

To create a virtualenv for python3 use:
```
$ virtualenv -m python3 env
```

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

