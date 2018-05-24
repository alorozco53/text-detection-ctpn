FROM ubuntu:16.04

# general
RUN apt-get update && apt-get install -y build-essential cmake \ 
    wget git unzip \
    yasm pkg-config software-properties-common python3-software-properties

# get python 3.6.3 
RUN add-apt-repository ppa:jonathonf/python-3.6 && apt-get update && \
    apt-get install -y python3.6 python3.6-dev python3.6-venv

# for tesseract ; why doesn't it work at below after python ln change??
RUN add-apt-repository ppa:alex-p/tesseract-ocr && apt-get update

# lib for opencv
RUN apt-get update && apt-get install -y  libjpeg8-dev libtiff5-dev libjasper-dev libpng12-dev \
    libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libdc1394-22-dev \
    libxvidcore-dev libx264-dev libgtk-3-dev libmagic-dev \
    libatlas-base-dev gfortran liblapack-dev \
    libtbb2 libtbb-dev libpq-dev

# pip3 stuff
RUN wget https://bootstrap.pypa.io/get-pip.py && \
    python3.6 get-pip.py && \
    python3.6 -m pip install pip --upgrade

RUN rm -f /usr/bin/python && ln -s /usr/bin/python3.6 /usr/bin/python
RUN rm -f /usr/bin/python3 && ln -s /usr/bin/python3.6 /usr/bin/python3
RUN rm -f /usr/local/bin/pip && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip
RUN rm -f /usr/local/bin/pip3 && ln -s /usr/local/bin/pip3.6 /usr/local/bin/pip3

# numpy etc
RUN apt-get install -y gcc python3.6-dev
RUN apt-get install -y gcc
RUN pip3 install psutil --user 
RUN pip3 install wheel 
RUN pip3 install Cython==0.24 
RUN pip3 install numpy 
RUN pip3 install pandas 
RUN pip3 install scipy 
RUN pip3 install scikit-learn 
RUN pip3 install python-magic 
RUN pip3 install Flask==0.12.2 
RUN pip3 install tensorflow==1.3.0 
RUN pip3 install keras==2.0.8
RUN pip3 install pdf2image==0.1.6
RUN pip3 install easydict

WORKDIR /

# opencv
RUN wget https://github.com/Itseez/opencv/archive/3.3.1.zip -O opencv.zip \
    && unzip opencv.zip \
    && wget https://github.com/Itseez/opencv_contrib/archive/3.3.1.zip -O opencv_contrib.zip \
    && unzip opencv_contrib \
    && mkdir /opencv-3.3.1/build \
    && cd /opencv-3.3.1/build \
    && cmake -DOPENCV_EXTRA_MODULES_PATH=/opencv_contrib-3.3.1/modules \
        -DBUILD_TIFF=ON \
        -DBUILD_opencv_java=OFF \
        -DWITH_CUDA=OFF \
        -DENABLE_AVX=ON \
        -DWITH_OPENGL=ON \
        -DWITH_OPENCL=ON \
        -DWITH_IPP=ON \
        -DWITH_TBB=ON \
        -DWITH_EIGEN=ON \
        -DWITH_V4L=ON \
        -DBUILD_TESTS=OFF \
        -DBUILD_PERF_TESTS=OFF \
        -DCMAKE_CXX_FLAGS=-std=c++11 \
        -DENABLE_PRECOMPILED_HEADERS=OFF \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DBUILD_opencv_python3=ON \
        -DCMAKE_INSTALL_PREFIX=$(python3.6 -c "import sys; print(sys.prefix)") \
        -DPYTHON_EXECUTABLE=$(which python3.6) \
        -DPYTHON_INCLUDE_DIR=$(python3.6 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())") \
        -DPYTHON_PACKAGES_PATH=$(python3.6 -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())") .. \
    && make install \
    && rm /opencv.zip \
    && rm /opencv_contrib.zip \
    && rm -r /opencv-3.3.1 \
    && rm -r /opencv_contrib-3.3.1


RUN mkdir /home/workspace
WORKDIR /home/workspace
COPY . /home/workspace

# setup
RUN cd lib/utils
RUN chmod +x make.sh
RUN ./make.sh

# Run index.py when the container launches
CMD ["python3", "./ctpn/demo.py"]