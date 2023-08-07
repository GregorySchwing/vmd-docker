# vmd-docker
A docker file to setup an environment to compile VMD from source.

Automates the instructions found https://github.com/jvermaas/vmd-packaging-instructions

To use:
sudo docker build -t vmd .
sudo docker run --gpus all --ipc=host --ulimit memlock=-1 --ulimit stack=67108864 --rm -it -p 8888:8888 vmd
